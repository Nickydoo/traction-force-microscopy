import numpy as np
import matplotlib.pyplot as plt
from skimage.restoration import richardson_lucy


def select_point(img):
    plt.imshow(img, cmap="gray")
    plt.show()
    x = int(input("Enter x coordinate of chosen bead"))
    y = int(input("Enter y coordinate of chosen bead"))
    sz = int(input("Enter approximate bead diameter (pixels)"))
    return x, y, sz


def get_PSF(img):
    x, y, sz = select_point(img)
    PSF = img[x - sz:x + sz, y - sz:y + sz]
    PSF /= np.max(PSF)
    return PSF

def deconv_img(img):
    PSF = get_PSF(img)
    deconv = richardson_lucy(img, PSF)
    return deconv
