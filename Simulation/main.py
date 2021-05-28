import numpy as np
import matplotlib.pyplot as plt
# from openpiv.pyprocess import extended_search_area_piv, get_coordinates
# from openpiv.validation import sig2noise_val
# from openpiv.filters import replace_outliers
from calculate_traction import reg_fttc
from pyTFM_trial import get_displacements
from plotting import show_quiver


before_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well001.png"
after_image_path = r"C:\Users\sbrown\Documents\GitHub\traction-force-microscopy\Data\C1-middle well002.png"
before_image = plt.imread(before_image_path).astype(np.int32)
after_image = plt.imread(after_image_path).astype(np.int32)

displacement_dict = get_displacements(before_image, after_image, 32, 64)
u, v = displacement_dict["u"], displacement_dict["v"]
print(u)
# tx, ty = reg_fttc(u, v, 1, 4000, 0.49, 0.12, False)



