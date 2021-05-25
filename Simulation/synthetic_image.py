import numpy as np
import scipy.sparse as sp
from scipy.ndimage import gaussian_filter


def raw_points_grid(res):
    """
    Makes image of randomly placed beads
    :param res: Resolution
    :return: matrix
    """
    x = np.random.randint(low=0, high=res, size=res)
    y = np.random.randint(low=0, high=res, size=res)
    mat = np.zeros((res, res))
    mat[x, y] = 1
    return mat


def add_out_of_focus(img, density, sigma):
    nrows = img.shape[0]
    ncols = img.shape[1]
    points = sp.rand(nrows, ncols, density=density).A
    points[np.nonzero(points)] = 1
    blurred = gaussian_filter(points, sigma=sigma)
    new = img + blurred
    return new


def gen_img(size, density, sigma):
    """
    Creates image with randomly placed beads and noisy regions
    :param size: Size of resulting image
    :param density: density of out of focus regions (between 0 and 1)
    :param sigma: how blurry the out of focus regions will be (100 seems good for this)
    :return: image with randomly placed beads and noisy regions
    """
    raw = raw_points_grid(size)
    smoothed = gaussian_filter(raw, sigma=5)
    blurry = add_out_of_focus(smoothed, density=density, sigma=sigma)
    return blurry
