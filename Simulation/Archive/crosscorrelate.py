from scipy.signal import correlate2d
import scipy.optimize as optimize
from scipy.ndimage import gaussian_filter
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from my_utils import find_maxima_skimage, move_points_circle, raw_points_grid_and_x_y, x_y_to_img

# move points in top left corner right by 5 pixels
# moved_right = np.roll(raw_before[0:201, 0:201], 5)
# raw_after = raw_before.copy()
# raw_after[0:201, 0:201] = moved_right


raw_before, raw_x, raw_y = raw_points_grid_and_x_y(1608, 1)
moved_x, moved_y, disp_x, disp_y = move_points_circle(raw_x, raw_y, 150)
moved_x_r = [int(round(num)) for num in moved_x]
moved_y_r = [int(round(num)) for num in moved_y]
raw_moved = x_y_to_img(moved_x_r, moved_y_r)
gaussian_before = gaussian_filter(raw_before, sigma=5, order=0)
gaussian_after = gaussian_filter(raw_moved, sigma=5, order=0)
# plt.subplot(121)
# plt.imshow(gaussian_before, cmap="gray")
# plt.subplot(122)
# plt.imshow(gaussian_after, cmap="gray")
# # plt.show()
#
# plt.subplot(121)
plt.plot(raw_x, raw_y, 'r.')
plt.plot(moved_x_r, moved_y_r, 'g.')
plt.show()
#
# plt.subplot(122)
# x_locations_before, y_locations_before = find_maxima_skimage(gaussian_before, 1)


# xafter, yafter = find_maxima_skimage(gaussian_after, 1)
# plt.plot(x_locations_before, y_locations_before, 'r.')
# plt.plot(xafter, yafter, 'g.')
# # plt.show()


def cross_correlate(before, after, xbefore, ybefore):
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
    coords = list(zip(xbefore, ybefore))
    xlist, ylist, u, v = [], [], [], []
    subpixel_x_d, subpixel_y_d = [], []
    for x, y in coords:
        ia = after[x:x + iw, y:y + iw]
        ib = before[x:x + iw, y:y + iw]
        c = correlate2d(ib - ib.mean(), ia - ia.mean())
        i, j = np.unravel_index(c.argmax(), c.shape)
        xlist.append(x - iw)
        ylist.append(y - iw)
        u.append(i - iw / 2. - 1)
        v.append(j - iw / 2. - 1)
        _, actual_x, actual_y, _, _ = fitgaussian(c)
        subpixel_x_d.append(actual_x)
        subpixel_y_d.append(actual_y)
    return xlist, ylist, u, v, subpixel_x_d, subpixel_y_d

# cross_correlate(gaussian_before, gaussian_after, x_locations_before, y_locations_before)








# fig = plt.figure()
# ax = fig.add_subplot(111, projection="3d")
# cx, cy = np.meshgrid(range(c.shape[0]), range(c.shape[1]))
# ax.plot_surface(cx, cy, c)
# plt.show()
# winsize = 24 # pixels
# searchsize = 64  # pixels, search in image B
# overlap = 12 # pixels
# dt = 0.02 # sec


# u0, v0, sig2noise = pyprocess.extended_search_area_piv(gaussian_before.astype(np.int32), gaussian_after.astype(np.int32), window_size=winsize, overlap=overlap, dt=dt, search_area_size=searchsize, sig2noise_method='peak2peak' )
# x, y = pyprocess.get_coordinates( image_size=gaussian_before.shape, search_area_size=winsize, overlap=overlap )
# u1, v1, mask = validation.sig2noise_val( u0, v0, sig2noise, threshold = 1.3 )
# u2, v2 = filters.replace_outliers( u1, v1, method='localmean', max_iter=10, kernel_size=2)
# x, y, u3, v3 = scaling.uniform(x, y, u2, v2, scaling_factor = 96.52 )
# tools.save(x, y, u3, v3, mask, 'exp1_001.txt' )
# tools.display_vector_field('exp1_001.txt', scale=50, width=0.0025)
