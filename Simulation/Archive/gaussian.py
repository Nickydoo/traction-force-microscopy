import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

sigma_x = 10
sigma_y = 10
resolution = 1608

x_coords = np.random.uniform(low=0, high=resolution, size=resolution)
y_coords = np.random.uniform(low=0, high=resolution, size=resolution)
plt.scatter(x_coords, y_coords)
plt.show()
locs = np.array([x_coords, y_coords]).transpose()

my_range = np.arange(resolution)

x = np.linspace(0, resolution - 1, resolution)
y = np.linspace(0, resolution - 1, resolution)
X, Y = np.meshgrid(x, y, indexing="ij")
x_dist = (X - x_coords)**2
y_dist = (Y - y_coords)**2
Z = 100 * np.exp(-x_dist/(2 * sigma_x) - y_dist/(2 * sigma_y))
fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.pcolormesh(X, Y, Z)
plt.show()
