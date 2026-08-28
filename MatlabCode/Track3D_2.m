function [SpotsCh1,SpotsCh2,topsmatched,bottomsmatched,xyzPoints ,SpotsTrajtop,SpotsTrajbottom,fl_stack,bf_stack]=Track3D_2(filename,linkcons,n,pixsize,corr_coeff,p,use_calib,rampcalibdata,symcalibdata,calibmap,tolfactor,minCorr,addextra)
% TRACK3D_2
% Opens .tiff files and tracks them using ADEMS code, then applies linking
% routines either with or without a calibration. Uses Everything4 to do the
% tracking for files with a calibration - this uses  proximity rather than
% correlation to determine possible matches.
%
% INPUTS
% FILENAME     - The name of the .tiff stack being tracked
% LINKCONS     - params for linking
% N            - number of steps that can be jumped
% PIXSIZE      - size of pixels in nm
% CORR_COEFF   - threshold correlation to accept the particles as the same.
%                range [-1 1]. 1 is most correlated
% P            - pstructure for spot finding using ADEMS code. (N.B. ADEMS 
%                code spits out a linking but that is discarded here in 
%                favour of my own linking routines). 
% USE_CALIB    - Switch. 1 to use the previous calibration data. 0 to not.
% RAMPCALIBDATA- The calibration data part 1
% SYMCALIBDATA - The calibration data part 2
% CALIBMAP     - The mapping between top and bottom images found according
%                to the user matched up localisations in the calibration
%                frame
% TOLFACTOR    - the number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% MINCORR      - minimum number of localisations in tracks to try
%                correlation. Use 2 for maximum  data linkage, but a higher
%                value if you have noise on otherwise clear tracks.
% ADDEXTRA     - A switch to look for missing localisations in the last
%                step of making 3D trajectories
%
% OUTPUTS
% SPOTSCH1     - top spots 
% SPOTSCH2     - bottom spots
% TOPSMATCHED  - top spots with column linking localisations in top and
%                bottom images
% BOTTOMSMATCHED- bottom spots with column linking localisations in top and
%                bottom images
% XYZPOINTS    - x,y,z,frame no, traj no of found trajectories
% SPOTSTRAJTOP - the trajectories found for spotsch1
% SPOTSTRAJBOTTOM- the trajectories found for spotsch2
% FL_STACK     - The fluorescent parts of the images, in a .mat file so
%                they can be used without reloading the images
% BF_STACK     - The BF part of the image, in a .mat file so it can be used
%                without reloading the image. (5 images) This assumes that
%                the files passed to the code are brightfield than a period
%                of dark, then fluorescence.
%
% example code: 
% Track3D('Image_file',[350 0.01 100], 2,51.5,0.5,p,1,rampcalibdata,symcalibdata,calibmap,5,2)
%
% Helen Miller April 2020. The coronavirus lockdown.

%need to extract image data first to rotate.
[numFrames, ~, ~, image_data, ~] = ExtractImageSequence3(filename, p.all, p.startFrame, p.endFrame);
rotimage1=rot90(image_data,1);
rotimage=flipud(rotimage1);
[SpotsCh1, SpotsCh2,frame_average,p, meta_data, image_data,firstLeft,firstRight] = ADEMScode2_0_vanilla_HM(rotimage,p);
if use_calib==0
[topsmatched,bottomsmatched,xyzPoints ,SpotsTrajtop,SpotsTrajbottom ] = everythingrough3( SpotsCh1,SpotsCh2,0, linkcons,n,pixsize,corr_coeff,firstLeft,firstRight,minCorr);
elseif use_calib==1
%[topsmatched,bottomsmatched,xyzPoints,SpotsTrajtop,SpotsTrajbottom  ] = everything3(SpotsCh1,SpotsCh2,0, linkcons,n,pixsize,corr_coeff,firstLeft,firstRight,rampcalibdata,symcalibdata,calibmap,tolfactor,minCorr);
[topsmatched,bottomsmatched,xyzPoints,SpotsTrajtop,SpotsTrajbottom  ] = everything4(SpotsCh1,SpotsCh2,0, linkcons,n,pixsize,firstLeft,firstRight,rampcalibdata,symcalibdata,calibmap,tolfactor,minCorr,addextra);
end
%make fluorimage stack
fl_stack=image_data(:,:,firstLeft:end);
%make bf stack assuming 5 bf images at start (NB changed to work when you
%tell to look for fluorescence from 50t frame
[~, ~, ~, bf_stack, ~] = ExtractImageSequence3(filename, 0, 1, 5);
end