import numpy as np
from skimage import measure
from math import floor

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


def pkfnd(im, th, sz=None):
    """
    finds local maxima in an image to pixel level accuracy
    provides a rough guess of particle centers
    Inspired by the lmx subroutine of Grier and Crocker's algorithm
    :param im: image to process
    :param th: minimum brightness of a pixel that might be local maxima
    :param sz:
    :return: N x 2 array containing [row, column] coordinates of local maxima
    out[:, 1] are the x-coordinates of the maxima
    out[:, 2] are the y coordinates of the maxima
    Adapted from Eric R. Dufresne MATLAB code
    """
    t = 1.5  # scaling factor for threshold
    ind = np.argwhere(im > t * th)
    nr, nc = im.shape
    tst = np.zeros((nr, nc))
    n = len(ind)
    if n == 0:
        print("Nothing above threshold")
        return []
    mx = []
    # convert index from find to row and column
    rc = [ind % nr, floor(ind / nr) + 1]
    for i in range(n):  # this might have to be n+1, check later
        r = rc[i, 0]
        c = rc[i, 1]
        # check each pixel above threshold to see if it's brighter than
        # its neighbors
        if 1 < r < nr and 1 < c < nc:
            if im[r, c] >= im[r - 1, c - 1] and im[r, c] >= im[r, c - 1] and im[r, c] >= im[r + 1, c - 1] and im[
                r, c] >= im[r - 1, c] & im[r, c] >= im[r + 1, c] and im[r, c] >= im[r - 1, c + 1] and im[r, c] >= im[
                r, c + 1] and im[r, c] >= im[r + 1, c + 1]:
                mx = np.concat([mx, np.concat([r, c]).T])
    mx = mx.T
    npks, crap = mx.shape
    # if size is specified, then get rid of pks within size of boundary
    if sz is not None and npks > 0:
        # throw out all pks within sz of boundary
        ind = np.argwhere(sz < mx[:, 0] < (nr - sz) and sz < mx[:, 1] < (nc - sz))
        mx = mx[ind, :]

    npks, crap = mx.shape
    if npks > 1:
        # create an image with only peaks
        nmx = npks
        tmp = 0 * im
        for i in range(nmx):  # might have to be nmx + 1
            tmp[mx[i, 0], mx[i, 1]] = im[mx[i, 0], mx[i, 1]]
        # look in neighborhood around each peak, pick the brightest
        for i in range(nmx):  # might have to be nmx + 1
            roi = tmp[[mx[i, 0] - floor(sz / 2)]:[mx[i, 0] + (floor(sz / 2) + 1)], (mx(i, 1) - floor(sz / 2)): (
                    mx[i, 1] + (floor(sz / 2) + 1))]
            mv, indi = np.max(roi)
            mv, indj = np.max(mv)
            tmp[(mx[i, 0] - floor(sz / 2)): (mx[i, 0] + (floor(sz / 2) + 1)), (mx[i, 1] - floor(sz / 2)): (
                    mx[i, 1] + (floor(sz / 2) + 1))] = 0
            tmp[mx[i, 0] - floor(sz / 2) + indi[indj] - 1, mx[i, 1] - floor(sz / 2) + indj - 1] = mv
        ind = np.argwhere(tmp > 0)
        mx = [ind % nr, floor(ind/nr) + 1]
    if mx.shape == (0, 0):
        return []
    else:
        out = []
        out[:, 1] = mx[:, 0]
        out[:, 0] = mx[:, 1]
        return out


