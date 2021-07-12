from tkinter import filedialog
from skimage import io
import numpy as np
from skimage.registration import phase_cross_correlation
from skimage.restoration import rolling_ball
from skimage.filters import difference_of_gaussians
from scipy.ndimage.interpolation import shift
from scipy.signal import convolve2d
from scipy.stats import mode


def load_files():
    """
    Loads before and after image files
    :return: before image, after image, optionally an image of the adhered cell
    """
    before_file_path = filedialog.askopenfilename(title="Select BEFORE image stack (strained substrate)")
    after_file_path = filedialog.askopenfilename(title="Select AFTER image stack (unstrained substrate)")
    before_image_tif = io.imread(before_file_path)
    after_image_tif = io.imread(after_file_path)
    if before_image_tif.ndim == 3 and after_image_tif.ndim == 3:
        before_image_beads = before_image_tif[0, ...].astype(np.int32)
        before_image_cell = before_image_tif[1, ...].astype(np.int32)
        after_image_beads = after_image_tif[0, ...].astype(np.int32)
        return before_image_beads, after_image_beads, before_image_cell
    else:
        return before_image_tif, after_image_tif, None


def load_movie():
    """
    Loads files from movie. Select the movie with a cell on the substrate, and choose a reference image
    or the first frame of a reference movie will be used. The movie should be a .tif file (not nd2) with beads
    in the first channel and cell in the second channel
    :return: list of images for beads, single image of unstrained beads, and list of images for cells
    """
    before_file_path = filedialog.askopenfilename(title="Select movie with cell on substrate")
    after_file_path = filedialog.askopenfilename(title="Select movie/image after lysing cells")
    movie = io.imread(before_file_path)
    after = io.imread(after_file_path)
    bead_frames = [movie[i, 0, ...] for i in range(movie.shape[0])]
    cell_frames = [movie[i, 1, ...] for i in range(movie.shape[0])]
    if after.ndim == 3:
        after_image_beads = after[0, ...]
    elif after.ndim == 4:
        after_image_beads = after[0, 0, ...]
    else:
        after_image_beads = after
    return bead_frames, after_image_beads, cell_frames


def load_movie_dynamics():
    """
    :return: list of bead images and list of cell images
    """
    file_path = filedialog.askopenfilename(title="Select TIF movie")
    movie = io.imread(file_path)
    beads = [movie[i, 0, ...] for i in range(movie.shape[0])]
    cell = [movie[i, 1, ...] for i in range(movie.shape[0])]
    return beads, cell


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


def regular_normalize(img):
    return img / np.sum(img)


def crop(im, x_shift, y_shift):
    """
    Crops shifted image
    :param im: shifted image
    :param x_shift: shift values in x direction
    :param y_shift: shift values in y direction
    :return: cropped image
    """
    if x_shift <= 0:
        im = im[:, int(np.ceil(-x_shift)):]
    else:
        im = im[:, :-int(np.ceil(x_shift))]
    if y_shift <= 0:
        im = im[int(np.ceil(-y_shift)):, :]
    else:
        im = im[:-int(np.ceil(y_shift)), :]
    return np.array(im, dtype=float)


def correct_shift(im1, im2, cell_image=None):
    """
    Corrects stage drift using image registration
    :param im1: image 1 of before/after pair
    :param im2: image 2 of before/after pair
    :param cell_image: optional cell image to also be corrected
    :return: corrected image 1, corrected image 2, optional corrected cell image
    """
    vals = phase_cross_correlation(im1, im2, upsample_factor=100)
    y_shift = vals[0][0]
    x_shift = vals[0][1]
    shifted_im1 = shift(im1, shift=(-y_shift, -x_shift), order=5)
    new_im1 = normalize(crop(shifted_im1, x_shift, y_shift))
    new_im2 = normalize(crop(im2, x_shift, y_shift))
    if cell_image is not None:
        new_cell_image = normalize((crop(cell_image, x_shift, y_shift)))
        return new_im1, new_im2, new_cell_image
    else:
        return new_im1, new_im2, None


def bandpass(im, lnoise=0, lobject=0, threshold=0.05):
    threshold *= mode(im.flatten())[0]
    if not lnoise:
        gaussian_kernel = np.array([[1], [0]])
    else:
        gk = regular_normalize(
            np.exp(-((np.arange(-np.ceil(5 * lnoise), np.ceil(5 * lnoise) + 1)) / (2 * lnoise)) ** 2))
        gaussian_kernel = np.vstack((gk, np.zeros(np.size(gk))))
    if lobject:
        bk = regular_normalize(np.ones((1, np.size(np.arange(-np.ma.round(lobject), np.ma.round(lobject) + 1)))))
        boxcar_kernel = np.vstack((bk, np.zeros(np.size(bk))))
    gconv = convolve2d(np.transpose(im), np.transpose(gaussian_kernel), mode='same')
    gconv = convolve2d(np.transpose(gconv), np.transpose(gaussian_kernel), mode='same')
    if lobject:
        bconv = convolve2d(np.transpose(im), np.transpose(boxcar_kernel), mode='same')
        bconv = convolve2d(np.transpose(bconv), np.transpose(boxcar_kernel), mode='same')
        filtered = gconv - bconv
    else:
        filtered = gconv
    lzero = np.amax((lobject, np.ceil(5 * lnoise)))

    filtered[0:int(np.round(lzero)), :] = 0
    filtered[(-1 - int(np.round(lzero)) + 1):, :] = 0
    filtered[:, 0:int(np.round(lzero))] = 0
    filtered[:, (-1 - int(np.round(lzero)) + 1):] = 0
    filtered[filtered < threshold] = 0
    return filtered


def filter_for_tfm(img, low=2, high=10, radius=5):
    filtered_img = difference_of_gaussians(img, low, high)
    background = rolling_ball(filtered_img, radius=radius)
    only_beads = filtered_img - background
    return only_beads
