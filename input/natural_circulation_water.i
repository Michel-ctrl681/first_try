# ============================================================
# 方腔自然循环流 - 有限体积法 (FV)
# 工质: 水 (Boussinesq近似)
# Rayleigh数 ~ O(10^5), 40x40网格平衡精度与效率
# ============================================================

# 水物性参数 (参考温度 ~350K)
rho = 998.0        # 密度 [kg/m³]
mu = 1.0e-3        # 动力粘度 [Pa·s]
k = 0.6            # 热导率 [W/(m·K)]
cp = 4182.0        # 比热容 [J/(kg·K)]
alpha_b = 2.1e-4   # 体积膨胀系数 [1/K]
T_hot = 358.15     # 热壁温度 [K] (85°C)
T_cold = 348.15    # 冷壁温度 [K] (75°C)
T_ref = 353.15     # 参考温度 [K] (80°C)
gravity = 9.81     # 重力加速度 [m/s²]

velocity_interp_method = 'rc'
advected_interp_method = 'upwind'

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
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 40
    xmin = 0
    xmax = 1.0
    ymin = 0
    ymax = 1.0
  []
  [corner]
    type = ExtraNodesetGenerator
    new_boundary = corner
    coord = '0 0'
    input = gen
  []
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
    initial_condition = ${T_ref}
  []
  [lambda]
    family = SCALAR
    order = FIRST
  []
[]

[FVKernels]
  # ===== 连续方程 =====
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

  # ===== X方向动量方程 =====
  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_diffusion]
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

  # ===== Y方向动量方程 =====
  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_diffusion]
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

  # ===== 浮力项 (Boussinesq近似) =====
  [u_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_x
    T_fluid = T
    rho = ${rho}
    ref_temperature = ${T_ref}
    gravity = '0 -${gravity} 0'
    momentum_component = 'x'
  []
  [u_gravity]
    type = INSFVMomentumGravity
    variable = vel_x
    rho = ${rho}
    gravity = '0 -${gravity} 0'
    momentum_component = 'x'
  []
  [v_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T
    rho = ${rho}
    ref_temperature = ${T_ref}
    gravity = '0 -${gravity} 0'
    momentum_component = 'y'
  []
  [v_gravity]
    type = INSFVMomentumGravity
    variable = vel_y
    rho = ${rho}
    gravity = '0 -${gravity} 0'
    momentum_component = 'y'
  []

  # ===== 能量方程 =====
  [T_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []
  [T_diffusion]
    type = FVDiffusion
    variable = T
    coeff = ${k}
  []
[]

[FVBCs]
  # 速度边界条件 - 四壁无滑移
  [no_slip_x]
    type = INSFVNoSlipWallBC
    variable = vel_x
    boundary = 'left right top bottom'
    function = 0
  []
  [no_slip_y]
    type = INSFVNoSlipWallBC
    variable = vel_y
    boundary = 'left right top bottom'
    function = 0
  []

  # 温度边界条件 - 左热右冷 (差分加热)
  [T_hot]
    type = FVDirichletBC
    variable = T
    boundary = left
    value = ${T_hot}
  []
  [T_cold]
    type = FVDirichletBC
    variable = T
    boundary = right
    value = ${T_cold}
  []
[]

[FunctorMaterials]
  [fluid_props]
    type = ADGenericFunctorMaterial
    prop_names = 'mu rho k cp alpha_b'
    prop_values = '${mu} ${rho} ${k} ${cp} ${alpha_b}'
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_max_its = 50
[]

[Outputs]
  [exodus]
    type = Exodus
    execute_on = 'FINAL'
  []
[]

[Postprocessors]
  [max_vel_x]
    type = ElementExtremeValue
    variable = vel_x
    value_type = max
  []
  [max_vel_y]
    type = ElementExtremeValue
    variable = vel_y
    value_type = max
  []
  [max_T]
    type = ElementExtremeValue
    variable = T
    value_type = max
  []
  [min_T]
    type = ElementExtremeValue
    variable = T
    value_type = min
  []
[]
