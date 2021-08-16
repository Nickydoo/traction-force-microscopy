import numpy as np
from skimage import measure
import scipy.ndimage as nd
import matplotlib.pyplot as plt
import cv2
from skimage.feature import peak_local_max

np.random.seed(1)


def raw_points_grid(res, sf):
    """
    :param res: Resolution
    :param sf: Scale factor
    :return: matrix
    """
    resolution = res * sf
    x = np.random.randint(low=0, high=resolution, size=resolution)
    y = np.random.randint(low=0, high=resolution, size=resolution)
    mat = np.zeros((resolution, resolution))
    mat[x, y] = 1
    return mat


def raw_points_grid_and_x_y(res, sf):
    """
    :param res: Resolution
    :param sf: Scale factor
    :return: matrix
    """
    resolution = res * sf
    x = np.random.randint(low=0, high=resolution, size=resolution)
    y = np.random.randint(low=0, high=resolution, size=resolution)
    mat = np.zeros((resolution, resolution))
    mat[x, y] = 1
    return mat, x, y


def ellipse(u, v, a, b):
    """
    :param u: x position of center
    :param v: y position of center
    :param a: radius in x direction
    :param b: radius in y direction
    :return: v1: vector of x coordinates, v2: vector of y coordinates
    """
    t = np.linspace(0, 2 * np.pi, 100)
    v1 = u + a * np.cos(t)
    v2 = v + b * np.sin(t)
    # oval_x, oval_y = ellipse(1608 / 2 * scale_factor, 1608 / 2 * scale_factor, 200 * scale_factor, 300 * scale_factor)
    return v1, v2


def mse(imageA, imageB):
    """
    Find mean squared error between two images of same size
    :param imageA: any image
    :param imageB: any image
    :return: mean squared error
    """
    err = np.sum((imageA.astype("float") - imageB.astype("float")) ** 2)
    err /= float(imageA.shape[0] * imageA.shape[1])

    return err


def struct_sim(imageA, imageB):
    """
    Find structural similarity between two images
    :param imageA: Any image
    :param imageB: Any image
    :return: structural similarity index
    """
    return measure.compare_ssim(imageA, imageB)


def cart2pol(x, y):
    """
    Convert cartesian coordinates to polar
    :param x: list/array of x coordinates
    :param y: list/array of y coordinates
    :return: rho, theta
    """
    rho = np.sqrt(x ** 2 + y ** 2)
    theta = np.arctan2(y, x)
    return rho, theta


def circle(r, center):
    t = np.linspace(0, 2 * np.pi, 100)
    x = center + r * np.cos(t)
    y = center + r * np.sin(t)
    return x, y


def distance(p1, p2):
    """
    Finds euclidean distance between two points
    :param p1: Tuple (x1, y1)
    :param p2: Tuple (x2, y2)
    :return: Absolute euclidean distance between p1, p2
    """
    x1 = p1[0]
    y1 = p1[1]
    x2 = p2[0]
    y2 = p2[1]
    return np.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)


def move_points_circle(x, y, r):
    # move by gaussian(distance)
    coordinates = list(zip(x, y))
    circ_x, circ_y = circle(r, len(x) / 2)
    circ = list(zip(circ_x, circ_y))
    new_x = []
    displacement_x = []
    displacement_y = []
    new_y = []
    gaussian_amp = 5
    gaussian_sigma = 2
    for coord in coordinates:
        nearest_point = min(circ, key=lambda d: distance(d, coord))
        x_distance = nearest_point[0] - coord[0]
        y_distance = nearest_point[1] - coord[1]
        new_x.append(coord[0] + gaussian_amp * np.exp(-x_distance ** 2 / (2 * gaussian_sigma ** 2)))
        displacement_x.append(gaussian_amp * np.exp(-x_distance ** 2 / (2 * gaussian_sigma ** 2)))
        new_y.append(coord[1] + gaussian_amp * np.exp(-y_distance ** 2 / (2 * gaussian_sigma ** 2)))
        displacement_y.append(gaussian_amp * np.exp(-y_distance ** 2 / (2 * gaussian_sigma ** 2)))
    return new_x, new_y, np.array(displacement_x), np.array(displacement_y)


def localization_error(true_im, im):
    """
    :param true_im: Unblurred, unfiltered image
    :param im: Image after processing
    :return: MSE and SSIM
    """
    mean_squared_err = mse(true_im, im)
    structural_similarity = struct_sim(true_im, im)
    return mean_squared_err, structural_similarity


def subtract_median(gaussian_array, filter_size, show_plots=False):
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
    norm_image = cv2.normalize(filtered, None, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
    if show_plots:
        fig, ax = plt.subplots(1, 3)
        ax[0].imshow(gaussian_array, cmap="gray")
        ax[0].title.set_text("Before Filter")
        ax[1].imshow(filtered, cmap="gray")
        ax[1].title.set_text("After Filter")
        ax[2].imshow(norm_image, cmap="gray")
        ax[2].title.set_text("Filtered and Normalized")
        plt.show()
    return filtered


def find_maxima_skimage(im, t):
    """
    Use skimage to find maxima
    :param im: Image to be processed
    :param t: scale factor for threshold
    :return: x and y coordinates of maxima
    """
    pixel_dist_factor = 1  # factor for pixel to x y coords
    a = 10
    th = t * np.average(im)
    coordinates = peak_local_max(im, min_distance=a * pixel_dist_factor, threshold_abs=th)
    x = coordinates[:, 1]
    y = coordinates[:, 0]
    return x, y


def get_x_y(raw_img):
    xvec, yvec = np.nonzero(raw_img)
    return xvec, yvec


def x_y_to_img(xvec, yvec):
    mat = np.zeros((len(xvec), len(yvec)))
    filter_xvec = []
    filter_yvec = []
    for x in xvec:
        if x >= len(xvec):
            filter_xvec.append(len(xvec) - 1)
        else:
            filter_xvec.append(x)
    for y in yvec:
        if y >= len(yvec):
            filter_yvec.append(len(yvec) - 1)
        else:
            filter_yvec.append(y)
    np.add.at(mat, (tuple(filter_xvec), tuple(filter_yvec)), 1)
    return mat
def shift_by_one(im):
    quarter_length = im.shape[0] // 4
    sub = im[quarter_length:3 * quarter_length, quarter_length:3 * quarter_length].copy()
    first_half = sub[len(sub) // 4:len(sub) // 2, :].copy()
    second_half = sub[3 * len(sub) // 4:, :]
    shift_down = np.roll(np.identity(len(first_half)), -1)
    shift_up = np.roll(np.identity(len(second_half)), 1)
    shift_up[:, -1] = 0
    shift_down[:, -1] = 0
    shifted_down = shift_down @ first_half
    shifted_up = shift_up @ second_half
    sub[len(sub) // 4:len(sub) // 2, :] = shifted_down
    sub[3 * len(sub) // 4:, :] = shifted_up
    im[quarter_length:3 * quarter_length, quarter_length:3 * quarter_length] = sub
    return im