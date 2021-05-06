import numpy as np

np.random.seed(1)


def raw_points_grid(res, sf):
    """
    :param res: Resolution
    :param sf: Scale factor
    :return: matrix
    """
    resolution = res * sf
    x = np.random.randint(low=0, high=resolution, size=resolution)
    y = np.random.randint(low=0, high=resolution, size=resolution)
    mat = np.zeros((resolution, resolution))
    mat[x, y] = 1
    return mat


def ellipse(u, v, a, b):
    """
    :param u: x position of center
    :param v: y position of center
    :param a: radius in x direction
    :param b: radius in y direction
    :return: v1: vector of x coordinates, v2: vector of y coordinates
    """
    t = np.linspace(0, 2 * np.pi, 100)
    v1 = u + a * np.cos(t)
    v2 = v + b * np.sin(t)
    # oval_x, oval_y = ellipse(1608 / 2 * scale_factor, 1608 / 2 * scale_factor, 200 * scale_factor, 300 * scale_factor)
    return v1, v2
