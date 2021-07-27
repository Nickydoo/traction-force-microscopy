import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as anim
from celluloid import Camera

data = list(np.load("dynamics_win50_thresh1.npy"))
# (x, y, tx, ty)
x = []
y = []
tx = []
ty = []
for points in data:
    x.append(points[0])
    y.append(points[1])
    tx.append(points[2])
    ty.append(points[3])

# fig, ax = plt.subplots()
# x0 = x[0]
# y0 = y[0]
# tx0 = tx[0]
# ty0 = ty[0]
# qr = ax.quiver(x0, y0, tx0, ty0)
# arr = np.zeros_like(tx0)
# def animate(frame, quiv, t_x, t_y):
#     quiv.set_UVC(t_x[frame], t_y[frame])
#     ax.set_title(f"Frame {frame}")
#     return qr,
#
# ani = anim.FuncAnimation(fig, animate, fargs=(qr, tx, ty), blit=False)
#
# plt.show()

fig = plt.figure()
camera = Camera(fig)
for i in range(len(tx)):
    plt.quiver(x[i], y[i], tx[i], ty[i])
    camera.snap()
    print(i)
animation = camera.animate()

