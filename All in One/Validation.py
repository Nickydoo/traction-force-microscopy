import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage.filters import gaussian_filter
from random import gauss
import scipy.sparse as sp

binaryframewidth = 100
particleradius = 1
xdim = 1608
ydim = 1608
num_beads = 2000


def make_beads():
    beads_pos = np.random.rand(num_beads, 2)
    beads_pos[:, 0] = (beads_pos[:, 0] - 0.5) * xdim
    beads_pos[:, 1] = (beads_pos[:, 1] - 0.5) * ydim
    return beads_pos


def move_beads(beads_pos, dt):
    def x_velocity(x):
        return -(5 * 2 / xdim) * x

    def y_velocity(y):
        return -(5 * 2 / ydim) * y

    v_x = x_velocity(beads_pos[:, 0])
    v_y = y_velocity(beads_pos[:, 1])
    new_beads_pos = np.zeros_like(beads_pos)
    new_beads_pos[:, 0] = beads_pos[:, 0] + v_x * dt
    new_beads_pos[:, 1] = beads_pos[:, 1] + v_y * dt
    return new_beads_pos


def binary_image(beads_pos, moved_beads_pos, bead_radius):
    xsize_pix = xdim + 10
    ysize_pix = ydim + 10
    binary = np.zeros((xsize_pix, ysize_pix), dtype=np.int32)
    new_binary = np.zeros((xsize_pix, ysize_pix), dtype=np.int32)
    Y, X = np.ogrid[-bead_radius: bead_radius, -bead_radius: bead_radius]
    inds = X ** 2 + Y ** 2 <= bead_radius ** 2
    centers = dict(x=[], y=[])
    moved_centers = dict(x=[], y=[])
    for i in range(0, num_beads):
        center_x = int(beads_pos[i, 0] + xsize_pix / 2)
        center_y = int(beads_pos[i, 1] + ysize_pix / 2)
        binary[center_y - bead_radius:center_y + bead_radius, center_x - bead_radius:center_x + bead_radius][inds] = 255
        centers['x'].append(center_x)
        centers['y'].append(center_y)
        center_x_new = int(moved_beads_pos[i, 0] + xsize_pix / 2)
        center_y_new = int(moved_beads_pos[i, 1] + ysize_pix / 2)
        new_binary[center_y_new - bead_radius:center_y_new + bead_radius,
                   center_x_new - bead_radius:center_x_new + bead_radius][inds] = 255
    return binary, new_binary


def blur_and_noise(img, blur_sigma, noise_sigma):
    blurred = gaussian_filter(img, sigma=blur_sigma)
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            noise = gauss(0, noise_sigma)
            blurred[i, j] = blurred[i, j] + noise
    return blurred


def add_out_of_focus(img, moved_img, density, sigma):
    """
    Adds out of focus areas to image
    :param img: image without moved points (base image)
    :param moved_img: image with moved points
    :param density: density/how sparse the out of focus regions are (lower -> less regions)
    :param sigma: how blurry the regions will be (higher -> more blurry), around 100 seems good for this
    :return: unmoved image with blurry regions, moved image with blurry regions
    """
    nrows = img.shape[0]
    ncols = img.shape[1]
    points = sp.rand(nrows, ncols, density=density).A
    points[np.nonzero(points)] = 1
    blurred = gaussian_filter(points, sigma=sigma)
    new_unmoved = img + blurred
    new_moved = moved_img + blurred
    return new_unmoved, new_moved


beads = make_beads()
moved_beads = move_beads(beads, 1)
relaxed, stressed = binary_image(beads, moved_beads, 2)
relaxed = blur_and_noise(relaxed, 3, 20)
stressed = blur_and_noise(stressed, 3, 20)
relaxed, stressed = add_out_of_focus(relaxed, stressed, 0.8, 100)
plt.subplot(121)
plt.imshow(relaxed, cmap="gray")
plt.subplot(122)
plt.imshow(stressed, cmap="gray")
plt.show()
