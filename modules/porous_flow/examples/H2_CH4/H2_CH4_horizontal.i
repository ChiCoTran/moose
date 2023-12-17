time = 2.592e6

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    xmin = 0
    xmax = 100
    ny = 40
    ymin = -500
    ymax = -400
  []

  [left_box]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x >= -1 & x <= 48'
    block_id = 1
    block_name = left_box
  []

  [mid_box]
    type = ParsedSubdomainMeshGenerator
    input = left_box
    combinatorial_geometry = 'x > 48 & x <= 52'
    block_id = 2
    block_name = mid_box
  []

  [right_box]
    type = ParsedSubdomainMeshGenerator
    input = mid_box
    combinatorial_geometry = 'x > 52 & x <= 100'
    block_id = 3
    block_name = right_box
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pp_H2]
  []

  [mass_frac_CH4]
  []
[]

[AuxVariables]
  [density]
    family = MONOMIAL
    order = FIRST
  []
[]

[Kernels]
  [mass_H2]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = pp_H2
  []

  [adv_H2]
    type = PorousFlowFullySaturatedDarcyFlow
    variable = pp_H2
    fluid_component = 1
  []

  [diff_H2]
    type = PorousFlowDispersiveFlux
    fluid_component = 1
    variable = pp_H2
    disp_trans = 0
    disp_long = 0
  []

  [mass_CH4]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = mass_frac_CH4
  []

  [adv_CH4]
    type = PorousFlowFullySaturatedDarcyFlow
    fluid_component = 0
    variable = mass_frac_CH4
  []

  [diff_CH4]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = mass_frac_CH4
    disp_trans = 0
    disp_long = 0
  []

[]

[AuxKernels]
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density
    phase = 0
    execute_on = 'initial timestep_end'
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pp_H2 mass_frac_CH4'
    number_fluid_phases = 1
    number_fluid_components = 2
  []
[]

[FluidProperties]
  [H2]
    type = HydrogenFluidProperties
  []
  [CH4]
    type = MethaneFluidProperties
  []
[]

[Materials]
  [ps]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pp_H2
  []

  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []

  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1E-14 0 0   0 1E-14 0   0 0 1E-14'
  []

  [H2]
    type = PorousFlowMultiComponentGasMixture
    fp = 'CH4 H2'
    x = 'mass_frac_CH4'
    phase = 0
  []

  [massfrac]
    type = PorousFlowMassFraction
    mass_fraction_vars = mass_frac_CH4
  []

  [temperature]
    type = PorousFlowTemperature
    temperature = 323
  []

  [diff]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0.00000726 0.00000726'
    tortuosity = 1
  []

  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 0
  []

[]

[ICs]
  # [mass_frac_CH4]
  #   type = BoundingBoxIC
  #   x1 = 0
  #   x2 = 50
  #   y1 = -500
  #   y2 = -400
  #   variable = mass_frac_CH4
  #   inside = 1
  #   outside = 0.1
  #   # type = MultiBoundingBoxIC
  #   # corners = '0 -500 0   48.5 -500 0   51.5 -500 0'
  #   # opposite_corners = '48.5 -400 0   51.5 -400 0   100 -400 0'
  #   # inside = '1.0 0.5 0'
  #   # variable = mass_frac_CH4
  # []

  [mass_frac_CH4_left]
    type = ConstantIC
    value = 1
    variable = mass_frac_CH4
    block = left_box
  []

  [mass_frac_CH4_mid]
    type = FunctionIC
    function = '(52-x)/(52-48)'
    variable = mass_frac_CH4
    block = mid_box
  []

  [mass_frac_CH4_right]
    type = ConstantIC
    value = 0
    variable = mass_frac_CH4
    block = right_box
  []

  [pressure]
    type = ConstantIC
    variable = pp_H2
    value = 4e6
  []

  # [pressure_left]
  #   type = FunctionIC
  #   variable = pp_H2
  #   function = '4e6+9.81*25*(-400-y)'
  #   block = left_box
  # []

  # [pressure_mid]
  #   type = FunctionIC
  #   variable = pp_H2
  #   function = '4e6+9.81*25*(-400-y)'
  #   block = mid_box
  # []

  # [pressure_right]
  #   type = FunctionIC
  #   variable = pp_H2
  #   function = '4e6+9.81*2.9*(-400-y)'
  #   block = right_box
  # []
[]

[BCs]
  # [constant_porepressure]
  #   type = DirichletBC
  #   variable = pp_H2
  #   value = 4e6
  #   boundary = 'top'
  # []
[]

[Preconditioning]
  [basic]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      lu           NONZERO                   2'
  []
[]

[Executioner]
  type = Transient
  end_time = ${time}
  dtmax = 5e4
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-8
  l_max_its = 500
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1000
  []
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<1e5, 5e3, if(t < 2e5, 1e4, if(t<1e6,5e4,if(t<5e6,1e5,2e6))))'

  # []
[]

[VectorPostprocessors]
  [mid_line_density]
    type = LineValueSampler
    start_point = '0 -450 0.0'
    end_point = '100 -450 0.0'
    variable = density
    sort_by = x
    num_points = 500
  []

  [mid_line_mass_frac_CH4]
    type = LineValueSampler
    start_point = '0 -450 0.0'
    end_point = '100 -450 0.0'
    variable = mass_frac_CH4
    sort_by = x
    num_points = 500
  []
[]

[Outputs]
  sync_times = '1 86400 2.592e6 31.536e6 157.680e6 '
  file_base = H2_CH4_horizontal_${time}

  [density_mid_output]
    type = CSV
    sync_only = true
  []
  exodus = true
[]
