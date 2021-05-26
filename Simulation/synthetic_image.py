import numpy as np
import scipy.sparse as sp
from scipy.ndimage import gaussian_filter
from skimage.measure import regionprops
import matplotlib.pyplot as plt
from skimage.draw import circle


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


def add_out_of_focus(img, moved_img, density, sigma):
    nrows = img.shape[0]
    ncols = img.shape[1]
    points = sp.rand(nrows, ncols, density=density).A
    points[np.nonzero(points)] = 1
    blurred = gaussian_filter(points, sigma=sigma)
    new_unmoved = img + blurred
    new_moved = moved_img + blurred
    return new_unmoved, new_moved


def gen_img(size, density, sigma, radius, move_by_px):
    """
    Creates image with randomly placed beads and noisy regions
    :param size: Size of resulting image
    :param density: density of out of focus regions (between 0 and 1)
    :param sigma: how blurry the out of focus regions will be (100 seems good for this)
    :param radius: how big the "cell" is for moving points in the after image
    :param move_by_px: how much points are moved by the "cell"
    :return: image with randomly placed beads and noisy regions
    """
    raw = raw_points_grid(size)
    moved = move_points_circle(raw, radius, move_by_px)
    smoothed_raw = gaussian_filter(raw, sigma=5)
    smoothed_moved = gaussian_filter(moved, sigma=5)
    blurry_unmoved, blurry_moved = add_out_of_focus(smoothed_raw, smoothed_moved, density=density, sigma=sigma)
    return blurry_unmoved, blurry_moved


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


def create_circular_mask(img, radius):
    h = img.shape[1]
    w = img.shape[0]
    center = (w // 2, h // 2)
    Y, X = np.ogrid[:h, :w]
    dist_from_center = np.sqrt((X - center[0]) ** 2 + (Y - center[1]) ** 2)
    mask = dist_from_center <= radius
    return mask


def move_points_circle(raw, radius, move_by_px):
    """
    contraction of points towards center of image
    :param raw: raw image
    :param radius: radius of circle (how many points will be moved)
    :param move_by_px: how many px the points will move
    :return: image that has points within circle moved by move_by_px
    """
    h, w = raw.shape
    mid = h // 2
    mask = create_circular_mask(raw, radius)
    only_inside = raw.copy()
    only_inside[~mask] = 0
    x, y = np.nonzero(only_inside)
    coords = list(zip(x, y))
    new_xs = []
    new_ys = []
    for tup in coords:
        if tup[0] < mid and tup[1] < mid:  # upper left
            new_x = tup[0] + move_by_px
            new_y = tup[1] + move_by_px
            new_xs.append(new_x)
            new_ys.append(new_y)
        elif tup[0] > mid > tup[1]:  # upper right
            new_x = tup[0] - move_by_px
            new_y = tup[1] + move_by_px
            new_xs.append(new_x)
            new_ys.append(new_y)
        elif tup[0] < mid < tup[1]:  # lower left
            new_x = tup[0] + move_by_px
            new_y = tup[1] - move_by_px
            new_xs.append(new_x)
            new_ys.append(new_y)
        else:  # lower right
            new_x = tup[0] - move_by_px
            new_y = tup[1] - move_by_px
            new_xs.append(new_x)
            new_ys.append(new_y)
    res = raw.copy()
    res[x, y] = 0
    res[new_xs, new_ys] = 1
    return res


before, after = gen_img(1608, 0.25, 100, 200, 100)
plt.subplot(121)
plt.imshow(before, cmap="gray")
plt.subplot(122)
plt.imshow(after, cmap="gray")
plt.show()

# filter x and y greater than or less than center, don't need to do 2 masks
