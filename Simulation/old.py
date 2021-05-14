def move_points(mat, move_by_px_up, move_by_px_down):
    """
    :param move_by_px_down: Amount to move each dot by in the down direction
    :param mat: matrix
    :param move_by_px_up: Amount to move each dot by in the up direction
    :return: Unfiltered array of moved points
    """
    positions = mat.copy()
    rows = cols = len(positions)
    quarter_size = int(rows / 4)
    second_quarter_start = 0 + quarter_size
    second_quarter_end = second_quarter_start + quarter_size
    third_quarter_start = second_quarter_end + 1
    third_quarter_end = third_quarter_start + quarter_size
    for row in range(second_quarter_start, second_quarter_end):
        for col in range(cols):
            if positions[row][col] == 1:
                positions[row - move_by_px_up][col] = 1
                positions[row][col] = 0
    for row in range(third_quarter_start, third_quarter_end):
        for col in range(cols):
            if positions[row][col] == 1:
                positions[row + move_by_px_down][col] = 1
                positions[row][col] = 0
    return positions

def create_image(res, sf, make_plot=True, return_array=True, save_image=True):
    """
    :param save_image: whether or not to save image
    :param return_array: whether or not to return arrays of original positions and filtered beads
    :param res: resolution of image, nominally 1608x1608
    :param sf: scale factor to allow for sub-pixel resolution
    :param make_plot: whether or not to display matplotlib plot
    """
    resolution = res * sf
    x = np.random.randint(low=0, high=resolution, size=resolution)
    y = np.random.randint(low=0, high=resolution, size=resolution)
    mat = np.zeros((resolution, resolution))
    mat[x, y] = 1
    mat2 = nd.gaussian_filter(mat, sigma=5.0, order=0)
    if save_image:
        plt.imsave("gaussian_image.png", mat2, cmap="gray")
    if make_plot:
        def numfmt(x, pos):
            s = "{}".format(x / sf)
            return s

        fmt = tkr.FuncFormatter(numfmt)
        fig, axes = plt.subplots(1, 2)
        axes[0].imshow(mat, cmap="gray", interpolation="nearest")
        axes[1].imshow(mat2, cmap="gray")
        for i in range(len(axes)):
            axes[i].xaxis.set_major_formatter(fmt)
            axes[i].yaxis.set_major_formatter(fmt)
        plt.show()
    if return_array:
        return mat, mat2

def find_maxima_manual(img, show_plots=True):
    neighborhood_size = 10
    t = 2  # weight for avg intensity
    avg_intensity = t * np.average(img)  # 0 is black and 1 is white, you can just average the values of the entire img
    data_max = nd.filters.maximum_filter(img, neighborhood_size)
    maxima = (img == data_max)
    diff = (data_max - avg_intensity) > 0
    maxima[diff == 0] = 0
    labeled, num_objects = nd.label(maxima)
    slices = nd.find_objects(labeled)
    x, y = [], []
    for dy, dx in slices:
        x_center = (dx.start + dx.stop - 1) / 2
        x.append(x_center)
        y_center = (dy.start + dy.stop - 1) / 2
        y.append(y_center)
    print(x[100:120])
    # print(y[100])
    # new_mat = np.zeros_like(img)
    # new_mat[x, y] = 1
    if show_plots:
        fig, ax = plt.subplots(1, 2)
        ax[0].imshow(img, cmap="gray")
        ax[0].title.set_text("Regular Image")
        ax[1].imshow(maxima, cmap="gray")
        ax[1].title.set_text("Local Maxima")
        plt.show()
    return maxima


def make_plots(raw_arrays, gaussian_arrays, sf):
    def numfmt(x, pos):
        s = "{}".format(x / sf)
        return s

    fmt = tkr.FuncFormatter(numfmt)
    fig, axes = plt.subplots(len(gaussian_arrays), len(raw_arrays))
    for i in range(len(raw_arrays)):
        axes[0, i].imshow(raw_arrays[i], cmap="gray", interpolation="nearest")
        axes[0, i].title.set_text(f'Raw Array {i}')
    for i in range(len(gaussian_arrays)):
        axes[1, i].imshow(gaussian_arrays[i], cmap="gray")
        axes[1, i].title.set_text('Gaussian Array')
    for i in range(len(axes)):
        for j in range(len(axes)):
            axes[i, j].xaxis.set_major_formatter(fmt)
            axes[i, j].yaxis.set_major_formatter(fmt)
    plt.show()

def find_maxima_matlab(im, sz=0):
    """
    Calls pkfnd matlab function, which has arguments pkfnd(im, th, sz)
    :param im: the image
    :param sz: Not sure
    :return: x and y coordinates of local maxima on the image
    """
    octave.addpath("/home/sam/Documents/MATLAB")
    my_im = plt.imread(im)
    t = 1  # scale factor for threshold
    th = t * np.average(my_im)
    out = octave.pkfnd_octave(my_im, th, sz)
    return out