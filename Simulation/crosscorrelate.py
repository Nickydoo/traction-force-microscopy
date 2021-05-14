from scipy.signal import correlate2d
import numpy as np


def cross_correlate(before, after):
    """
    Taken from openpiv tutorial, this uses a sliding window that moves across the image, I want to adapt it
    to have a 15x15 window for each recognized bead.
    I also want to fit a gaussian to the peak of the correlation matrix (output from correlate2d) in order to get
    subpixel displacements
    :param before: before picture
    :param after: after picture
    :return:
    """
    iw = 32
    x, y, u, v = [], [], [], []
    for k in range(0, before.shape[0], iw):
        for m in range(0, before.shape[1], iw):
            ia = after[k:k + iw, m:m + iw]
            ib = before[k:k + iw, m:m + iw]
            c = correlate2d(ib - ib.mean(), ia - ia.mean())
            i, j = np.unravel_index(c.argmax(), c.shape)
            x.append(k - iw / 2.)
            y.append(m - iw / 2.)
            u.append(i - iw / 2. - 1)
            v.append(j - iw / 2. - 1)
