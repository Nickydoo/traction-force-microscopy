from my_utils import move_points_circle, raw_points_grid_and_x_y, x_y_to_img
from calculate_traction import reg_fttc
from scipy.ndimage import gaussian_filter
from openpiv.pyprocess import extended_search_area_piv, get_coordinates
from openpiv.validation import sig2noise_val
from openpiv.filters import replace_outliers
from plotting import show_quiver
import matplotlib.pyplot as plt
from synthetic_image import gen_img
import numpy as np


def get_displacements(img1, img2, overlap: int, window_size: int, normalized: bool = True):
    """
    :param img1: before image - image with cell on substrate
    :param img2: after image - image after cell has been removed
    :param overlap: how much the cross correlation windows will overlap (must be > window_size/2)
    :param window_size: size of search windows for cross correlation
    :param normalized: Whether to normalize search windows, True is more accurate but takes longer
    :return: dictionary with x,y coordinates of search windows and u (x-component) and v (y-component) of displacement
    """
    u, v, sig2noise = extended_search_area_piv(img1, img2, window_size=window_size, overlap=overlap, dt=1,
                                               subpixel_method="gaussian", search_area_size=window_size,
                                               sig2noise_method="peak2peak", normalized_correlation=normalized)

    u, v, mask = sig2noise_val(u, v, sig2noise, threshold=1.05)

    def_abs = np.sqrt(u ** 2 + v ** 2)
    m = np.nanmean(def_abs)
    std = np.nanstd(def_abs)
    threshold = std * 20 + m
    mask_std = def_abs > threshold
    u[mask_std] = np.nan
    v[mask_std] = np.nan

    u, v = replace_outliers(u, v, method="localmean", max_iter=10, kernel_size=2)
    x, y = get_coordinates(image_size=img1.shape, window_size=window_size, overlap=overlap)
    y = y[::-1]
    v = -v
    return {'x': x, 'y': y, 'u': u, 'v': v, 'mask': mask, 'mask_std': mask_std}


def strain_energy_points(u, v, tx, ty, pix):
    """
    :param u: displacement field in x direction
    :param v: displacement field in y direction
    :param tx: tractions in x direction
    :param ty: tractions in y direction
    :param pix: pixel-distance factor
    :return: pointwise energy (use total_strain_energy for magnitude)
    """
    pix *= 10e-6
    energy = ((pix ** 2) / 2) * (tx * u * pix + ty * v * pix)
    return energy


def total_strain_energy(strain_energy, mask):
    """
    Calculate total strain energy
    :param strain_energy: from strain_energy_points
    :param mask: mask of cell boundary
    :return: total strain energy
    """
    return np.sum(strain_energy[mask])


im_before, im_after = gen_img(1608, 0.25, 100, 100, 20)
disps = get_displacements(im_before, im_after, window_size=64)
u, v = disps['u'], disps['v']
tx, ty = reg_fttc(u, v, 10e-4, 4000, 0.49, pix=120000, regularized=False)
print(tx.shape)
fig, ax = show_quiver(tx, ty)
plt.show()

# for wsize in range(32, 16*10+1, 16):
#     gauss_before = gaussian_filter(im_before, sigma=5)
#     gauss_after = gaussian_filter(im_after, sigma=5)
#     disps = get_displacements(gauss_before, gauss_after, window_size=wsize)
#     u, v = disps["u"], disps["v"]
#     actual_x_disps = np.full(u.shape, 1)
#     actual_y_disps = np.full(v.shape, 1)
#     xerror = ((actual_x_disps - u)**2)
#     yerror = ((actual_y_disps - u)**2)
#     mxerror = np.average(xerror)
#     myerror = np.average(yerror)
#     mse = np.average(np.stack((mxerror, myerror)))
#     plt.plot(u, v, 'r.')
#     plt.show()
#     print(f'relative error for window size {wsize} is {1/ mse * 100} % ')


# im_before, im_after, x_movements, y_movements = make_images()
# actually_moved_x = [i for i in x_movements if i > 0.0001 or i < -0.0001] + [0]
# actually_moved_y = [i for i in y_movements if i > 0.0001 or i < -0.0001] + [0]*8
# xarr = np.array(actually_moved_x)
# yarr = np.array(actually_moved_y)
# # print(xarr.shape, yarr.shape)
# for wsize in range(15, 120+1,15):
#
#     displacements = get_displacements(im_before, im_after, window_size=wsize)
#     x, y, u, v = displacements['x'], displacements['y'], displacements['u'], displacements['v']
#     u1d = u[0, :]
#     v1d = v[:, 0]
#     calculated = np.array([u1d, v1d])
#
#     actual = np.array([xarr, yarr])
# print(actual.shape)
# se = (actual - calculated)**2
# plt.hist(se)
# plt.show()
# mse = se.mean(axis=None)
# print(mse)

# print(f'u has length {len(u)}')
# print(f'u has shape {u.shape}')
# print(f'v has length {len(v)}')
# print(f'displacement_x has length {len(displacement_x)}')
# plt.plot(u, v, 'r.')
# plt.plot(displacement_x, displacement_y, 'g.')
# plt.show()
# fig, ax = show_quiver(u, -v)
# plt.show()
# print(u)
