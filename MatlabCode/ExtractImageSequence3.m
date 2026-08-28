function [numFrames, frame_Ysize, frame_Xsize, image_data, image_path] = ExtractImageSequence3(image_label, all, startFrame, endFrame)
% EXTRACTIMAGESEQUENCE3
% A function that extracts multipage tifs and outputs an array 
% Based on a function from Adam Wollman's code (ADEMS code)
%
% INPUTS
% image_label    string for image to load
% all            switch; 1 =whole image is loaded, else loads from optional 
%                startFrame to endFrame
% startFrame     if all isn't set to one, this is the first frame loaded
% endFrame       if all isn't set to one, this is the last frame loaded 
% image_label is the number before the file extension of the tif
%
% OUTPUTS
% numFrames      the number of frames loaded
% frame_Ysize    The number of pixels on the y axis
% frame_Xsize    The number of pixels on the x axis
% image_data     The array of image files; image_data(:,:,1) is the first
%                frame
% image_path     The file path to the image
%
% EXAMPLE CODE
% To load an entire tif image called test.tif that is in the working folder
% and only retain the image as an array called image_data
% [~, ~, ~, image_data, image_path] = ExtractImageSequence3('test', 1, 0, 0)
% To load only frame 9 of test.tif
% [~, ~, ~, image_data, image_path] = ExtractImageSequence3('test', 0, 9, 9)
%

filePath=dir(strcat('*',image_label,'.tif'));
filePath.name
%if isempty(strfind(filePath.name,'tif'))==0
    tifImagePath0 = dir(strcat(image_label,'.tif'));
    % Error control if no .tif file can be found with that label.
    if isempty(tifImagePath0) % If there is no .tif image sequence file for such image_label, show error and exit function:
        error('Check you are in the correct directory and run again. No .tif file found for that image_label.');
    end
    %else if image is found:
    image_path = tifImagePath0.name;
    InfoImage=imfinfo(image_path);
    frame_Ysize=InfoImage(1).Width;
    frame_Xsize=InfoImage(1).Height;
    numFrames=length(InfoImage);
    
    if all==0 %extract only certain frames
        image_data=zeros(frame_Xsize,frame_Ysize,endFrame-startFrame+1,'uint16');
        for i=1:endFrame-startFrame+1
            image_data(:,:,i)=imread(image_path,i+startFrame-1);
        end
    else %extract all the frames
        image_data=zeros(frame_Xsize,frame_Ysize,numFrames,'uint16');
        for i=1:numFrames

            image_data(:,:,i)=imread(image_path,i);
        end
    end
% elseif isempty(strfind(filePath.name,'asc'))==0
%     M=dlmread(filePath.name);
%     frame_Xsize=length(unique(M(:,1)));
%     frame_Ysize=size(M,2)-1;
%     numFrames=size(M,1)/frame_Xsize;
%       image_path=pwd;
%     image_data=zeros(frame_Xsize,frame_Ysize,numFrames);
%     for i=1:numFrames
%        image_data(:,:,i)= M(1+(i-1)*512:i*512,2:end);
%     end
%     image_data(:,513,:)=[];
% else
%     if filePath.isdir==1
%         cd(filePath.name)
%         TifNames=dir('*.tif');
%         InfoImage=imfinfo(TifNames(1).name);
%         image_path=pwd;
%         frame_Ysize=InfoImage(1).Width;
%         frame_Xsize=InfoImage(1).Height;
%         numFrames=length(TifNames);
%         image_data=zeros(frame_Xsize,frame_Ysize,numFrames,'uint16');
%         for k=1:length(TifNames)
%             image_data(:,:,k)=imread(TifNames(k).name);
%         end
%         cd ..
%     end
% end

end