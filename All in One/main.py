import numpy as np
import matplotlib.pyplot as plt
from DisplacementTracking import get_displacements
from utils import load_files, correct_shift
from PlottingFunctions import display_vector_field
from TractionCalculation import reg_fttc

before_image, after_image, cell_image = load_files()
print(
    f"Make sure that the shapes match:\nBefore image has shape {before_image.shape}\nAfter image has shape"
    f" {after_image.shape}")

before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
print("Stage drift corrected")
window_size = 32
print("Finding displacements...")
displacement_dict = get_displacements(before_image, after_image, window_size, int(0.75 * window_size))
print("Found displacements")
x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
display_vector_field(x, y, u, v, window_size, image=before_image)
plt.show()
print("Finding tractions...")
tx, ty = reg_fttc(u, v, 1, 2300, 0.49, 0.12, False)
print("Found tractions")
display_vector_field(x, y, tx, ty, window_size, image=cell_image)
plt.show()