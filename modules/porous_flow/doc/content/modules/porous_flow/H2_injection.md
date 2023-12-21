# Hydrogen injection into underground water

## Problem statement

This problem is based on [!cite](OKOROAFOR2023117409). The injection of water into a porous media filled with water is modelled. The schematic is demonstrated in [schematicFig]. The experiment details are elaborated in the referred paper so will not be shown here to avoid repetition. The governing equations and associated `Kernels` that describe this problem are provided in detail [here](governing_equations.md).

!table id=datatable caption=Parameters of the problem [!citep](OKOROAFOR2023117409).
| Symbol | Quantity | Value | Units |
| --- | --- | --- | --- |
| $\phi$ | Porosity | $0.12$ | $-$ |
| $k$ | Permeability | $1*10^{-13}$  | $m^2$ |
| $\mu$ | Viscosity ($T=20^oC$) | $1*10^{-3}$  | $J.Kg^{-1}.s^{-1}.m^{-1}$ |
| $g$ | Gravity | $9.81$  | $m.s^{2}$ |
| $T_0$ | Initial temperature | $50$  | $^oC$ |

!media media/porous_flow/H2_injection_schematic.png style=width:100%;margin-left:10px; caption=The experiment schematic [!citep](OKOROAFOR2023117409). id=schematicFig


## Input file setup

This section describes the input file syntax.

### Mesh

The first step is to set up the mesh. In this problem, a rectangular reservoir with a width of 5000 m and a depth of 100 m is simulated. The code block is provided below. The numbers of nodes in the X and Y directions are specified along with the dimension of the tank. The mesh is translated in the x direction by 0.1 m and revolved around the y direction to create a cylindrical reservoir with a well in the center.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Mesh

### Fluid properties

After the mesh has been specified, we need to provide the fluid properties that are used for this simulation. In our case, water and hydrogen gas properties are used.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=FluidProperties

### Variables declaration

Since we are focusing on the variation of hydrogen saturation in water due to injection, hydrogen saturation (`sat_H2`) and water porepressure (`pp_water`) are declared. Initial conditions are also applied with the hydrogen saturation set to 0 and hydrostatic pressure condition for water.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Variables

### Kernel declaration

This section describes the physics we need to solve. To do so, some kernels are declared. In MOOSE, the required kernels depend on the terms in the governing equations. For this problem, four kernels were declared. To have a better understanding, users are recommended to visit [this page](governing_equations.md). The code block is shown below.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Materials

### Material setup

Additional material properties are required , which are declared here:

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Materials

### Boundary Conditions

The next step is to supply the boundary conditions. For this problem, there are three boundary conditions that we need to supply. The first one is the injection condition for hydrogen at the left boundary. And, the other two are for the free outflow of water and hydrogen at the right boundary.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=BCs

### Controls

Since we only inject hydrogen for the first year in the total simulation time of two years, we need to implement the control code block to disable the injection boundary condition at the desired time specified by the `time_condition` function.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Controls

### Function declaration

As aforementioned, we need to specify two functions to calculate the injection area and the time condition for the boundary condition. They are declared in this code block.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Functions

### Executioner setup

For this problem, a transient solver is required.
To save time and computational resources, [`IterationAdaptiveDT`](IterationAdaptiveDT.md) was implemented. This option enables the time step to be increased if the solution converges and decreased if it does not. Thus, this will help save time if a large time step can be used and aid in convergence if a small time step is required. For practice, users can try to disable it by putting the code block into comment and witnessing the difference in the solving time and solution.

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=Executioner

### Auxilary kernels and variables (optional)

This section introduces some auxvariable and auxkernels. Some variables are optional since they will not affect the calculation of the primary variables (`water_density`, `H2_density`, `pp_H2`, `sat_water`) and are solved by auxkernels. The remains are additional variables required by the solver but are not our interest (`massfrac_ph0_sp0`, `massfrac_ph1_sp0`).

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=AuxVariables

!listing modules/porous_flow/examples/H2_injection/H2_injection.i block=AuxKernels

## Result

The input file can be executed and the result is as follows:


!media media/porous_flow/H2_injection_vid.mp4 style=width:100%;margin-left:10px; caption= Evolution of $H_2$ saturation in water with a test time of 2 years. id=Sat_twoyears_vid

!media media/porous_flow/H2_injection_last_frame.png style=width:100%;margin-left:10px; caption=$H_2$ saturation in water at the end of the test. id=Sat_twoyears_last_frame

!media media/porous_flow/sat_over_time.png style=width:100%;margin-left:10px; caption=$H_2$ saturation at two different locations over time. id=Sat_two_location

It can be seen that MOOSE was able to capture significant behaviours of the flow. Initially the $H_2$ saturation is uniform across the $y$ axis. However later on, due to the effect of gravity, $H_2$ has been pushed to the top as it is a light gas forming a higher saturation region in this area. After one year, the injection stops. the low saturation region becomes smaller as more $H_2$ convects to the top layer.


The result from the simulation agrees well with the published literature.

!media media/porous_flow/H2_injection_contour_benchmark.png style=width:100%;margin-left:10px; caption=Gas saturation distribution contour over time using different codes [!citep](OKOROAFOR2023117409). id=past_result_contour


!media media/porous_flow/H2_injection_space_over_time.png style=width:100%;margin-left:10px; caption=Gas saturation distribution over time at two locations using different codes [!citep](OKOROAFOR2023117409). id=past_result_2places

## Viscous fingering

Viscous fingering is an undesired phenomenon that happens when gas is injected into water storage with a non-uniform permeability medium which creates the finger-shape pattern of the gas saturation contour [!cite](Feldmann2016). To capture this behaviour, we will modify the above input file following the below schematic. All the parameters are the same as [datatable] except the permeability in the red boxes is half of the surrounding domain.

!media media/porous_flow/H2_fingering_schematic.png style=width:100%;margin-left:10px; caption=Schematic of the viscous fingering simulation. id=schematic_vis_fing

## Simulation setup

Since the problem is based on the previous problem input file, only the change will be demonstrated.

### Mesh setup

Firstly, we need to modify the mesh to introduce the three boxes into the domain with a size of $20 m * 100 m$ each.

!listing modules/porous_flow/examples/H2_injection/H2_fingering.i block=Mesh

### Physic setup

After the boxes are introduced, we can specify different pearmeability values to them and the outer domain.

!listing modules/porous_flow/examples/H2_injection/H2_fingering.i block=Materials

To aid in the visualization, gravity has been deactivated so that $H_2$ will not float to the top of the domain as shown in the previous problem.

!listing modules/porous_flow/examples/H2_injection/H2_fingering.i block=GlobalParams

## Result

The development of gas saturation in the reservoir is shown below. As expected, the gas saturation contour forms a finger pattern due to the presence of regions with permeability anomalies. The lower permeability acts as an obstruction to the gas movement resulting in the lower saturation at the aft of them compared to the surrounding. This behaviour was accurately captured by MOOSE indicating the software's capabilities in simulating such complex flows.


!media media/porous_flow/H2_fingering_vid.mp4 style=width:100%;margin-left:10px; caption= Formation of the fingering pattern in gas saturation contour. id=Sat_twoyears_vid_finger



