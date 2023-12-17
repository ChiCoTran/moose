import matplotlib.pyplot as plt
import numpy as np
import math as mt



# Read MOOSE simulation data
day_1 = np.genfromtxt('H2_CH4_horizontal_test_linear_grad_step_157.680e6_mid_line_density_0019.csv', delimiter = ',', names = True, dtype = float)
day_1_2 = np.genfromtxt('H2_CH4_horizontal_86400_mid_line_density_0096.csv', delimiter = ',', names = True, dtype = float)
day_1_3 = np.genfromtxt('H2_CH4_horizontal_2.592e6_mid_line_density_0008.csv', delimiter = ',', names = True, dtype = float)
month_1 = np.genfromtxt('H2_CH4_horizontal_test_linear_grad_step_157.680e6_mid_line_density_0032.csv', delimiter = ',', names = True, dtype = float)
month_1_2 = np.genfromtxt('H2_CH4_horizontal_2.592e6_mid_line_density_0059.csv', delimiter = ',', names = True, dtype = float)
year_1 = np.genfromtxt('H2_CH4_horizontal_test_157.680e6_mid_line_density_0060.csv', delimiter = ',', names = True, dtype = float)
year_5 = np.genfromtxt('H2_CH4_horizontal_test_157.680e6_mid_line_density_0187.csv', delimiter = ',', names = True, dtype = float)



ylim=[-0.0001, 26]
xlim=[-0.5, 100.5]

plt.figure(0)

plt.plot(day_1['x'], np.array(day_1['density']),'mo' , markevery=10, label = '1 day')
plt.plot(day_1_2['x'], np.array(day_1_2['density']),'bo' , markevery=10, label = '1 day 2')
plt.plot(day_1_3['x'], np.array(day_1_3['density']),'go' , markevery=10, label = '1 day 3')
# plt.plot(month_1['x'], np.array(month_1['density']),'ro' , markevery=10, label = '30 days')
# plt.plot(month_1_2['x'], np.array(month_1_2['density']),'go' , markevery=10, label = '30 days fine_small time step')
# plt.plot(year_1['x'], np.array(year_1['density']),'bo' , markevery=20, label = '1 year')
# plt.plot(year_5['x'], np.array(year_5['density']),'go' , markevery=20, label = '5 years')


plt.xlabel('$x$ (m)')
plt.ylabel('Density ($Kg/m^3)$')
plt.legend()
plt.ylim(ylim)
plt.tight_layout()
plt.xlim(xlim)
plt.grid()
plt.savefig("density_x.png")


