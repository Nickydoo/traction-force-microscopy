#
# plt.show()
# plt.subplot(121)
# plt.imshow(filtered_projection, cmap="gray")
# plt.plot(p_x, p_y, 'r.')
# plt.subplot(122)
# plt.imshow(only_maxima(filtered_projection, p_x, p_y), cmap="gray")
# plt.show()


# maxima = [find_maxima_skimage(i, 1) for i in ims]
# xs = [tup[0] for tup in maxima]
# ys = [tup[1] for tup in maxima]
# z = np.linspace(0, 7.4, 37)
# fig = plt.figure()
# ax = fig.gca(projection="3d")
# for i in range(20, 22):
#     ax.scatter(xs[i], ys[i], z[i], depthshade=True)
# plt.show()

# plt.imshow(ims[20])
# plt.show()

# XYZ = np.array([p_x, p_y, z])
# guess = [0, 0, 40, 2]  # A, B, C, D in Ax + By + Cz = D
#
#
# def f_min(X, p):
#     plane_xyz = p[0:3]
#     distance = (plane_xyz * X.T).sum(axis=1) + p[3]
#     return distance / np.linalg.norm(plane_xyz)
#
#
# def residuals(params, signal, X):
#     return f_min(X, params)
#
#
# sol = leastsq(residuals, guess, args=(None, XYZ))
# print(f'Parameters of plane are: {sol[0]}')
# print(f'Cost function is {sol[1]}')
# print(f'Optimization successful: {sol[-1]}')
# print(f'Error is: {(f_min(XYZ, sol[0]) ** 2).sum()}')
#
#
# def plane(params, x, y):
#     A, B, C, D = params
#     return (D - A * x - B * y) / C

# x = y = np.linspace(0, 2048, 100)
# X, Y = np.meshgrid(x, y)
# zs = np.array(plane(sol[0], X.ravel(), Y.ravel()))
# Z = zs.reshape(X.shape)