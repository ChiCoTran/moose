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
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pp_H2]
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
    fluid_component = 0
    variable = pp_H2
  []

  [adv_H2]
    type = PorousFlowFullySaturatedDarcyFlow
    variable = pp_H2
    fluid_component = 0
  []

  [diff_H2]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = pp_H2
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
    porous_flow_vars = 'pp_H2'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[FluidProperties]
  [H2]
    type = HydrogenFluidProperties
  []
[]

[Materials]
  [ps]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pp_H2
  []

  [mass_frac]
    type = PorousFlowMassFraction
    mass_fraction_vars = ''
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
    type = PorousFlowSingleComponentFluid
    fp = H2
    phase = 0
  []

  [temperature]
    type = PorousFlowTemperature
    temperature = 323
  []

  [diff]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0.00000726'
    tortuosity = 1
  []

  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 1
    phase = 0
  []

[]

[ICs]

  [pressure]
    type = ConstantIC
    variable = pp_H2
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
  dtmax = 1e5
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-8
  l_max_its = 500
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1000
  []
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

[]

[Outputs]
  sync_times = '10'
  file_base = test_${time}

  [density_mid_output]
    type = CSV
    sync_only = true
  []
  exodus = true
[]
