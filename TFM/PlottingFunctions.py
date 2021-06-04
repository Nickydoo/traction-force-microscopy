import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from PlottingUtils import set_vmin_vmax, filter_values, scale_for_quiver, add_colorbar


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


def display_vector_field(x, y, u, v, window_size, image=None):
    fig, ax = plt.subplots()
    xmax = np.amax(x) + window_size / 2
    ymax = np.amax(y) + window_size / 2
    mag = np.sqrt(u ** 2 + v ** 2)
    if image is not None:
        ax.imshow(image, extent=[0.0, xmax, 0.0, ymax])
        quiv = ax.quiver(x, y, u, v, mag)
        fig.colorbar(quiv)
    else:
        quiv = ax.quiver(x, y, u, v, mag)
        fig.colorbar(quiv)
    return fig, ax


def show_quiver(fx, fy, filter=[0, 1], scale_ratio=0.2, headwidth=None, headlength=None, headaxislength=None,
                width=None, cmap="rainbow",
                figsize=None, cbar_str="", ax=None, fig=None
                , vmin=None, vmax=None, cbar_axes_fraction=0.2, cbar_tick_label_size=15
                , cbar_width="2%", cbar_height="50%", cbar_borderpad=0.1
                , cbar_title_pad=1, plot_cbar=True, alpha=1,
                ax_origin="upper", filter_method="regular", filter_radius=5, **kwargs):
    # list of all necessary quiver parameters
    quiver_parameters = {"headwidth": headwidth, "headlength": headlength, "headaxislength": headaxislength,
                         "width": width, "scale_units": "xy", "angles": "xy", "scale": None}
    quiver_parameters = {key: value for key, value in quiver_parameters.items() if not value is None}

    fx = fx.astype("float64")
    fy = fy.astype("float64")
    dims = fx.shape  # needed for scaling
    if not isinstance(ax, matplotlib.axes.Axes):
        fig = plt.figure(figsize=figsize)
        ax = plt.axes()
    map_values = np.sqrt(fx ** 2 + fy ** 2)
    vmin, vmax = set_vmin_vmax(map_values, vmin, vmax)
    im = plt.imshow(map_values, cmap=cmap, vmin=vmin, vmax=vmax, alpha=alpha, origin=ax_origin)  # imshowing
    ax.set_axis_off()
    # plotting arrows
    # filtering every n-th value and every value smaller then x
    fx, fy, xs, ys = filter_values(fx, fy, abs_filter=filter[0], f_dist=filter[1], filter_method=filter_method,
                                   radius=filter_radius)
    if scale_ratio:  # optional custom scaling with the image axis lenght
        fx, fy = scale_for_quiver(fx, fy, dims=dims, scale_ratio=scale_ratio)
        quiver_parameters["scale"] = 1  # disabeling the auto scaling behavior of quiver
    plt.quiver(xs, ys, fx, fy, **quiver_parameters)  # plotting the arrows
    if plot_cbar:
        add_colorbar(vmin, vmax, cmap, ax=ax, cbar_width=cbar_width, cbar_height=cbar_height,
                     cbar_borderpad=cbar_borderpad, v=cbar_tick_label_size, cbar_str=cbar_str,
                     cbar_axes_fraction=cbar_axes_fraction, cbar_title_pad=cbar_title_pad)
    return fig, ax
