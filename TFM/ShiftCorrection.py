from skimage.registration import phase_cross_correlation
from scipy.ndimage.interpolation import shift
import numpy as np


def normalize(img):
    img = img - np.percentile(img, 1)  # 1 Percentile
    img = img / np.percentile(img, 99.99)  # norm to 99 Percentile
    img[img < 0] = 0.0
    img[img > 1] = 1.0
    return img


def crop(im, x_shift, y_shift):
    if x_shift <= 0:
        im = im[:, int(np.ceil(-x_shift)):]
    else:
        im = im[:, :-int(np.ceil(x_shift))]
    if y_shift <= 0:
        im = im[int(np.ceil(-y_shift)):, :]
    else:
        im = im[:-int(np.ceil(y_shift)), :]
    return np.array(im, dtype=np.float)


def correct_shift(im1, im2):
    vals = phase_cross_correlation(im1, im2, upsample_factor=100)
    y_shift = vals[0][0]
    x_shift = vals[0][1]
    shifted_im1 = shift(im1, shift=(-y_shift, -x_shift), order=5)
    new_im1 = normalize(crop(shifted_im1, x_shift, y_shift))
    new_im2 = normalize(crop(im2, x_shift, y_shift))
    return new_im1, new_im2
