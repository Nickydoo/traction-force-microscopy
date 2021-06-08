from scipy.ndimage import median_filter, gaussian_filter
from skimage.filters import difference_of_gaussians
import numpy as np


def subtract_med_filter(img):
    smallfilt = median_filter(img, 2)
    medfilt = median_filter(img, 16)
    new_im = np.abs(smallfilt - medfilt)
    new_im -= np.min(new_im)
    return new_im


def dog_filter(img, low_sigma, high_sigma, weight):
    im1 = gaussian_filter(img, low_sigma)
    im2 = weight * gaussian_filter(img, high_sigma)
    new_img = np.abs(im1-im2)
    return new_img


