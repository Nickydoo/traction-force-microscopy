import numpy as np
import matplotlib.pyplot as plt
from DisplacementTracking import get_displacements
from utils import correct_shift, filter_for_tfm
from TractionCalculation import fttc
from tqdm import tqdm
import time
from skimage import io
import multiprocessing as mp

t0 = time.time()

movie = io.imread(r"F:\Sam\July 14\timelapse.tif")
beads = [movie[i, 0, ...] for i in range(movie.shape[0])]
# cell_images = [movie[i, 1, ...] for i in range(movie.shape[0])]
before = []
after = []
# cell = []
for i in range(1, len(beads)):
    before.append(beads[i - 1])
    after.append(beads[i])
    # cell.append(cell_images[i - 1])

pairs = list(zip(before, after))


def tfm_process(pair):
    before_image, after_image = pair
    # before_image, after_image, cell_image = correct_shift(before_image, after_image, cell_image)
    before_image = filter_for_tfm(before_image, low=1, high=5, radius=None)
    after_image = filter_for_tfm(after_image, low=1, high=5, radius=None)
    window_size = 20
    displacement_dict = get_displacements(before_image, after_image, window_size, int(0.75 * window_size))
    x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
    tx, ty = fttc(u, v, 1, 2200, 0.49, 0.12, False)
    return x, y, tx, ty


if __name__ == '__main__':
    pool = mp.Pool(mp.cpu_count())

    results = pool.map(tfm_process, [pair for pair in pairs])

    pool.close()
    np.save("parallel_test_2.npy", results)

    t1 = time.time()
    print(f'took {t1 - t0} seconds')
