import numpy as np


def reg_fttc(u, v, L, E, s, pix, regularized=True):
    """
    Calculates traction field using regularized fourier transform traction cytometry
    :param u: deformation field in x direction
    :param v: deformation field in y direction
    :param L: Tikhonov regularization parameter
    :param E: Young's modulus
    :param s: Poisson's ratio
    :param pix: pixel size in meters/pixel of image (from microscope)
    :param regularized: whether or not to apply regularization (uses MATLAB code)
    :return:
    """
    if regularized:
        V = 2 * (1 + s) / E
        # must zero pad first to get regular grid (step 1)
        ax1_length = np.shape(u)[0]
        ax2_length = np.shape(u)[1]
        max_ind = int(np.max((ax1_length, ax2_length)))
        if max_ind % 2 != 0:
            max_ind += 1  # make sure it is even
        u_expand = np.zeros((max_ind, max_ind))
        v_expand = np.zeros((max_ind, max_ind))
        u_expand[:ax1_length, :ax2_length] = u
        v_expand[:ax1_length, :ax2_length] = v

        # make wave vectors for u and v (step 2)
        kx1 = np.array([list(range(0, int(max_ind / 2), 1)), ] * int(max_ind))
        kx2 = np.array([list(range(-int(max_ind / 2), 0, 1)), ] * int(max_ind))
        kx = np.append(kx1, kx2, axis=1) * 2 * np.pi

        ky = np.transpose(kx)
        k = np.sqrt(kx ** 2 + ky ** 2) / (pix * max_ind)

        # fourier transforms of displacement (step 3)
        u_ft = np.fft.fft2(u_expand * pix)
        v_ft = np.fft.fft2(v_expand * pix)
        Ginv_xx = (kx ** 2 + ky ** 2) ** (-1 / 2) * V * (kx ** 2 * L + ky ** 2 * L + V ** 2) ** (-1) * (
                kx ** 2 * L + ky ** 2 * L + ((-1) + s) ** 2 * V ** 2) ** (-1) * (
                          kx ** 4 * (L + (-1) * L * s) + kx ** 2 * (
                          (-1) * ky ** 2 * L * ((-2) + s) + (-1) * ((-1) + s) * V ** 2) + ky ** 2 * (
                                  ky ** 2 * L + ((-1) + s) ** 2 * V ** 2))

        Ginv_yy = (kx ** 2 + ky ** 2) ** (-1 / 2) * V * (kx ** 2 * L + ky ** 2 * L + V ** 2) ** (-1) * (
                kx ** 2 * L + ky ** 2 * L + ((-1) + s) ** 2 * V ** 2) ** (-1) * (
                          kx ** 4 * L + (-1) * ky ** 2 * ((-1) + s) * (ky ** 2 * L + V ** 2) + kx ** 2 * (
                          (-1) * ky ** 2 * L * ((-2) + s) + ((-1) + s) ** 2 * V ** 2))

        Ginv_xy = (-1) * kx * ky * (kx ** 2 + ky ** 2) ** (-1 / 2) * s * V * (kx ** 2 * L + ky ** 2 * L + V ** 2) ** (
            -1) * (kx ** 2 * L + ky ** 2 * L + ((-1) + s) * V ** 2) * (
                          kx ** 2 * L + ky ** 2 * L + ((-1) + s) ** 2 * V ** 2) ** (-1)
        Ginv_xx[0, 0] = 0
        Ginv_yy[0, 0] = 0
        Ginv_xy[0, 0] = 0
        Ginv_xy[max_ind / 2 + 1, :] = 0
        Ginv_xy[:, max_ind / 2 + 1] = 0
        # calculate traction in fourier space (step 5)
        Ftfx = Ginv_xx * u_ft + Ginv_xy * v_ft
        Ftfy = Ginv_xy * u_ft + Ginv_yy * v_ft
        # transform back to real space (step 6)
        tx = np.fft.ifft2(Ftfx).real
        ty = np.fft.ifft2(Ftfy).real
    else:
        u_shift = (u - np.mean(u))
        v_shift = (v - np.mean(v))
        V = 2 * (1 + s) / E
        # must zero pad first to get regular grid (step 1)
        ax1_length = np.shape(u_shift)[0]
        ax2_length = np.shape(u_shift)[1]
        max_ind = int(np.max((ax1_length, ax2_length)))
        if max_ind % 2 != 0:
            max_ind += 1  # make sure it is even
        u_expand = np.zeros((max_ind, max_ind))
        v_expand = np.zeros((max_ind, max_ind))
        u_expand[:ax1_length, :ax2_length] = u_shift
        v_expand[:ax1_length, :ax2_length] = v_shift

        # make wave vectors for u and v (step 2)
        kx1 = np.array([list(range(0, int(max_ind / 2), 1)), ] * int(max_ind))
        kx2 = np.array([list(range(-int(max_ind / 2), 0, 1)), ] * int(max_ind))
        kx = np.append(kx1, kx2, axis=1) * 2 * np.pi

        ky = np.transpose(kx)
        k = np.sqrt(kx ** 2 + ky ** 2) / (pix * max_ind)

        # fourier transforms of displacement (step 3)
        u_ft = np.fft.fft2(u_expand * pix)
        v_ft = np.fft.fft2(v_expand * pix)
        # calculate angle between k and kx
        alpha = np.arctan2(ky, kx)
        alpha[0, 0] = np.pi / 2

        # calculation of K tensor to calculate traction, inverse of K is calculated
        # k^(-1) = [[kix kid],
        #          [kid, kiy]]
        kix = ((k * E) / (2 * (1 - s ** 2))) * (1 - s + s * np.cos(alpha) ** 2)
        kiy = ((k * E) / (2 * (1 - s ** 2))) * (1 - s + s * np.sin(alpha) ** 2)
        kid = ((k * E) / (2 * (1 - s ** 2))) * (s * np.sin(alpha) * np.cos(alpha))

        # add zeros in diagonal
        kid[:, int(max_ind / 2)] = np.zeros(max_ind)
        kid[int(max_ind / 2), :] = np.zeros(max_ind)

        # fourier transform of displacements
        u_ft = np.fft.fft2(u_expand * pix)
        v_ft = np.fft.fft2(v_expand * pix)

        # tractions in fourier space - T = k^(-1) * U where U = [u, v]
        tx_ft = kix * u_ft + kid * v_ft
        ty_ft = kid * u_ft + kiy * v_ft

        # go back to real space

        tx = np.fft.ifft2(tx_ft).real
        ty = np.fft.ifft2(ty_ft).real

        tx_cut = tx[0:ax1_length, 0:ax2_length]
        ty_cut = ty[0:ax1_length, 0:ax2_length]



