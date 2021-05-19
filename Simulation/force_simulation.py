from skimage.draw import circle
from scipy.ndimage import gaussian_filter
from skimage import measure
import numpy as np
import matplotlib.pyplot as plt
from my_utils import raw_points_grid
import openpiv.syn


def setup_geometry(im_shape=(300, 300), shape_size=100):
    matrix = np.zeros(im_shape, dtype=int)
    center = measure.regionprops(matrix + 1)[0].centroid
    circ = circle(center[0], center[1], shape_size)
    matrix[circ] = 1
    return matrix


def stress_tensor_from_deformation(mask, type, circ_size=60):
    if type == "gaussian":
        center = measure.regionprops(mask)[0].centroid
        c_x, c_y = np.meshgrid(range(mask.shape[1]), range(mask.shape[0]))  # arrays with all x and y coordinates
        rx = c_x - center[0]
        ry = c_y - center[0]

        rx_new = rx * 0.5  # isotropic contraction towards the center by factor 0.5
        ry_new = ry * 0.5
        u = rx - rx_new  # displacement relative to previous
        v = ry - ry_new
        circ = circle(center[0], center[1], circ_size)
        circ_mask = np.zeros(u.shape)
        circ_mask[circ] = 1
        circ_mask = circ_mask.astype(bool)
        u[~circ_mask] = 0
        v[~circ_mask] = 0
        u = gaussian_filter(u, sigma=5)
        v = gaussian_filter(v, sigma=5)
    if type == "flat":
        center = measure.regionprops(mask)[0].centroid
        c_x, c_y = np.meshgrid(range(mask.shape[1]), range(mask.shape[0]))  # arrays with all x and y coordinates
        rx = c_x - center[0]  # note maybe its also enough to chose any point as refernece point
        ry = c_y - center[0]

        rx_new = rx * 0.5  # isotropic contraction towards the center by factor 0.5
        ry_new = ry * 0.5
        u = rx - rx_new  # displacement relative to previous
        v = ry - ry_new
        circ = circle(center[0], center[1], circ_size)
        circ_mask = np.zeros(u.shape)
        circ_mask[circ] = 1
        circ_mask = circ_mask.astype(bool)
        disp_lengths = np.sqrt(u ** 2 + v ** 2)
        outer_ring = np.logical_and(~circ_mask, mask.astype(bool))
        u[outer_ring] = (u[outer_ring] / disp_lengths[outer_ring]) * np.max(u[circ_mask])
        v[outer_ring] = (v[outer_ring] / disp_lengths[outer_ring]) * np.max(v[circ_mask])
    return u, v, mask.astype(bool)

my_mask = setup_geometry()
u, v, my_mask = stress_tensor_from_deformation(my_mask, type="flat")

plt.plot(u, v, 'r.')
plt.show()
plt.imshow(my_mask)
plt.show()