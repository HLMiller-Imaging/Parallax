function[TopCalibLoc,BottomCalibLoc]=MakeMeACalib(rotimage,p_calib,pixsize,linkcons)
%MAKEMEACALIB
% stitches together bits of tracking from a calibration data set if a
% continuous track was not found in checkcalib
% INPUTS
% Pairings - the user defined pairing data column 1 is the top traj no and
%            column 2 is the bottom traj no
% calibtop - the top spot localisations from ADEMS code reshaped using
%            ADEMS2TSCalib
% calibbottom - the bottom spot localisations from ADEMS code reshaped using
%            ADEMS2TSCalib
% nframes - number of frames in the calibration data
%
% OUTPUTS
% TopCalibLoc - the top localisation that is chosen for the calibration 
% BottomCalibLoc - the bottom localisation that is chosen for the
%                  calibration
%
% example code [TopCalibLoc, BottomCalibLoc]=MakeMeACalib(Pairings,calibtop,calibbottom,600)
%
% Helen Miller November 2020

%go back and track the calib in cursor mode
close all
p_calib.use_cursor=1;
[SpotsCh1, SpotsCh2,~,~, ~, ~,~,~] = ADEMScode2_0_vanilla_HM(rotimage,p_calib);
[TopCalibLoc]=ADEMS2TSCalib(SpotsCh1,pixsize,linkcons);
[BottomCalibLoc]=ADEMS2TSCalib(SpotsCh2,pixsize,linkcons);

end