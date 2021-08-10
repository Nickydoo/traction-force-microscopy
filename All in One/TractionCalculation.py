import numpy as np
from scipy.ndimage.filters import gaussian_filter


def fttc(u, v, E, s, pix, pix_new):
    """
    Calculates traction field using regularized fourier transform traction cytometry
    :param u: deformation field in x direction
    :param v: deformation field in y direction
    :param E: Young's modulus
    :param s: Poisson's ratio
    :param pix: pixel size of image (from microscope), m/pixel
    :param pix_new: pixel size of deformation field, equal to pix*mean(after_image.shape / u.shape), m/pixel
    :return: traction fields in x and y directions
    """
    v *= -1
    u_shift = (u - np.mean(u))
    v_shift = (v - np.mean(v))
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
    # F(kx) = 1/2pi * integral(e^(i*kx*x))dk

    ky = np.transpose(kx)
    k = np.sqrt(kx ** 2 + ky ** 2) / (pix_new * max_ind)
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
    fs = max_ind / 50
    tx_filter = gaussian_filter(tx_cut, sigma=fs)
    ty_filter = gaussian_filter(ty_cut, sigma=fs)
    return tx_filter, ty_filter


def strain_energy(u, v, tx, ty, pixelsize, newpixelsize, mask):
    """
    :param u: deformation field in x direction
    :param v: deformation field in y direction
    :param tx: x tractions
    :param ty: y tractions
    :param pixelsize: pixel size of original image, from microscope (units m/pixel)
    :param newpixelsize: pixel size of deformation field (units m/pixel)
    :param mask: optional mask of cell area
    :return: total strain energy or strain energy in mask
    """
    energy = ((newpixelsize ** 2) / 2) * (tx * u * pixelsize + ty * v * pixelsize)
    background = np.percentile(energy, 20)
    energy -= background
    if mask is not None:
        return np.sum(energy[mask])
    else:
        return np.sum(energy)


def contractility(x, y, tx, ty, pixelsize, mask):
    """
    :param x: x coordinate of window centers
    :param y: y coordinate of window centers
    :param tx: x tractions
    :param ty: y tractions
    :param pixelsize: pixel size of deformation/traction field in m/pixel
    :param mask: optional mask of cell area
    :return: contractile force in Newtons
    """
    mask_area = np.sum(mask) * pixelsize ** 2
    tx_filter = tx.copy()
    ty_filter = ty.copy()
    tx_filter[~mask] = 0
    ty_filter[~mask] = 0
    fx = tx_filter * mask_area
    fy = ty_filter * mask_area

    traction_mags = np.sqrt(tx_filter ** 2 + ty_filter ** 2)
    bx = np.sum(x * (traction_mags ** 2) + fx * (tx_filter * fx + ty_filter * fy))
    by = np.sum(y * (traction_mags ** 2) + fy * (tx_filter * fx + ty * fy))
    axx = np.sum(traction_mags ** 2 + fx ** 2)
    axy = np.sum(fx * fy)
    ayy = np.sum(traction_mags ** 2 + fy ** 2)
    A = np.array([[axx, axy], [axy, ayy]])
    b = np.array([bx, by]).T
    center = np.matmul(np.linalg.inv(A), b)
    dist_x = center[0] - x
    dist_y = center[1] - y
    dist_abs = np.sqrt(dist_y ** 2 + dist_x ** 2)
    proj_abs = (fx * dist_x + fy * dist_y) / dist_abs
    contractile_force = np.nansum(proj_abs)
    return contractile_force
