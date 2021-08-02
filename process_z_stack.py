from skimage import io
from skimage.filters import difference_of_gaussians
from scipy.ndimage.filters import median_filter
from skimage.registration import phase_cross_correlation
from scipy.ndimage.interpolation import shift
import matplotlib.pyplot as plt
import numpy as np
import matplotlib
from tqdm import tqdm


def register_movie(stack):
    ref = stack[0]
    moved = stack[1:]
    shifted_ims = []

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


matplotlib.rc('image', cmap='gray')

fname = r"D:\Sam\July 29\timelapse 40x.nd2 - timelapse 40x.nd2 (series 2).tif"
orig = io.imread(fname)
# array is (time, z, channel, x, y)
# so first cell image is (0, 1, 0, ...) because cell z stack is blank in 0 and 2
# beads images are (time, layer, 1, ...)
beads_stacks = orig[:, :, 1, ...]
cell_ims = orig[:, 1, 0, ...]
print("Filtering frames")
first_slice_beads_dog = np.array(
    [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 0, ...], low_sigma=0.5, high_sigma=3), 1))
     for i in range(beads_stacks.shape[0])])
second_slice_beads_dog = np.array(
    [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 1, ...], low_sigma=0.5, high_sigma=3), 1))
     for i in range(beads_stacks.shape[0])])
third_slice_beads_dog = np.array(
    [normalize(median_filter(difference_of_gaussians(beads_stacks[i, 2, ...], low_sigma=0.5, high_sigma=3), 1))
     for i in range(beads_stacks.shape[0])])

new = np.stack([first_slice_beads_dog, second_slice_beads_dog, third_slice_beads_dog])
filtered = np.transpose(new, (1, 0, 2, 3))
projection = np.average(filtered, axis=1)
print("Registering frames")
projection = register_movie(projection)
savename = fname.split("\\")[-1] + "_processed.tif"
io.imsave(r'D:\Sam\July 29\Processed' + "\\" + savename, projection)
