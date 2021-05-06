import numpy as np
import matplotlib.pyplot as plt
import scipy.ndimage as nd
import matplotlib.ticker as tkr
import cv2
from my_utils import raw_points_grid

np.random.seed(1)


def make_plots(raw_arrays, gaussian_arrays, sf):
    def numfmt(x, pos):
        s = "{}".format(x / sf)
        return s

    fmt = tkr.FuncFormatter(numfmt)
    fig, axes = plt.subplots(len(gaussian_arrays), len(raw_arrays))
    for i in range(len(raw_arrays)):
        axes[0, i].imshow(raw_arrays[i], cmap="gray", interpolation="nearest")
        axes[0, i].title.set_text(f'Raw Array {i}')
    for i in range(len(gaussian_arrays)):
        axes[1, i].imshow(gaussian_arrays[i], cmap="gray")
        axes[1, i].title.set_text('Gaussian Array')
    for i in range(len(axes)):
        for j in range(len(axes)):
            axes[i, j].xaxis.set_major_formatter(fmt)
            axes[i, j].yaxis.set_major_formatter(fmt)
    plt.show()


def subtract_median(gaussian_array, filter_size, show_plots=True):
    """
    Subtracts median filtered image from original image to reduce noise (step 2 of plotnikov paper)
    Optionally shows before/after
    :param filter_size: size of filter to be passed to scipy
    :param gaussian_array:
    :param show_plots:
    :return: Fitered image
    """
    g_med = nd.median_filter(gaussian_array, filter_size)
    filtered = np.abs(gaussian_array - g_med)
    if show_plots:
        fig, ax = plt.subplots(1, 2)
        ax[0].imshow(gaussian_array, cmap="gray")
        ax[0].title.set_text("Before Filter")
        ax[1].imshow(filtered, cmap="gray")
        ax[1].title.set_text("After Filter")
    return filtered


def add_out_of_focus(orig_g_mat, show_plots=True):
    new = raw_points_grid(1608, 2)
    np.random.shuffle(new)
    blurry_points = nd.gaussian_filter(new, sigma=100, order=0)
    mod = orig_g_mat + blurry_points
    if show_plots:
        fig, ax = plt.subplots(1, 2)
        ax[0].imshow(orig_g_mat, cmap="gray")
        ax[0].title.set_text("Original")
        ax[1].imshow(mod, cmap="gray")
        ax[1].title.set_text("With Blurry Points")
        plt.show()
    return mod


def create_image(res, sf, make_plot=True, return_array=True, save_image=True):
    """
    :param save_image: whether or not to save image
    :param return_array: whether or not to return arrays of original positions and filtered beads
    :param res: resolution of image, nominally 1608x1608
    :param sf: scale factor to allow for sub-pixel resolution
    :param make_plot: whether or not to display matplotlib plot
    """
    resolution = res * sf
    x = np.random.randint(low=0, high=resolution, size=resolution)
    y = np.random.randint(low=0, high=resolution, size=resolution)
    mat = np.zeros((resolution, resolution))
    mat[x, y] = 1
    mat2 = nd.gaussian_filter(mat, sigma=5.0, order=0)
    if save_image:
        plt.imsave("gaussian_image.png", mat2, cmap="gray")
    if make_plot:
        def numfmt(x, pos):
            s = "{}".format(x / sf)
            return s

        fmt = tkr.FuncFormatter(numfmt)
        fig, axes = plt.subplots(1, 2)
        axes[0].imshow(mat, cmap="gray", interpolation="nearest")
        axes[1].imshow(mat2, cmap="gray")
        for i in range(len(axes)):
            axes[i].xaxis.set_major_formatter(fmt)
            axes[i].yaxis.set_major_formatter(fmt)
        plt.show()
    if return_array:
        return mat, mat2


def move_points(mat, move_by_px_up, move_by_px_down):
    """
    :param move_by_px_down: Amount to move each dot by in the down direction
    :param mat: matrix
    :param move_by_px_up: Amount to move each dot by in the up direction
    :return: Unfiltered array of moved points
    """
    positions = mat.copy()
    rows = cols = len(positions)
    quarter_size = int(rows / 4)
    second_quarter_start = 0 + quarter_size
    second_quarter_end = second_quarter_start + quarter_size
    third_quarter_start = second_quarter_end + 1
    third_quarter_end = third_quarter_start + quarter_size
    for row in range(second_quarter_start, second_quarter_end):
        for col in range(cols):
            if positions[row][col] == 1:
                positions[row - move_by_px_up][col] = 1
                positions[row][col] = 0
    for row in range(third_quarter_start, third_quarter_end):
        for col in range(cols):
            if positions[row][col] == 1:
                positions[row + move_by_px_down][col] = 1
                positions[row][col] = 0
    return positions


raw_mat = raw_points_grid(1608, 2)
unmoved_gauss = nd.gaussian_filter(raw_mat, sigma=5.0, order=0)
add_out_of_focus(unmoved_gauss)
# moved_mat = move_points(raw_mat, move_by_px_up=100, move_by_px_down=0)
# rarrs = [raw_mat, moved_mat]
# subtract_median(unmoved_gauss, 10)
# moved_gauss = nd.gaussian_filter(moved_mat, sigma=5.0, order=0)
# gaussians = [unmoved_gauss, moved_gauss]
# make_plots(rarrs, gaussians, 2)

# raw_diffs = cv2.subtract(moved_mat, raw_mat)
# plt.imshow(raw_diffs, cmap="gray")
# plt.show()
# mod_diffs = cv2.subtract(moved_gauss, unmoved_gauss)
# plt.imshow(mod_diffs, cmap="gray")
# plt.show()

# TODO: compute error of localization - use local maxima detection
# https://stackoverflow.com/questions/9111711/get-coordinates-of-local-maxima-in-2d-array-above-certain-value
# TODO: remove local maxima that are too close to each other, within 4 - 10 pixels
# TODO: compute displacement & displacement error - reference 20.2.3 of plotnikov paper
