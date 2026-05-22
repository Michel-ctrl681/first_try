mu = 0.001
rho = 1000
k = 0.6
cp = 4180
alpha_b = 2.1e-4
velocity_interp_method = 'rc'
advected_interp_method = 'average'
T_cold = 333.15
T_hot = 343.15
T_ref = 338.15

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = vel_x
    v = vel_y
    pressure = pressure
  []
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  nx = 128
  ny = 128
[]

[Variables]
  [vel_x]
    type = INSFVVelocityVariable
  []
  [vel_y]
    type = INSFVVelocityVariable
  []
  [pressure]
    type = INSFVPressureVariable
  []
  [T]
    type = INSFVEnergyVariable
    initial_condition = '${T_ref}'
  []
  [lambda]
    family = SCALAR
    order = FIRST
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
  []
  [mean_zero_pressure]
    type = FVIntegralValueConstraint
    variable = pressure
    lambda = lambda
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
  []
  [u_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_x
    T_fluid = T
    gravity = '0 -9.81 0'
    rho = '${rho}'
    ref_temperature = ${T_ref}
    momentum_component = 'x'
  []
  [u_gravity]
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 -9.81 0'
    rho = '${rho}'
    momentum_component = 'x'
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
  []
  [v_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T
    gravity = '0 -9.81 0'
    rho = '${rho}'
    ref_temperature = ${T_ref}
    momentum_component = 'y'
  []
  [v_gravity]
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -9.81 0'
    rho = '${rho}'
    momentum_component = 'y'
  []

  # 能量方程对流项：ρ*cp * (u·∇)T
  [T_advection]
    type = INSFVEnergyAdvection
    variable = T
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
  []

  # 能量方程扩散项：∇·(k ∇T)
  [T_diffusion]
    type = FVDiffusion
    variable = T
    coeff = 'k'
  []
[]

[FVBCs]
  [top_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'top'
    function = 0
  []

  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'left right bottom'
    function = 0
  []

  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'left right top bottom'
    function = 0
  []

  [hot_wall]
    type = FVDirichletBC
    variable = T
    value = '${T_hot}'
    boundary = 'left'
  []
  [cold_wall]
    type = FVDirichletBC
    variable = T
    value = '${T_cold}'
    boundary = 'right'
  []
[]

[FunctorMaterials]
  [const_functor]
    type = ADGenericFunctorMaterial
    prop_names = 'mu rho k cp alpha_b'
    prop_values = '${mu} ${rho} ${k} ${cp} ${alpha_b}'
  []

  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    rho = ${rho}
    temperature = 'T'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'

  nl_abs_tol = 1e-4
  nl_rel_tol = 1e-2
  nl_max_its = 50

  # 伪瞬态: 小dt提供数值阻尼, dt逐步增大直到稳态
  dt = 1e-4
  dtmax = 1e4
  end_time = 1e6
  steady_state_detection = true
  steady_state_tolerance = 1e-4

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    growth_factor = 2.0
    dt = 1e-4
  []

  [TimeIntegrator]
    type = BDF2
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Debug]
  show_var_residual_norms = true
[]
