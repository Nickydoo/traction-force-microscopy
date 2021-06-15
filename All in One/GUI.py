import PySimpleGUI as sg
import matplotlib.pyplot as plt
from utils import correct_shift
from DisplacementTracking import get_displacements
from PlottingFunctions import display_vector_field
from skimage import io
import numpy as np


def myfunc(a, b):
    return a + b


before_photo = sg.popup_get_file("Select the BEFORE photo (strained substrate)")
after_photo = sg.popup_get_file("Select the AFTER photo (unstrained substrate)")
before_image_tif = io.imread(before_photo)
after_image_tif = io.imread(after_photo)
if before_image_tif.ndim == 3 and after_image_tif.ndim == 3:
    before_image_beads = before_image_tif[0, ...].astype(np.int32)
    before_image_cell = before_image_tif[1, ...].astype(np.int32)
    after_image_beads = after_image_tif[0, ...].astype(np.int32)
else:
    before_image_beads = before_image_tif.copy()
    after_image_beads = after_image_tif.copy()
    before_image_cell = None

layout = [[sg.Button("Correct Stage Drift"), sg.Button("Find Displacements"), sg.Button("Calculate Tractions")]]
window = sg.Window("Stage Correction", layout)
while True:  # Event Loop
    event, values = window.read()
    if event in (None, 'Exit'):
        break
    elif event == "Correct Stage Drift":
        before_image_beads, after_image_beads, cell_image = correct_shift(before_image_beads, after_image_beads, before_image_cell)
        plt.subplot(121)
        plt.imshow(before_image_beads, cmap="gray")
        plt.title("Strained substrate")
        plt.subplot(122)
        plt.imshow(after_image_beads, cmap="gray")
        plt.title("Unstrained substrate")
        plt.show()
    elif event == "Find Displacements":
        displacement_dict = get_displacements(before_image_beads, after_image_beads, 150, 60)
        x, y, u, v = displacement_dict["x"], displacement_dict["y"], displacement_dict["u"], displacement_dict["v"]
        display_vector_field(x, y, u, v, 150)
        plt.show()
    elif event == "Calculate Tractions":
        print("krob")