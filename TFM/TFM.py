import numpy as np
import matplotlib.pyplot as plt
from skimage import io
import cv2
from DisplacementTracking import get_displacements
from TractionCalculation import reg_fttc, strain_energy_points, total_strain_energy
from PlottingFunctions import process_mask, show_quiver, display_vector_field
from tkinter import filedialog
from ShiftCorrection import correct_shift
from DeconvBeads import deconv_img
from preprocess import subtract_med_filter


def load_files():
    before_file_path = filedialog.askopenfilename(title="Select BEFORE image (strained substrate)")
    after_file_path = filedialog.askopenfilename(title="Select AFTER image (unstrained substrate)")
    cell_file_path = filedialog.askopenfilename(title="Select CELL image")
    return plt.imread(before_file_path), plt.imread(after_file_path), plt.imread(cell_file_path)


def load_files_tif():
    before_file_path = filedialog.askopenfilename(title="Select BEFORE image stack (strained substrate)")
    after_file_path = filedialog.askopenfilename(title="Select AFTER image stack (unstrained substrate)")
    before_image_tif = io.imread(before_file_path)
    after_image_tif = io.imread(after_file_path)
    if before_image_tif.ndim == 3 and after_image_tif.ndim == 3:
        before_image_beads = before_image_tif[0, ...].astype(np.int32)
        before_image_cell = before_image_tif[1, ...].astype(np.int32)
        after_image_beads = after_image_tif[0, ...].astype(np.int32)
        return before_image_beads, after_image_beads, before_image_cell
    else:
        return before_image_tif, after_image_tif, None


# before_image_path, after_image_path, cell_image_path = load_files()
before_image, after_image, cell_image = load_files_tif()
before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
print("Stage drift corrected")
before_image_filtered = subtract_med_filter(before_image)
after_image_filtered = subtract_med_filter(after_image)
print("Median filter done")
plt.subplot(221)
plt.imshow(before_image, cmap="gray")
plt.title("Before")
plt.subplot(222)
plt.imshow(before_image_filtered, cmap="gray")
plt.title("Before filtered")
plt.subplot(223)
plt.imshow(after_image, cmap="gray")
plt.title("After")
plt.subplot(224)
plt.imshow(after_image_filtered, cmap="gray")
plt.title("After filtered")
plt.show()
# before_image = plt.imread(before_image_path).astype(np.int32)
# after_image = plt.imread(after_image_path).astype(np.int32)
# cell_image = plt.imread(cell_image_path).astype(np.int32)
# both = cv2.subtract(before_image, after_image)
# plt.subplot(131)
# plt.imshow(before_image, cmap="gray")
# plt.title("Before")
# plt.subplot(132)
# plt.imshow(after_image, cmap="gray")
# plt.title("After")
# plt.subplot(133)
# plt.imshow(both, cmap="gray")
# plt.title("Overlay")
# plt.show()
# R = after_image.copy()
# G = before_image.copy()
# B = np.zeros_like(after_image)
# beforeandafter = np.stack([R, G, B], axis=2)
# plt.imshow(beforeandafter)
# plt.show()
window_size = 32
displacement_dict = get_displacements(before_image_filtered, after_image_filtered, window_size, int(0.75*window_size))
print("Displacements found")
x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
display_vector_field(x, y, u, v, window_size, image=cell_image)
plt.show()
# M = np.sqrt(u**2 + v**2)
# plt.imshow(cell_image)
# plt.quiver(x, y, u, v, M)
# plt.colorbar()
# plt.show()
tx, ty = reg_fttc(u, v, 1, 4000, 0.49, 0.12, False)
print("Tractions found")
display_vector_field(x, y, tx, ty, window_size, image=cell_image)
plt.show()
# e_arr = strain_energy_points(u, v, tx, ty, 0.12)
# mask = plt.imread(r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\cells-middle well001_cp_masks.png") \
#     .astype(bool)
# interp_mask = process_mask(mask, u.shape, 150)
# energy = total_strain_energy(e_arr, interp_mask)
# print(energy)
