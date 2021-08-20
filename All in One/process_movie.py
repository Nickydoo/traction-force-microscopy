import numpy as np
from skimage import io
from utils import bandpass, normalize
import matplotlib
from scipy.ndimage.filters import median_filter
from tqdm import tqdm

matplotlib.rc('image', cmap='gray')
fname = r"D:\Sam\August 18\location 1 registered.tif"
movie = io.imread(fname)
noisesize = 1
objsize = 7

new_movie = np.zeros_like(movie)

for i in tqdm(range(len(movie))):
    new_movie[i] = normalize((bandpass(normalize(movie[i]), noisesize, objsize)))

saveloc = "\\".join(fname.split("\\")[:-1])
savename = fname.split("\\")[-1]
io.imsave(saveloc + "\\" + f'n{noisesize}' + f'o{objsize}' + savename, new_movie)
