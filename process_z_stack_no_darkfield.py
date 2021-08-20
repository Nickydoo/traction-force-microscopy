from skimage import io
from skimage.filters import difference_of_gaussians
from scipy.ndimage.filters import median_filter
from skimage.registration import phase_cross_correlation
from scipy.ndimage.interpolation import shift
import matplotlib.pyplot as plt
import numpy as np
import matplotlib
from tqdm import tqdm
from scipy.signal import convolve2d
from scipy.stats import mode


def register_movie(stack):
    ref = stack[0]
    moved = stack[1:]
    shifted_ims = [ref]

    for i in tqdm(range(len(moved))):
        val = phase_cross_correlation(ref, moved[i], return_error=False)
        y_shift = val[0]
        x_shift = val[1]
        shifted_im = shift(moved[i], shift=(y_shift, x_shift), order=5)
        shifted_ims.append(shifted_im)
    return np.array(shifted_ims)


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


def regular_norm(img):
    return img / np.sum(img)


def bandpass(im, lnoise=0, lobject=0, threshold=0):
    """
    :param im: image to be filtered
    :param lnoise: Characteristic lengthscale of noise in pixels
    :param lobject: Integer length in pixels somewhat larger than an object of interest
    :param threshold: brightness threshold
    :return:
    """
    threshold *= mode(im.flatten())[0]
    if not lnoise:
        gaussian_kernel = np.array([[1], [0]])
    else:
        gk = regular_norm(
            np.exp(-((np.arange(-np.ceil(5 * lnoise), np.ceil(5 * lnoise) + 1)) / (2 * lnoise)) ** 2))
        gaussian_kernel = np.vstack((gk, np.zeros(np.size(gk))))
    if lobject:
        bk = regular_norm(np.ones((1, np.size(np.arange(-np.ma.round(lobject), np.ma.round(lobject) + 1)))))
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


matplotlib.rc('image', cmap='gray')

fname = r"D:\Sam\August 3\location 2.tif"
beads_stacks = io.imread(fname)
# array is (time, z, channel, x, y)
# second type is (time, x, y, channel)
# so first cell image is (0, 1, 0, ...) because cell z stack is blank in 0 and 2
# beads images are (time, layer, 1, ...)
# beads_stacks = orig[:, :, 1, ...]
# cell_ims = orig[:, 1, 0, ...]
print("Filtering frames")
# first_slice_beads_dog = np.array(
#     [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 0, ...], low_sigma=0.5, high_sigma=3), 1))
#      for i in range(beads_stacks.shape[0])])
# second_slice_beads_dog = np.array(
#     [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 1, ...], low_sigma=0.5, high_sigma=3), 1))
#      for i in range(beads_stacks.shape[0])])
# third_slice_beads_dog = np.array(
#     [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 2, ...], low_sigma=0.5, high_sigma=3), 1))
#      for i in range(beads_stacks.shape[0])])
noisesize = 1
objsize = 3
first_slice_beads_dog = np.array(
    [normalize(bandpass(beads_stacks[i, ..., 0], noisesize, objsize))
     for i in range(beads_stacks.shape[0])])
second_slice_beads_dog = np.array(
    [normalize(bandpass(beads_stacks[i, ..., 1], noisesize, objsize))
     for i in range(beads_stacks.shape[0])])
third_slice_beads_dog = np.array(
    [normalize(bandpass(beads_stacks[i, ..., 2], noisesize, objsize))
     for i in range(beads_stacks.shape[0])])
fourth_slice_beads_dog = np.array(
    [normalize(bandpass(beads_stacks[i, ..., 3], noisesize, objsize))
     for i in range(beads_stacks.shape[0])])

new = np.stack([first_slice_beads_dog, second_slice_beads_dog, third_slice_beads_dog, fourth_slice_beads_dog])
# filtered = np.transpose(new, (1, 0, 2, 3))
projection = np.average(new, axis=0)
print("Registering frames")
projection = register_movie(projection)
savename = fname.split("\\")[-1] + "_processed_bp_n1obj3n.tif"
io.imsave(r'D:\Sam\August 3\Processed' + "\\" + savename, projection)
