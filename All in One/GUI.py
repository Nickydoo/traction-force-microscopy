import PySimpleGUI as sg

def stage_correction_gui(im1, im2):
    layout = [[sg.Text(f"Before Image Path: {im1}")],
              [sg.Text(f"After Image Path: {im2}")],
              [sg.Button("1")]]
    window = sg.Window("Stage Correction", layout)
    while True:  # Event Loop
        event, values = window.read()
        if event in (None, 'Exit'):
            break

before_photo = sg.popup_get_file("Select the BEFORE photo (strained substrate)")
after_photo = sg.popup_get_file("Select the AFTER photo (unstrained substrate)")

stage_correction_gui(before_photo, after_photo)