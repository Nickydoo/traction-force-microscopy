import matplotlib
from matplotlib import cm
import matplotlib.pyplot as plt
from contextlib import suppress
import numpy as np


def add_colorbar(vmin, vmax, cmap="rainbow", ax=None, cbar_width="2%",
                 cbar_height="50%", cbar_borderpad=0.1, cbar_tick_label_size=15, cbar_str="",
                 cbar_axes_fraction=0.2, shrink=0.8, aspect=20, cbar_title_pad=1, **kwargs):
    norm = matplotlib.colors.Normalize(vmin=vmin, vmax=vmax)
    sm = plt.cm.ScalarMappable(cmap=matplotlib.cm.get_cmap(cmap), norm=norm)
    sm.set_array([])  # bug fix for lower matplotlib version
    cb0 = plt.colorbar(sm, aspect=aspect, shrink=shrink, fraction=cbar_axes_fraction,
                       pad=cbar_borderpad)  # just exploiting the axis generation by a plt.colorbar
    cb0.outline.set_visible(False)
    cb0.ax.tick_params(labelsize=cbar_tick_label_size)
    with suppress(TypeError, AttributeError):
        cb0.ax.set_title(cbar_str, color="black", pad=cbar_title_pad)
    return cb0


def filter_values(ar1, ar2, abs_filter=0, f_dist=3, filter_method="regular", radius=5):
    """
    function to filter out values from an array for better display
    :param radius:
    :param filter_method:
    :param abs_filter:
    :param ar1:
    :param ar2:
    :param f_dist: distance betweeen filtered values
    :return:
    """

    if filter_method == "regular":
        pixx = np.arange(np.shape(ar1)[0])
        pixy = np.arange(np.shape(ar1)[1])
        xv, yv = np.meshgrid(pixy, pixx)

        def_abs = np.sqrt((ar1 ** 2 + ar2 ** 2))
        select_x = ((xv - 1) % f_dist) == 0
        select_y = ((yv - 1) % f_dist) == 0
        select_size = def_abs > abs_filter
        select = select_x * select_y * select_size
        s1 = ar1[select]
        s2 = ar2[select]
        x_ind = xv[select]
        y_ind = yv[select]
    if filter_method == "local_maxima":
        y_ind, x_ind = find_maxima(ar1, ar2, radius=radius, shape="circle")
        s1 = ar1[y_ind, x_ind]
        s2 = ar2[y_ind, x_ind]
    if filter_method == "local_maxima_square":
        y_ind, x_ind = find_maxima(ar1, ar2, radius=radius, shape="square")
        s1 = ar1[y_ind, x_ind]
        s2 = ar2[y_ind, x_ind]
    return s1, s2, x_ind, y_ind


def find_maxima(ar1, ar2, radius=5, shape="circle"):
    # generating circle

    ys, xs = np.indices((radius * 2 + 1, radius * 2 + 1))
    xs = (xs - radius).astype(float)
    ys = (ys - radius).astype(float)
    if shape == "circle":
        out = np.sqrt(xs ** 2 + ys ** 2) <= radius
        xs[~out] = np.nan
        ys[~out] = np.nan
    abs_val = np.sqrt(ar1 ** 2 + ar2 ** 2)
    lmax = np.unravel_index(np.nanargmax(abs_val), shape=abs_val.shape)
    maxis = [lmax]
    while True:
        x_exclude = (lmax[1] + xs).flatten()
        y_exclude = (lmax[0] + ys).flatten()
        outside_image = (x_exclude >= abs_val.shape[1]) | (x_exclude < 0) | (y_exclude >= abs_val.shape[0]) | (
                y_exclude < 0) | (np.isnan(x_exclude)) | (np.isnan(y_exclude))
        x_exclude = x_exclude[~outside_image]
        y_exclude = y_exclude[~outside_image]
        abs_val[y_exclude.astype(int), x_exclude.astype(int)] = np.nan
        try:
            lmax = np.unravel_index(np.nanargmax(abs_val), shape=abs_val.shape)
        except ValueError:
            break
        maxis.append(lmax)

    maxis_y = [i[0] for i in maxis]
    maxis_x = [i[1] for i in maxis]
    return maxis_y, maxis_x


def set_vmin_vmax(x, vmin, vmax):
    if not isinstance(vmin, (float, int)):
        vmin = np.nanmin(x)
    if not isinstance(vmax, (float, int)):
        vmax = np.nanmax(x)
    if isinstance(vmax, (float, int)) and not isinstance(vmin, (float, int)):
        vmin = vmax - 1 if vmin > vmax else None
    return vmin, vmax


def scale_for_quiver(ar1, ar2, dims, scale_ratio=0.2, return_scale=False):
    scale = scale_ratio * np.max(dims) / np.nanmax(np.sqrt(ar1 ** 2 + ar2 ** 2))
    if return_scale:
        return scale
    return ar1 * scale, ar2 * scale
