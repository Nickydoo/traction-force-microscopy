from pyTFM.TFM_functions import calculate_deformation, TFM_tractions
import numpy as np
from pyTFM.plotting import show_quiver
from synthetic_image import gen_img
import matplotlib.pyplot as plt

before_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well001_GS.bmp"
after_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well002.png"
im1 = plt.imread(before_image_path).astype(np.int32)
im2 = plt.imread(after_image_path).astype(np.int32)


u, v, mask_val, mask_std = calculate_deformation(im1, im2, window_size=100, overlap=60)

fig1, ax = show_quiver(u, v)
plt.show()

ps1 = 0.12  # pixel size of the image of the beads
im1_shape = (1608, 1608)  # dimensions of the image of the beads
ps2 = ps1 * np.mean(np.array(im1_shape) / np.array(u.shape))  # pixel size of of the deformation field
young = 49000  # Young's modulus of the substrate in Pa
sigma = 0.49  # Poisson's ratio of the substrate
h = "infinite"  # height of the substrate in µm, "infinite" is also accepted
tx, ty = TFM_tractions(u, v, pixelsize1=ps1, pixelsize2=ps2, h=h, young=young, sigma=sigma)
fig2, ax = show_quiver(tx, ty)
plt.show()