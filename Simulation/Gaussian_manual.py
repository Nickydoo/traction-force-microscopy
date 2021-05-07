import numpy as np
import matplotlib.pyplot as plt
import scipy.ndimage as nd
import matplotlib.ticker as tkr
from my_utils import raw_points_grid, mse, struct_sim
from oct2py import octave
import pprint
octave.addpath("/home/sam/Documents/MATLAB")

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
        plt.show()
    brightness_factor = np.min(filtered)
    mod = filtered - brightness_factor
    return mod


def find_maxima(img, show_plots=True):
    neighborhood_size = 10
    t = 2  # weight for avg intensity
    avg_intensity = t * np.average(img)  # 0 is black and 1 is white, you can just average the values of the entire img
    data_max = nd.filters.maximum_filter(img, neighborhood_size)
    maxima = (img == data_max)
    diff = (data_max - avg_intensity) > 0
    maxima[diff == 0] = 0
    labeled, num_objects = nd.label(maxima)
    slices = nd.find_objects(labeled)
    x, y = [], []
    for dy, dx in slices:
        x_center = (dx.start + dx.stop - 1) / 2
        x.append(x_center)
        y_center = (dy.start + dy.stop - 1) / 2
        y.append(y_center)
    print(x[100:120])
    # print(y[100])
    # new_mat = np.zeros_like(img)
    # new_mat[x, y] = 1
    if show_plots:
        fig, ax = plt.subplots(1, 2)
        ax[0].imshow(img, cmap="gray")
        ax[0].title.set_text("Regular Image")
        ax[1].imshow(maxima, cmap="gray")
        ax[1].title.set_text("Local Maxima")
        plt.show()
    return maxima


def localization_error(true_im, im):
    """
    :param true_im: Unblurred, unfiltered image
    :param im: Image after processing
    :return: MSE and SSIM
    """
    mean_squared_err = mse(true_im, im)
    structural_similarity = struct_sim(true_im, im)
    return mean_squared_err, structural_similarity


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
added_blurry_points = add_out_of_focus(unmoved_gauss, False)
filtered = subtract_median(added_blurry_points, 10, False)
out = octave.pkfnd(plt.imread("gaussian_image.png"))
# print(processed)
# print(localization_error(raw_mat.reshape(1608, 1608), processed.reshape(1608, 1608)))
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
# TODO: Just call the .m file from python - since using saved image I'll have to be smart about image name etc
# - can unravel matrix, sort, and compare points AFTER getting them into x-y space (from matlab function)
# https://stackoverflow.com/questions/9111711/get-coordinates-of-local-maxima-in-2d-array-above-certain-value
# TODO: remove local maxima that are too close to each other, within 4 - 10 pixels
# TODO: compute displacement & displacement error - reference 20.2.3 of plotnikov paper
