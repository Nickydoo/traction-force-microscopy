import numpy as np
import matplotlib.pyplot as plt
import scipy.ndimage as nd
import matplotlib.ticker as tkr



def numfmt(x, pos):
    s = "{}".format(x / 2)
    return s

fmt = tkr.FuncFormatter(numfmt)
resolution = 1608*2
x = np.random.randint(low=0, high=resolution, size=resolution)
y = np.random.randint(low=0, high=resolution, size=resolution)
mat = np.zeros((resolution, resolution))
mat[x, y] = 1
print(np.sum(mat))
mat2 = nd.gaussian_filter(mat, sigma=5.0, order=0)
fig, axes = plt.subplots(1, 2)
axes[0].imshow(mat, cmap="gray", interpolation="nearest")
axes[1].imshow(mat2, cmap="gray")
for i in range(len(axes)):
    axes[i].xaxis.set_major_formatter(fmt)
    axes[i].yaxis.set_major_formatter(fmt)
plt.show()
