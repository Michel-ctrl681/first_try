temp_ref= 353.15

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 100
  []
  [./bottom_left]
    type = ExtraNodesetGenerator
    new_boundary = corner
    coord = '0 0'
    input = gen
  [../]
[]

[Preconditioning]
  [./PJFNK_SMP]
    type = SMP
    full = true
    solve_type = 'PJFNK'
  [../]
[]

[Executioner]
  type = Transient

  end_time = 10

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'
  
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    growth_factor = 1.2
    dt = 5e-4
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'timestep_end'
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
  []
  [p][]
  [temp]
    initial_condition = ${temp_ref}
    scaling = 1e-4
  []
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 0
    y_value = 0
    variable = velocity
  []
[]

[FVBCs]
  [./velocity_dirichlet]
    type = VectorDirichletBC
    boundary = 'left right bottom top'
    variable = velocity
    values = '0 0 0'
  [../]

  [./p_zero]
    type = DirichletBC
    boundary = corner
    variable = p
    value = 0
  [../]

  [./hot]
    type = DirichletBC
    variable = temp
    boundary = left
    value = 358.15
  [../]

  [./cold]
    type = DirichletBC
    variable = temp
    boundary = right
    value = 348.15
  [../]
[]

[Kernels]

  # ===== 连续方程 =====
  [./mass]
    type = INSADMass
    variable = p
  [../]

  [mass_pspg]
    type = INSADMassPSPG
    variable = p
  []

  # ===== 动量方程 =====
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

  [./buoyancy]
    type = INSADBoussinesqBodyForce
    variable = velocity
    temperature = temp
    gravity = '0 -9.81 0'
  [../]

  [./gravity]
    type = INSADGravityForce
    variable = velocity
    gravity = '0 -9.81 0'
  [../]

  [supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []

  # ===== 能量方程 =====
  [temp_time]
    type = INSADHeatConductionTimeDerivative
    variable = temp
  []

  [temp_advection]
    type = INSADEnergyAdvection
    variable = temp
  []

  [temp_conduction]
    type = ADHeatConduction
    variable = temp
    thermal_conductivity = 'k'
  [../]

  [temp_supg]
    type = INSADEnergySUPG
    variable = temp
    velocity = velocity
  []
[]

[Materials]
  [./ad_const]
    type = ADGenericConstantMaterial
    prop_names  = 'mu      rho     alpha     k        cp'
    prop_values = '1e-3    1000    2.1e-4   0.6      4180'
  [../]

  [./const]
    type = GenericConstantMaterial
    prop_names = 'temp_ref'
    prop_values = '${temp_ref}'
  [../]

  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = temp
  []
[]