import numpy as np
import matplotlib.pyplot as plt
from DisplacementTracking import get_displacements
from utils import load_movie, correct_shift, bandpass
from PlottingFunctions import display_vector_field, display_heatmap
from TractionCalculation import reg_fttc
from roipoly import RoiPoly




before_frames, after, cell_frames = load_movie()
for before_image, cell_image in list(zip(before_frames, cell_frames)):
    after_image = after.copy()
    print(
        f"Make sure that the shapes match:\nBefore image has shape {before_image.shape}\nAfter image has shape"
        f" {after_image.shape}")
    before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
    print("Stage drift corrected")
    print(f"Shapes after drift correction are:\nBefore: {before_image.shape}, After: {after_image.shape}")
    print("Filtering images")
    # before_image = bandpass(before_image, 1, 5)
    # after_image = bandpass(after_image, 1, 5)
    print("Filtering done")
    window_size = 100
    print("Finding displacements...")
    displacement_dict = get_displacements(before_image, after_image, window_size, int(0.75 * window_size))
    print("Found displacements")
    x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
    print(f'u and v shapes are {u.shape} and {v.shape}')
    plt.imshow(u)
    plt.show()
    # print("Select an ROI")
    # plt.imshow(cell_image)
    # my_roi = RoiPoly(color="r")
    # my_mask = my_roi.get_mask(cell_image)
    # v_mask = my_roi.get_mask(v)
    # u_mask = my_roi.get_mask(u)
    # cell_image[~my_mask] = 0
    # before_image[~my_mask] = 0
    # after_image[~my_mask] = 0
    # u[~u_mask] = 0
    # v[~v_mask] = 0
    display_vector_field(x, y, u, v, window_size, image=before_image)
    plt.show()
    print("Finding tractions...")
    tx, ty = reg_fttc(u, v, 1, 4200, 0.49, 0.12, False)
    print("Found tractions")
    display_vector_field(x, y, tx, ty, window_size, image=cell_image)
    plt.show()



# print(
#     f"Make sure that the shapes match:\nBefore image has shape {before_frames[0].shape}\nAfter image has shape"
#     f" {after.shape}")
# print("Filtering each image")
# before_frames = [bandpass(i, 1, 5) for i in before_frames]
# after = bandpass(after, 1, 5)
# print("Filtering done")
