[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = 128
    ny = 128
  []
[]

[Preconditioning]
  [./Newton_SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  [../]
[]

[Executioner]
  type = Transient

  start_time = 0
  end_time = 50

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'
  
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    growth_factor = 1.5
    dt = 0.05
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[VectorPostprocessors]
  [centerline_T]
    type = LineValueSampler
    variable = vel_x
    start_point = '0.5 0 0'
    end_point = '0.5 1.0 0'
    num_points = 50          # 沿高度取100个点
    sort_by = y
    outputs = csv
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    execute_on = 'timestep_end'
    sync_times = '10 20 30 40 50'  # 仅在这些时间步输出
    sync_only = true
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
  []
  [p][]
[]

[AuxVariables]
  [vel_x]
  []
  [vel_y]
  []
[]

[AuxKernels]
  [vel_x]
    type = VectorVariableComponentAux
    variable = vel_x
    vector_variable = velocity
    component = 'x'
  []
  [vel_y]
    type = VectorVariableComponentAux
    variable = vel_y
    vector_variable = velocity
    component = 'y'
  []
[]

[BCs]
  [top_x]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top'
    values = '1 0 0'
  []
  
  [no_slip_y]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'left right bottom'
    values = '0 0 0'
  []
  
  [p_zero]
    type = DirichletBC
    boundary = 'left'
    variable = p
    value = 0
  []
[]

[Kernels]
  [./mass]
    type = INSADMass
    variable = p
  [../]
  [mass_pspg]
    type = INSADMassPSPG
    variable = p
  []

  [momentum_time]
    type = INSADMomentumTimeDerivative
    variable = velocity
  []

  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  [../]

  [momentum_advection]
    type = INSADMomentumAdvection
    variable = velocity
  []

  [momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = p
    integrate_p_by_parts = true
  []
  [supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []
[]

[Materials]
  [./ad_const]
    type = ADGenericConstantMaterial
    # alpha = coefficient of thermal expansion where rho  = rho0 -alpha * rho0 * delta T
    prop_names =  'mu        rho'
    prop_values = '0.0002         1'
  [../]
  [ins_mat]
    type = INSADTauMaterial
    velocity = velocity
    pressure = p
  []
[]