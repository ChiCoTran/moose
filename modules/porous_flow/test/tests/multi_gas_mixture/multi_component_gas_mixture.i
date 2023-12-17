time = 10

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    xmin = -50
    xmax = 50
    ny = 10
    ymin = -100
    ymax = 0
  []
  [left_box]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x >= -50 & x <= 0'
    block_id = 1
    block_name = left_box
  []
  [right_box]
    type = ParsedSubdomainMeshGenerator
    input = left_box
    combinatorial_geometry = 'x >0  & x <= 50'
    block_id = 2
    block_name = right_box
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pp_CO2]
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
  [mass_CO2]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = pp_CO2
  []
  [adv_CO2]
    type = PorousFlowFullySaturatedDarcyFlow
    variable = pp_CO2
    fluid_component = 1
  []
  [diff_CO2]
    type = PorousFlowDispersiveFlux
    fluid_component = 1
    variable = pp_CO2
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
    porous_flow_vars = 'pp_CO2 mass_frac_CH4'
    number_fluid_phases = 1
    number_fluid_components = 2
  []
[]

[FluidProperties]
  [CO2]
    type = CO2FluidProperties
  []
  [CH4]
    type = MethaneFluidProperties
  []
[]

[Materials]
  [ps]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pp_CO2
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1E-14 0 0   0 1E-14 0   0 0 1E-14'
  []
  [CO2]
    type = PorousFlowMultiComponentGasMixture
    fp = 'CH4 CO2'
    x = mass_frac_CH4
    phase = 0
  []
  [massfrac]
    type = PorousFlowMassFraction
    mass_fraction_vars = mass_frac_CH4
  []

  [temperature]
    type = PorousFlowTemperature
    temperature = 313
  []
  [diff]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '1e-7 1e-7'
    tortuosity = 1
  []
  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 0
  []
[]

[ICs]
  [mass_frac_CH4_bot]
    type = ConstantIC
    variable = mass_frac_CH4
    value = 0
    block = left_box
  []
  [mass_frac_CH4_top]
    type = ConstantIC
    variable = mass_frac_CH4
    value = 1
    block = right_box
  []
  [pressure]
    type = ConstantIC
    variable = pp_CO2
    value = 4e6
  []
[]

[BCs]
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
  dtmax = 1e7
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-8
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1000
  []
[]

[Outputs]
  file_base = multi_component_gas_mixtur_${time}
  exodus = true
[]
