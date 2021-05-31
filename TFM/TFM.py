import numpy as np
import matplotlib.pyplot as plt
import cv2
from DisplacementTracking import get_displacements
from TractionCalculation import reg_fttc, strain_energy_points, total_strain_energy
from PlottingFunctions import vector_plot, process_mask
before_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well001_GS.bmp"
after_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well002_GS.bmp"
before_image = plt.imread(before_image_path).astype(np.int32)
after_image = plt.imread(after_image_path).astype(np.int32)
both = cv2.add(before_image, after_image)
plt.subplot(131)
plt.imshow(before_image, cmap="gray")
plt.title("Before")
plt.subplot(132)
plt.imshow(after_image, cmap="gray")
plt.title("After")
plt.subplot(133)
plt.imshow(both, cmap="gray")
plt.title("Overlay")
plt.show()
displacement_dict = get_displacements(before_image, after_image, 100, 60)
u, v = displacement_dict["u"], displacement_dict["v"]
fig, ax = vector_plot(u, v)
plt.show()
tx, ty = reg_fttc(u, v, 1, 4000, 0.49, 0.12, False)
e_arr = strain_energy_points(u, v, tx, ty, 0.12)
mask = plt.imread(r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\cells-middle well001_cp_masks.png")\
    .astype(bool)
mask = process_mask(mask, u.shape, 150)
energy = total_strain_energy(e_arr, mask)
print(energy)
