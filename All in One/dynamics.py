import numpy as np
import matplotlib.pyplot as plt
from DisplacementTracking import get_displacements
from utils import load_movie_dynamics, correct_shift, bandpass
from PlottingFunctions import display_vector_field, display_heatmap
from TractionCalculation import reg_fttc

beads, cell_images = load_movie_dynamics()
before = []
after = []
cell = []
for i in range(1, len(beads)):
    before.append(beads[i-1])
    after.append(beads[i])
    cell.append(cell_images[i-1])

pairs = list(zip(before, after, cell))

for before_image, after_image, cell_image in pairs:
    print(
        f"Make sure that the shapes match:\nBefore image has shape {before_image.shape}\nAfter image has shape"
        f" {after_image.shape}")
    before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
    print("Stage drift corrected")
    print(f"Shapes after drift correction are:\nBefore: {before_image.shape}, After: {after_image.shape}")
    print("Filtering images")
    before_image = bandpass(before_image, 1, 7)
    after_image = bandpass(after_image, 1, 7)
    print("Filtering done")
    window_size = 32
    print("Finding displacements...")
    displacement_dict = get_displacements(before_image, after_image, window_size, int(0.75 * window_size))
    print("Found displacements")
    x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
    display_vector_field(x, y, u, v, window_size, image=before_image)
    plt.show()
    print("Finding tractions...")
    tx, ty = reg_fttc(u, v, 1, 4200, 0.49, 0.12, False)
    print("Found tractions")
    display_vector_field(x, y, tx, ty, window_size, image=cell_image)
    plt.show()
