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


def pkfnd(im, sz=None):
    """
    finds local maxima in an image to pixel level accuracy
    provides a rough guess of particle centers
    Inspired by the lmx subroutine of Grier and Crocker's algorithm
    :param im: image to process
    :param sz:
    :return: N x 2 array containing [row, column] coordinates of local maxima
    out[:, 0] are the x-coordinates of the maxima
    out[:, 1] are the y coordinates of the maxima
    Adapted from Eric R. Dufresne MATLAB code
    """
    t = 1.5  # scaling factor for threshold
    th = np.average(im)
    ind = np.where(im > (t * th))[0]
    print([i for i in ind if i != 0])
    print(f'indices shape is {ind.shape}')
    nr, nc = im.shape
    print(f'{nr} rows')
    print(f'{nc} columns')
    n = len(ind)
    if n == 0:
        print("Nothing above threshold")
        return []
    mx = np.array([])
    # convert index from find to row and column
    rc = np.array([np.mod(ind, nr), np.floor(ind / nr) + 1])  # this should have shape ind, 2
    print(f' first weird thing has shape {np.mod(ind, nr).shape}')
    print(f' second weird thing has shape {(np.floor(ind / nr) + 1).shape}')
    print(f'values of first weird thing are {np.mod(ind, nr)[0:10]}')
    print(f'values of second weird thing are {(np.floor(ind / nr) + 1)[0:10]}')
    print(f'x y array has shape {rc.shape}')
    for i in range(n):  # this might have to be n+1, check later
        r = rc[0][i]
        c = rc[1][i]
        # print(f'r is {r}')
        # print(f'c is {c}')
        # check each pixel above threshold to see if it's brighter than
        # its neighbors
        if 0 < r < nr and 0 < c < nc:
            """
            if im[r, c] >= im[r - 1, c - 1] and im[r, c] >= im[r, c - 1] and im[r, c] >= im[r + 1, c - 1] and im[
                r, c] >= im[r - 1, c] & im[r, c] >= im[r + 1, c] and im[r, c] >= im[r - 1, c + 1] and im[r, c] >= im[
                r, c + 1] and im[r, c] >= im[r + 1, c + 1]:
            """
            if im[r][c] >= im[r - 1][c - 1] and im[r][c] >= im[r][c - 1] and im[r][c] >= im[r + 1][c - 1] and im[
                r][c] >= im[r - 1][c] & im[r][c] >= im[r + 1][c] and im[r][c] >= im[r - 1][c + 1] and im[r][c] >= im[
                r][c + 1] and im[r][c] >= im[r + 1][c + 1]:
                print("found a maximum")
                mx = np.concatenate([mx, np.concatenate([r, c]).T])
    mx = mx.T
    npks = mx.shape
    print(npks)
    # if size is specified, then get rid of pks within size of boundary
    # if sz is not None and npks > 0:
    #     # throw out all pks within sz of boundary
    #     ind = np.argwhere(sz < mx[:, 0] < (nr - sz) and sz < mx[:, 1] < (nc - sz))
    #     mx = mx[ind, :]
    #     npks = mx.shape
    if npks[0] > 1:
        # create an image with only peaks
        nmx = npks
        tmp = 0 * im
        for i in range(nmx):  # might have to be nmx + 1
            tmp[mx[i, 0], mx[i, 1]] = im[mx[i, 0], mx[i, 1]]
        # look in neighborhood around each peak, pick the brightest
        for i in range(nmx):  # might have to be nmx + 1
            roi = tmp[[mx[i, 0] - np.floor(sz / 2)]:[mx[i, 0] + (np.floor(sz / 2) + 1)],
                  (mx(i, 1) - np.floor(sz / 2)): (
                          mx[i, 1] + (np.floor(sz / 2) + 1))]
            mv, indi = np.max(roi)
            mv, indj = np.max(mv)
            tmp[(mx[i, 0] - np.floor(sz / 2)): (mx[i, 0] + (np.floor(sz / 2) + 1)), (mx[i, 1] - np.floor(sz / 2)): (
                    mx[i, 1] + (np.floor(sz / 2) + 1))] = 0
            tmp[mx[i, 0] - np.floor(sz / 2) + indi[indj] - 1, mx[i, 1] - np.floor(sz / 2) + indj - 1] = mv
        ind = np.argwhere(tmp > 0)
        mx = [ind % nr, np.floor(ind / nr) + 1]
    if mx.shape == (0, 0):
        return []
    else:
        out = []
        out[:, 1] = mx[:, 0]
        out[:, 0] = mx[:, 1]
        return out


def gaussian(height, center_x, center_y, width_x, width_y):
    """Returns a gaussian function with the given parameters"""
    width_x = float(width_x)
    width_y = float(width_y)
    return lambda x, y: height * np.exp(
        -(((center_x - x) / width_x) ** 2 + ((center_y - y) / width_y) ** 2) / 2)


def moments(data):
    """Returns (height, x, y, width_x, width_y)
    the gaussian parameters of a 2D distribution by calculating its
    moments """
    total = data.sum()
    X, Y = np.indices(data.shape)
    x = (X * data).sum() / total
    y = (Y * data).sum() / total
    col = data[:, int(y)]
    width_x = np.sqrt(np.abs((np.arange(col.size) - x) ** 2 * col).sum() / col.sum())
    row = data[int(x), :]
    width_y = np.sqrt(np.abs((np.arange(row.size) - y) ** 2 * row).sum() / row.sum())
    height = data.max()
    return height, x, y, width_x, width_y


def fitgaussian(data):
    """Returns (height, x, y, width_x, width_y)
    the gaussian parameters of a 2D distribution found by a fit"""
    params = moments(data)
    errorfunction = lambda p: np.ravel(gaussian(*p)(*np.indices(data.shape)) -
                                       data)
    p, success = optimize.leastsq(errorfunction, params)
    return p