function [CalibMap]=CreateCalibMap(TopCalibLoc,BottomCalibLoc)
%creates a mapping from the user made pairings so possibly correlated
%tracks can be decided between later. Written as it's own function despite
%being simple so I can make it better at another time if wanted.
%
%INPUTS
% TopCalibLoc - the top localisation that is chosen for the calibration 
% BottomCalibLoc - the bottom localisation that is chosen for the
%                  calibration
%
%OUTPUTS
% CALIBMAP - values to subtract from the toploc to find where you expect
%           the bottom loc to be
%
% example code [CalibMap]=CreateCalibMap(TopCalibLoc,BottomCalibLoc,Pairings)
%
% Helen Miller March 2020

Diffy=BottomCalibLoc(1,4)-TopCalibLoc(1,4);
Diffx=BottomCalibLoc(1,3)-TopCalibLoc(1,3);

CalibMap=[Diffx Diffy];
end