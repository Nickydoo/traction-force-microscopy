# Import all necessary libraries
import numpy as np
import matplotlib.pyplot as plt
from skimage import io
from DisplacementTracking import get_displacements
from utils import load_files, correct_shift, filter_for_tfm, bandpass
from PlottingFunctions import display_vector_field, display_heatmap
from TractionCalculation import fttc, contractility, strain_energy
from skimage.transform import resize
from roipoly import RoiPoly
# Constants
pixel_size = 0.12  # micron per pixel
pixel_size *= 1e-6  # meter per pixel
window_size = 50

# Load images

before_image = io.imread(r"C:\Example Directory\Image1.tif")
cell_image = io.imread(r"C:\Example Directory\cellImage.tif")
after_image = io.imread(r"C:\Example Directory\Image2.tif")
print(
    f"Make sure that the shapes match:\nBefore image has shape {before_image.shape}\nAfter image has shape"
    f" {after_image.shape}")

# Filter images

print("Filtering images")
before_image = bandpass(before_image, 1, 6)
after_image = bandpass(after_image, 1, 6)
print("Filtering done")

# Check to see if images look okay

plt.subplot(121)
plt.imshow(before_image, cmap="gray")
plt.subplot(122)
plt.imshow(after_image, cmap="gray")
plt.show()

# Correct stage drift

before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
print("Stage drift corrected")
print(f"Shapes after drift correction are:\nBefore: {before_image.shape}, After: {after_image.shape}")
print("Finding displacements...")

# Find displacements

displacement_dict = get_displacements(before_image, after_image, window_size, int(0.75 * window_size))
print("Found displacements")

# Displacement data is returned in a dictionary, has to be unpacked as below

x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]

# Show quiver plot of displacements, overlaid on beads

display_vector_field(x, y, u, v, window_size, image=before_image)
plt.show()

# Calculate "new" pixel size to be used finding tractions

ps_new = pixel_size*np.mean(np.array(after_image.shape) / np.array(u.shape))

# Find tractions

print("Finding tractions...")
tx, ty = fttc(u, v, 2400, 0.49, pixel_size, ps_new)
print("Found tractions")

# Show vector field overlaid on cell image. Notice optional colormap argument is used here

display_vector_field(x, y, tx, ty, window_size, image=cell_image, cmap="viridis")
plt.show()

# Resize cell image to same size as displacement field, and then draw a mask using RoiPoly

print(f'u has shape {u.shape}')
print(f'v has shape {v.shape}')
small_cell = resize(cell_image, u.shape)
plt.imshow(small_cell)
my_roi = RoiPoly(color="red")
plt.show()
my_mask = my_roi.get_mask(small_cell)

# Calculate traction and displacement vector magnitudes

traction_mags = np.sqrt(tx**2 + ty**2)
disp_mags = np.sqrt(u**2 + v**2)

# Can look at a heatmap plot like this:

plt.imshow(traction_mags, cmap="jet", interpolation="bilinear")
plt.show()

# Calculate strain energy, contractility, etc and print

strain_energy = strain_energy(u, v, tx, ty, pixel_size, ps_new, my_mask)
contforce = contractility(x, y, tx, ty, ps_new, my_mask)
avg_displacements = np.average(disp_mags[my_mask])
avg_traction = np.average(traction_mags[my_mask])
median_displacements = np.median(disp_mags[my_mask])
mask_area = np.sum(my_mask) * ps_new**2
print(f'average traction is {avg_traction} Pa')
print(f'average force is {avg_traction * mask_area} newtons')
print(f'strain energy is {strain_energy*10e12} picojoules')
print(f'average displacement is {avg_displacements} pixels or {ps_new*avg_displacements} microns')
print(f'median displacement is {median_displacements} pixels or {ps_new*median_displacements} microns')
print(f'contractility is {contforce} newtons')