import numpy as np
import matplotlib.pyplot as plt
from tkinter import filedialog
from scipy.ndimage import gaussian_filter
from mpl_toolkits.mplot3d import Axes3D
from my_utils import subtract_median, find_maxima_skimage


def load_files():
    file_paths = filedialog.askopenfilenames(title="Select images", filetypes=(("tif Files", "*.tif"),
                                                                               ("tiff Files", "*.tiff"),
                                                                               ("JPEG Files", "*.jpeg"),
                                                                               ("all Files", "*.*")))
    return file_paths


images = ('/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_001_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_002_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_003_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_004_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_005_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_006_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_007_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_008_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_009_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_010_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_011_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_012_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_013_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_014_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_015_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_016_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_017_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_018_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_019_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_020_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_021_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_022_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_023_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_024_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_025_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_026_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_027_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_028_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_029_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_030_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_031_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_032_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_033_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_034_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_035_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_036_001.tif',
          '/home/sam/Documents/traction-force-microscopy/Data/Beads 10/ChanA_001_001_037_001.tif')
ims = [plt.imread(im) for im in images]
# filtered_im = subtract_median(ims[20], 20, True)
out = np.stack(ims, axis=2)
projection = out.max(-1)
filtered_projection = gaussian_filter(projection, sigma=2, order=0)
# maxima_raw = find_maxima_skimage(projection, 0.5)
p_x, p_y = find_maxima_skimage(filtered_projection, 1)


def only_maxima(im, x, y):
    """
    Given an image and x and y coordinates of maxima, return an image with the same value at x, y and zero where there
    is no x, y
    Does this by making a boolean mask with 1 at (x, y) and 0 at non (x,y), multiply im * mask
    :param im: Image to be processed
    :param x: list of x coordinates
    :param y: list of y coordinates
    :return: image with intensities of x and y spots
    """
    #
    mat = np.zeros_like(im)
    np.add.at(mat, (tuple(x), tuple(y)), 1)
    new_im = im * mat
    return new_im


# now I have matrices with only the x y points
# can stack them, argmax along third axis
# then i will have an nxn matrix of indices where there is a maximum pixel value
# but, even if there is a zero this matrix will still be full (if there is a pixel with no local maxima)
# i think that's fine, I can look through the index matrix and only select points at x, y to match them with the z
# for each x y pair, I want to go to that location in the matrix, make a new tuple with x, y, pos
# first multiply each index in array by 0.2 to convert from image number to micron
masked_stack = np.stack([only_maxima(i, p_x, p_y) for i in ims], axis=2)
max_indices = np.argmax(masked_stack, axis=2)
coords = list(zip(p_x, p_y))
z = []
for r, c in coords:
    z.append(0.2*max_indices[r][c])

fig = plt.figure()
ax = fig.gca(projection="3d")
ax.scatter(p_x, p_y, z)
plt.show()

# plt.imshow(projection, cmap="gray")
# plt.plot(maxima_raw[0], maxima_raw[1], 'r.')
# plt.show()
# plt.subplot(121)
# plt.imshow(filtered_projection, cmap="gray")
# plt.plot(p_x, p_y, 'r.')
# plt.subplot(122)
# plt.imshow(only_maxima(filtered_projection, p_x, p_y), cmap="gray")
# plt.show()


# maxima = [find_maxima_skimage(i, 1) for i in ims]
# xs = [tup[0] for tup in maxima]
# ys = [tup[1] for tup in maxima]
# z = np.linspace(0, 7.4, 37)
# fig = plt.figure()
# ax = fig.gca(projection="3d")
# for i in range(20, 22):
#     ax.scatter(xs[i], ys[i], z[i], depthshade=True)
# plt.show()

# plt.imshow(ims[20])
# plt.show()
# X, Y = np.meshgrid(np.arange(0, 2048, 0.5), np.arange(0, 2048, 0.5))
# XX = X.flatten()
# YY = Y.flatten()
# A = np.c_[out[:, 0], out[:, 1], np.ones(out.shape[0])]
# C, res, rank, S = scipy.linalg.lstsq(A, out[:, 2])
# Z = C[0] * X + C[1] * Y + C[2]
