import numpy as np
import matplotlib.pyplot as plt


def display_vector_field(x, y, u, v, window_size, image=None, cmap="viridis"):
    """
    :param cmap: colormap for vectors, default 'viridis'
    :param x: x locations of vectors
    :param y: y locations of vectors
    :param u: x component of vector length
    :param v: y component of vector length
    :param window_size: window size that was used in PIV
    :param image: optional, an image that the vector field will be displayed on
    :return: fig and ax, they can be used or you can simply put plt.show() after the function call
    """
    fig, ax = plt.subplots()
    xmax = np.amax(x) + window_size / 2
    ymax = np.amax(y) + window_size / 2
    mag = np.sqrt(u ** 2 + v ** 2)
    if image is not None:
        ax.imshow(image, extent=[0.0, xmax, 0.0, ymax], cmap="gray")
        quiv = ax.quiver(x, y, u, v, mag, cmap=str(cmap))
        fig.colorbar(quiv)
    else:
        quiv = ax.quiver(x, y, u, v, mag, cmap=str(cmap))
        fig.colorbar(quiv)
    return fig, ax


def display_heatmap(x, y, u, v):
    """
    :param x: x coordinates of window centers
    :param y: y coordinates of window centers
    :param u: x component of displacement/traction vectors
    :param v: y component of displacement/traction vectors
    :return: fig and ax object, can use plt.show()
    """
    intensity = np.sqrt(u ** 2 + v ** 2)
    fig, ax = plt.subplots()
    ax.pcolormesh(x, y, intensity, shading="auto")
    return fig, ax
