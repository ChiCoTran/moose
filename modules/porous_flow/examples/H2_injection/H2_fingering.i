[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    xmin = 0
    xmax = 3000
    ny = 20
    ymin = 0
    ymax = 100
  []

  [translate]
    type = TransformGenerator
    transform = TRANSLATE
    vector_value = '0.1 0 0'
    input = gen
  []

  [perm_anomal_box]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '-0.1 40 0'
    top_right = '100 60 0'
    input = translate
  []

  [perm_anomal_box2]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '-0.1 10 0'
    top_right = '100 30 0'
    input = perm_anomal_box
  []

  [perm_anomal_box3]
    type = SubdomainBoundingBoxGenerator
    block_id = 3
    bottom_left = '-0.1 70 0'
    top_right = '100 90 0'
    input = perm_anomal_box2
  []

  [rename]
    type = RenameBlockGenerator
    old_block = '0 1 2 3'
    new_block = 'outter_box perm_box perm_box perm_box'
    input = 'perm_anomal_box3'
  []

  coord_type = RZ
  rz_coord_axis = Y
  uniform_refine = 1
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
  temperature_unit = Celsius
[]

[Variables]
  [pp_water]
    [InitialCondition]
      type = FunctionIC
      variable = pp_water
      function = '12e6'
    []
  []
  [sat_H2]
    initial_condition = 0
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = 50
  []
  [water_density]
    family = MONOMIAL
    order = CONSTANT
  []
  [H2_density]
    family = MONOMIAL
    order = CONSTANT
  []
  [massfrac_ph0_sp0]
    initial_condition = 1
  []
  [massfrac_ph1_sp0]
    initial_condition = 0
  []
  [pp_H2]
    family = MONOMIAL
    order = CONSTANT
  []
  [sat_water]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[Kernels]
  [mass_water]
    type = PorousFlowMassTimeDerivative
    variable = pp_water
  []
  [flux_water]
    type = PorousFlowAdvectiveFlux
    variable = pp_water
  []
  [mass_H2]
    type = PorousFlowMassTimeDerivative
    variable = sat_H2
    fluid_component = 1
  []
  [flux_H2]
    type = PorousFlowAdvectiveFlux
    variable = sat_H2
    fluid_component = 1
  []
[]

[AuxKernels]
  [water_density]
    type = PorousFlowPropertyAux
    property = density
    variable = water_density
    execute_on = 'initial timestep_end'
  []
  [H2_density]
    type = PorousFlowPropertyAux
    property = density
    variable = H2_density
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [pp_H2]
    type = PorousFlowPropertyAux
    property = pressure
    phase = 1
    variable = pp_H2
    execute_on = 'initial timestep_end'
  []
  [sat_water]
    type = PorousFlowPropertyAux
    property = saturation
    variable = sat_water
    execute_on = 'initial timestep_end'
  []
[]

[BCs]
  [H2_injection]
    type = PorousFlowSink
    boundary = left
    variable = sat_H2
    flux_function = injection_rate
    fluid_phase = 1
  []
  [free_outflow_water]
    type = PorousFlowOutflowBC
    variable = pp_water
    boundary = right
  []
  [free_outflow_H2]
    type = PorousFlowOutflowBC
    variable = sat_H2
    boundary = right
  []
[]

[Functions]
  [injection_rate]
    type = ParsedFunction
    symbol_values = injection_area
    symbol_names = area
    expression = '-5/area'
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pp_water sat_H2'
    number_fluid_phases = 2
    number_fluid_components = 2
  []
  [pc]
    type = PorousFlowCapillaryPressureConst
    pc = 0
  []
[]

[FluidProperties]
  [Water]
    type = Water97FluidProperties
  []
  [H2]
    type = HydrogenFluidProperties
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
    temperature = temperature
  []
  [ps]
    type = PorousFlow2PhasePS
    phase0_porepressure = pp_water
    phase1_saturation = sat_H2
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
    mass_fraction_vars = 'massfrac_ph0_sp0 massfrac_ph1_sp0'
  []
  [H2]
    type = PorousFlowSingleComponentFluid
    fp = H2
    phase = 1
  []
  [water]
    type = PorousFlowSingleComponentFluid
    fp = Water
    phase = 0
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.12
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0 0 1e-13 0  0 0 1e-13'
    block = outter_box
  []

  [anomaly_permeability]
    type = PorousFlowPermeabilityConst
    permeability = '5e-14 0 0 0 5e-14 0  0 0 5e-14'
    block = perm_box
  []
  [relperm_Water]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
    s_res = 0.2
    sum_s_res = 0.3
  []
  [relperm_H2]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 1
    s_res = 0.1
    sum_s_res = 0.3
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = ' asm      lu           NONZERO'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  end_time = 6e7
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-4
  nl_max_its = 20
  dtmax = 1e6
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
  []
  # [Adaptivity]
  #   interval = 1
  #   refine_fraction = 0.2
  #   coarsen_fraction = 0.3
  #   #max_h_level = 4
  # []
[]

[Postprocessors]
  [sat_H2_top]
    type = PointValue
    point = '500 50 0'
    variable = sat_H2
  []
  [injection_area]
    type = AreaPostprocessor
    boundary = left
    execute_on = initial
  []
[]

[Outputs]
  execute_on = 'initial timestep_end'
  exodus = true
  csv = true
[]
