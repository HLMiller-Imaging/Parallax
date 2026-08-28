After following the instructions in README_1 you should have successfully produced a folder called 'Analysis'.

So now, let's explain what it is doing, and how you can create your own calibration file.

The main tracking code is called TrackFolder2_noSIM. It tracks a whole folder of tiffs using a calibration file to work out z. 
It assumes that the calibration data are in a standard format.

The standard format is hard coded into TrackFolder2_noSim in lines 111 and 113, but could be changed if needed
(see calibratez4 documentation if interested).

The expected format of the calibration image is that it is set up so that the test object is stationary for 6 frames, then 
there are two frames where it slews to the next position. There should be 21 equally spaced stationary positions looped 
through, at 50.4nm height intervals, going first up then down. There should be 600 frames in total. For example, 1 second stationary
then 0.2s of slew covered by 8 images will work, or equivalent ratios. It does not matter where in the amplitude ramp the firt image is. 
You can see an example of z height vs frame number in 'example_file3.png'; the x axis is frame number and the y axis is the z position in 
arbitrary units. You should have an identical graph named '3.png' in your test analysis file created by following README1.

One way to make a calibration image file in this format is to use my LabView code, 'generatezlines_slower'.
You will need to have LabView including the NI DAQ toolbox and a piezo stage on your microscope attached
to an NI DAQ rack, and a camera controlled by Andor Solis to use this.
Run the Labview code by double clicking its' icon. Change the parameters as instructed in the file to:
1) connect to your piezo
2) set amplitude to 504nm
3) set z offset to 504nm, other offsets 0
4) sampling frequency to 250Hz

Next, set your camera to acquire 600 frames with the frame rate at 6.667Hz. As frame rate cannot be adjusted 
directly, you need to modify exposure time until you get this frame rate. The corresponding exposure time
does depend on the size of the image you are acquiring (best to adjust the frame size to just what you need).

The next thing to do is get your test object lined up to take the calibration. You can use my method in the rest of this paragraph,
or develop your own and rejoin this method at the following paragraph. I use 200nm fluorescent 
beads stuck down on a coverslip as a test sample. I first focus the beads with no Labview program running so they are in about 
the right place. Then, I set the generatezlines_slower running with sampling frequency 250Hz and a normal (~0.1Hz) frame rate 
in Solis. This moves the beads fast enough to see. I adjust the focus until the beads look like they move the same distance past 
the centre in each direction. When I am happy I press the big 'stop' button on the Labview, change the camera settings to what is 
needed for calibration, and when Labview stops I change settings to those for calibration.

Now, press 'run' in the LabView program. After about 40s you will see the voltage output graph move to steps. As soon 
as you see this, press acquire in Andor Solis. This image is your calibration file :)

NB It is very important that all images using the Piezo have the feedback loop switched on (on piezo controller, 'servos on')

You can now acquire data. Once you have data move on to README3 for how to track it.

NB A common problem is that the calibration file is not good enough quality and you cannot establish a good calibration. 
Common reasons are a dropped frame on the camera or the test object moving too far beyond focus and not being tracked because 
the test object was not correctly centred. I usually acquire 2 or 3 calibrations at a time to guard against this.