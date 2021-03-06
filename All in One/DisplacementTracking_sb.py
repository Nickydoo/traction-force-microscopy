import numpy as np
from dependencies.openpiv_sb_pyprocess import extended_search_area_piv_sb, get_coordinates_maxima
from dependencies.openpiv_validation import sig2noise_val
from dependencies.openpiv_filters import replace_outliers

"""
Uses individual bead tracking version of code, very very slow and not recommended
"""


def get_displacements(img1, img2, window_size: int, overlap: int):
    """
    :param img1: before image - image with cell on substrate
    :param img2: after image - image after cell has been removed
    :param overlap: how much the cross correlation windows will overlap (must be > window_size/2)
    :param window_size: size of search windows for cross correlation
    :return: dictionary with x,y coordinates of search windows and u (x-component) and v (y-component) of displacement
    """
    if img1.ndim == 3 or img2.ndim == 3:
        raise ValueError("Make sure to use a grayscale image!")
    u, v, sig2noise = extended_search_area_piv_sb(img1, img2, window_size=window_size, overlap=overlap, dt=1,
                                               subpixel_method="gaussian", search_area_size=window_size,
                                               sig2noise_method="peak2peak")

    u, v, mask = sig2noise_val(u, v, sig2noise, threshold=1.05)

    def_abs = np.sqrt(u ** 2 + v ** 2)
    m = np.nanmean(def_abs)
    std = np.nanstd(def_abs)
    threshold = std * 20 + m
    mask_std = def_abs > threshold
    u[mask_std] = np.nan
    v[mask_std] = np.nan
    u, v = replace_outliers(u, v, method="localmean", max_iter=10, kernel_size=2)
    x, y = get_coordinates_maxima(img1)
    y = y[::-1]
    return {'x': x, 'y': y, 'u': u, 'v': v, 'mask': mask, 'mask_std': mask_std}
