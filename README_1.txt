Code for extracting data from parallax microscopy images, assuming a calibration of 504nm 

This repository contains Matlab code to extract 3D microscopy data from images collected using parallax microscopy.

This code is as it was used in 2022, on MATLAB r2020b.

Included in this bundle is ADEMs code, which was written by Adam Wollman https://doi.org/10.1016/j.ymeth.2015.01.010 . Please
see his Github for more detail https://github.com/awollman?tab=repositories

This code runs in the command line. To run the test files and check everything is working:
1. copy the 'MatlabCode' folder to your computer
2. change the matlab filepath using 'Add with subfolders' to go to the 'MatlabCode' folder,
3. in Matlab, navigate the working directory to 'TestFiles' and load in 'testparams.mat'
4. in the command line type:

TrackFolder2_noSIM('Analysis',[500 0.01 100],2,51.5,0.9,p,CalibFileName,p_calib,5,2,1)

5. !The code does ask for user input, so do not leave until the message telling you that you can!


6. This should complete without errors and form a folder called 'Analysis' in 'TestFiles'. If this works,
move on to README_2 instructions. If it doesn't, please contact me through Github with the error code you
are receiving.

