import matplotlib.pyplot as plt
import numpy as np
import math as mt


# Read MOOSE simulation data
H2CSV = np.genfromtxt('H2_injection_out.csv', delimiter = ',', names = True, dtype = float)

ylim=[-0.01, 0.9]
xlim=[0, 600]

plt.figure(0)
plt.plot(np.array(H2CSV['time'])/(3600*24), np.array(H2CSV['sat_H2_top']),'-' , label = 'MOOSE ($x=500m, y=0m$)')
plt.plot(np.array(H2CSV['time'])/(3600*24), np.array(H2CSV['sat_H2_mid']),'--' , label = 'MOOSE ($x=500m, y=-50m$)')

plt.grid()
plt.xlabel('Time (Days)')
plt.ylabel('$H_2$ Saturation')
plt.legend()
plt.ylim(ylim)
plt.tight_layout()
plt.xlim(xlim)
plt.savefig("sat_over_time.png")



