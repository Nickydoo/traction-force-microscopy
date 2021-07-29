from tkinter import filedialog
from skimage import io
import numpy as np
from skimage.restoration import rolling_ball
from skimage.filters import difference_of_gaussians

stack = io.imread(r"F:\Sam\July 20\stack_trypsin_0_12.tif")
before = stack[0, ...]
after = stack[1, ...]


def normalize(img):
    """
    Normalizes image
    :param img: Any image
    :return: normalized image
    """
    img = img - np.percentile(img, 1)  # 1 Percentile
    img = img / np.percentile(img, 99.99)  # norm to 99 Percentile
    img[img < 0] = 0.0
    img[img > 1] = 1.0
    return img


def filter_for_tfm(img, low=1, high=7, radius=None):
    """
    Apply first a bandpass and then a background subtraction to fluorescent bead images
    Difference of gaussians - features will be detected between low and high
    :param img: image of beads
    :param low: sigma of smaller gaussian
    :param high: sigma of larger gaussian
    :param radius: radius of rolling ball for background subtraction
    :return: processed image
    """
    filtered_img = difference_of_gaussians(img, low, high)
    if radius is not None:
        background = rolling_ball(filtered_img, radius=radius)
        only_beads = filtered_img - background
        return only_beads
    else:
        return filtered_img


before_proc = normalize(filter_for_tfm(before))
after_proc = normalize(filter_for_tfm(after))
io.imsave("before_proc.tif", before_proc)
io.imsave("after_proc.tif", after_proc)
