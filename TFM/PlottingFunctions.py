import numpy as np
import matplotlib.pyplot as plt


def process_mask(orig_mask, vector_shape: tuple, cell_size_approx):
    from skimage.morphology import remove_small_holes, remove_small_objects
    from scipy.ndimage.morphology import binary_closing, binary_fill_holes
    mask = orig_mask.copy().astype(bool)
    mask = binary_fill_holes(mask)
    mask = remove_small_holes(mask, cell_size_approx)
    mask = remove_small_objects(mask, 1000)
    coords = np.array(np.where(mask)).astype(float)
    factors = np.array([vector_shape[0] / mask.shape[0], vector_shape[1] / mask.shape[1]])
    coords[0] = coords[0] * factors[0]
    coords[1] = coords[1] * factors[1]
    coords = np.round(coords).astype(int)
    coords[0, coords[0] >= vector_shape[0]] = vector_shape[0] - 1
    coords[1, coords[1] >= vector_shape[1]] = vector_shape[1] - 1
    mask_int = np.zeros(vector_shape)
    mask_int[coords[0], coords[1]] = 1
    mask_int = mask_int.astype(int)
    # filling gaps if we interpolate upwards
    if vector_shape[0] * vector_shape[1] >= mask.shape[0] * mask.shape[1]:
        mask_int = binary_closing(mask_int, iterations=10)
    return mask_int.astype(bool)


def vector_plot(u_orig, v_orig):
    u = u_orig.copy()
    v = v_orig.copy()
    u = u.astype(np.float64)
    v = v.astype(np.float64)
    vals = np.sqrt(u ** 2 + v ** 2)
    fig, ax = plt.subplots()
    my_cbar = ax.imshow(vals)
    x = np.arange(np.shape(u_orig)[0])
    y = np.arange(np.shape(u_orig)[1])
    X, Y = np.meshgrid(x, y)
    ax.quiver(X, Y, u, v)
    plt.colorbar(my_cbar)
    return fig, ax
