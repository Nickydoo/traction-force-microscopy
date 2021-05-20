from my_utils import shift_by_one, move_points_circle, raw_points_grid, raw_points_grid_and_x_y, x_y_to_img
from scipy.ndimage import gaussian_filter
from openpiv.pyprocess import extended_search_area_piv, get_coordinates
from openpiv.validation import sig2noise_val
from openpiv.filters import replace_outliers
from plotting import show_quiver
import matplotlib.pyplot as plt
import numpy as np


# generate synthetic images

# moved_right = np.roll(raw_before[0:201, 0:201], 5)
# raw_moved = raw_before.copy()
# raw_moved[0:201, 0:201] = moved_right
def make_images():
    raw_before, raw_x, raw_y = raw_points_grid_and_x_y(1608, 1)
    moved_x, moved_y, displacement_x, displacement_y = move_points_circle(raw_x, raw_y, 150)
    moved_x_r = [int(round(num)) for num in moved_x]
    moved_y_r = [int(round(num)) for num in moved_y]
    raw_moved = x_y_to_img(moved_x_r, moved_y_r)
    gaussian_before = gaussian_filter(raw_before, sigma=5, order=0)
    gaussian_after = gaussian_filter(raw_moved, sigma=5, order=0)
    return gaussian_before, gaussian_after, displacement_x, displacement_y


def get_displacements(img1, img2, window_size=64):
    u, v, sig2noise = extended_search_area_piv(img1, img2, window_size=window_size, overlap=window_size // 2, dt=1,
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
    x, y = get_coordinates(image_size=img1.shape, search_area_size=window_size, overlap=window_size // 2)
    y = y[::-1]
    v = -v
    return {'x': x, 'y': y, 'u': u, 'v': v}
im_before = raw_points_grid(1608, 1)
im_after = np.roll(np.roll(im_before.copy(), 1, axis=0),1, axis=1)
for wsize in range(32, 16*10+1, 16):
    gauss_before = gaussian_filter(im_before, sigma=5)
    gauss_after = gaussian_filter(im_after, sigma=5)
    disps = get_displacements(gauss_before, gauss_after, window_size=wsize)
    u, v = disps["u"], disps["v"]
    actual_x_disps = np.full(u.shape, 1)
    actual_y_disps = np.full(v.shape, 1)
    xerror = ((actual_x_disps - u)**2)
    yerror = ((actual_y_disps - u)**2)
    mxerror = np.average(xerror)
    myerror = np.average(yerror)
    mse = np.average(np.stack((mxerror, myerror)))
    plt.plot(u, v, 'r.')
    plt.show()
    print(f'relative error for window size {wsize} is {1/ mse * 100} % ')


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
