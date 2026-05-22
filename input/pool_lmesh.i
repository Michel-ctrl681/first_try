mu = 0.001
rho = 1000
k = 0.6
cp = 4180
alpha_b = 2.1e-4
velocity_interp_method = 'rc'
advected_interp_method = 'quick'
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

  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_x
    rho = ${rho}
    momentum_component = 'x'
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

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_y
    rho = ${rho}
    momentum_component = 'y'
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

  # 能量方程瞬态项：ρ*cp * ∂T/∂t
  [T_time]
    type = INSFVEnergyTimeDerivative
    variable = T
    rho = ${rho}
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

  end_time = 200
  dtmax = 2.0

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_max_its = 20

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    growth_factor = 1.2
    dt = 0.01
  []

  [TimeIntegrator]
    type = BDF2
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
[]