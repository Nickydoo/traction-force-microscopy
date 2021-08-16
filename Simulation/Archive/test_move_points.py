from my_utils import raw_points_grid, get_x_y
import matplotlib.pyplot as plt
import numpy as np
mat = raw_points_grid(1608, 1)
orig_mat = mat.copy()
quarter_length = mat.shape[0]//4
sub = mat[quarter_length:3*quarter_length, quarter_length:3*quarter_length].copy()
first_half = sub[len(sub)//4:len(sub)//2, :].copy()
second_half = sub[3*len(sub)//4: , :]
shift_down = np.roll(np.identity(len(first_half)), -1)
shift_up = np.roll(np.identity(len(second_half)), 1)
shift_up[:, -1] = 0
shift_down[:, -1] = 0
shifted_down = shift_down@first_half
shifted_up = shift_up@second_half
sub[len(sub)//4:len(sub)//2, :] = shifted_down
sub[3*len(sub)//4:, :] = shifted_up
mat[quarter_length:3*quarter_length, quarter_length:3*quarter_length] = sub
plt.subplot(121)
plt.imshow(orig_mat)
plt.subplot(122)
plt.imshow(mat)
plt.show()

