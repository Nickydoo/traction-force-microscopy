import numpy as np

def reg_fttc(u, v, L, E, s, pix):
    """
    Calculates traction field using regularized fourier transform traction cytometry
    :param u: deformation field in x direction
    :param v: deformation field in y direction
    :param L: Tikhonov regularization parameter
    :param E: Young's modulus
    :param s: Poisson's ratio
    :param pix: pixel size in meters/pixel of image (from microscope)
    :return:
    """
    V = 2*(1+s)/E # constant from beginning of eq 20.6 for ease of calculation
    # must zero pad first to get regular grid
    ax1_length = np.shape(u)[0]
    ax2_length = np.shape(u)[1]
    max_ind = int(np.max((ax1_length, ax2_length)))
    if max_ind % 2 != 0:
        max_ind += 1 # make sure it is even
    u_expand = np.zeros((max_ind, max_ind))
    v_expand = np.zeros((max_ind, max_ind))

    # make wave vectors for u and v
    kx1 = np.array([list(range(0, int(max_ind / 2), 1)), ] * int(max_ind))
    kx2 = np.array([list(range(-int(max_ind / 2), 0, 1)), ] * int(max_ind))
    kx = np.append(kx1, kx2, axis=1) * 2 * np.pi

    ky = np.transpose(kx)
    k = np.sqrt(kx**2 + ky**2)/(pix * max_ind)

    # fourier transforms of displacement
    u_ft = np.fft.fft2(u_expand * pix)
    v_ft = np.fft.fft2(v_expand * pix)
