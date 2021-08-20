import numpy as np
import matplotlib.pyplot as plt
from skimage import io
from DisplacementTracking import get_displacements
from scipy.ndimage.filters import median_filter
from utils import load_files, correct_shift, filter_for_tfm, bandpass
from PlottingFunctions import display_vector_field, display_heatmap
from TractionCalculation import fttc, contractility, strain_energy
from skimage.transform import resize
from roipoly import RoiPoly

pixel_size = 0.12  # micron per pixel
pixel_size *= 1e-6  # meter per pixel

before_image_both = io.imread(r"D:\Sam\July 20\1 close crop cell and beads.tif")
after_image_both = io.imread(r"D:\Sam\July 20\2 close crop cell and beads.tif")
before_image = before_image_both[0]
after_image = after_image_both[0]
cell_image = after_image_both[1]
print(
    f"Make sure that the shapes match:\nBefore image has shape {before_image.shape}\nAfter image has shape"
    f" {after_image.shape}")
print("Filtering images")
before_image = bandpass(before_image, 1, 6)
after_image = bandpass(after_image, 1, 6)
print("Filtering done")
plt.subplot(121)
plt.imshow(before_image, cmap="gray")
plt.subplot(122)
plt.imshow(after_image, cmap="gray")
plt.show()
before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
print("Stage drift corrected")
print(f"Shapes after drift correction are:\nBefore: {before_image.shape}, After: {after_image.shape}")
window_size = 50
print("Finding displacements...")
displacement_dict = get_displacements(before_image, after_image, window_size, int(0.8 * window_size))
print("Found displacements")
x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
display_vector_field(x, y, u, v, window_size, image=before_image)
plt.show()
print("Finding tractions...")
ps_new = pixel_size*np.mean(np.array(after_image.shape) / np.array(u.shape))
tx, ty = fttc(u, v, 2400, 0.49, pixel_size, ps_new)
print("Found tractions")
display_vector_field(x, y, tx, ty, window_size, image=cell_image, cmap="viridis")
plt.show()
print(f'u has shape {u.shape}')
print(f'v has shape {v.shape}')
small_cell = resize(cell_image, u.shape)
plt.imshow(small_cell)
my_roi = RoiPoly(color="red")
plt.show()
my_mask = my_roi.get_mask(small_cell)
big_tx = resize(tx, before_image.shape)
big_ty = resize(tx, before_image.shape)
magnitudes = np.sqrt(big_tx**2 + big_ty**2)
small_mags = np.sqrt(tx**2 + ty**2)
disp_mags = np.sqrt(u**2 + v**2)
plt.imshow(magnitudes, interpolation="nearest", cmap="jet")
plt.show()
plt.imshow(small_mags, cmap="jet", interpolation="bilinear")
plt.show()
strain_energy = strain_energy(u, v, tx, ty, pixel_size, ps_new, my_mask)
contforce = contractility(x, y, tx, ty, ps_new, my_mask)
avg_displacements = np.average(disp_mags[my_mask])
avg_traction = np.average(small_mags[my_mask])
median_displacements = np.median(disp_mags[my_mask])
mask_area = np.sum(my_mask) * ps_new**2
print(f'average traction is {avg_traction} Pa')
print(f'average force is {avg_traction * mask_area} newtons')
print(f'strain energy is {strain_energy*10e12} picojoules')
print(f'average displacement is {avg_displacements} pixels or {0.12*avg_displacements} microns')
print(f'median displacement is {median_displacements} pixels or {0.12*median_displacements} microns')
print(f'contractility is {contforce} newtons')