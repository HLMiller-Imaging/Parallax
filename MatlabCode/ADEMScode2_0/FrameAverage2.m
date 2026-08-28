function [frame_average] = FrameAverage2(image_data, noFrames, startFrame,ALEX)

% Calculates a frame average of image_data array starting at startFrame
% over noFrames
%Start frame should mostly be firstLeft from LaserOn
if ALEX==0
    frame_average=mean(image_data(:,:,startFrame:(startFrame+noFrames)),3);
    frame_average=mat2gray(frame_average);
else
    frame_average(:,:,1)=mean(image_data(:,:,startFrame:2:(startFrame+2*noFrames)),3);
    startFrame=startFrame+1;
    frame_average(:,:,2)=mean(image_data(:,:,startFrame:2:(startFrame+2*noFrames)),3);
    frame_average=mat2gray(frame_average);
end
end