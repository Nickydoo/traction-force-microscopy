import numpy as np
from skimage import measure

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

def pkfnd(im, th, sz):
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

    ind = np.argwhere(im > th)
    nr, nc = im.shape
    tst = np.zeros((nr, nc))
    n = len(ind)
    if n == 0:
        print("Nothing above threshold")
        return []
    mx = []
    # convert index from find to row and column
    rc = [ind % nr, (ind/nr).floor()+1]
    for i in range(n):
        r = rc[i, 0]
        c = rc[i, 1]
        # check each pixel above threshold to see if it's brighter than
        # its neighbors
        # if 1 < r < nr and 1 < c < nc:
            # TODO finish implementing