function [] = TrackFolder2_noSIM(OutputFolder,linkcons,n,pixsize,corr_coeff,p,CalibFileName,p_calib,tolfactor,minCorr,addextra)
% TRACKFOLDER2_noSIM
% Tracks a whole folder of tiffs using a calibration file to work out z. 
% This code requires user input to match up the beads in the calibration 
% images. It assumes that the calibration data are in a standard form:
% make_z_lines_slower 12000 250Hz  600 6.667 50.4
% You need to be in the folder with all the tiffs you want to track, and
% load some p structures
% P_calib is used to track the file identified as the calibration to use.
% Any other Calibration files will be tracked like data files.
%
% Changes vs Trackfolder2: No symmetry calibration data is used (it is 
% collected, but then set to zero). This means z is inferred from the cubic
% fit to the calibration and no corrections are made to x or y
%
% INPUTS
% OUTPUTFOLDER - where you want all the analysis put e.g. 'Analysis1'
% LINKCONS     - params for linking
% N            - number of steps that can be jumped
% PIXSIZE      - size of pixels in nm
% CORR_COEFF   - threshold correlation to accept the particles as the same.
%                range [-1 1]. 1 is most correlated
% P            - pstructure for spot finding using ADEMS code. (N.B. ADEMS 
%                code spits out a linking but that is discarded here in 
%                favour of my own linking routines). 
% CALIBFILENAME- The name of the image used for calibration
% P_CALIB      - ADEMS code P structure for use on the calibration data
% TOLFACTOR    - the number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% MINCORR      - minimum number of localisations in tracks to try
%                correlation. Use 2 for maximum  data linkage, but a higher
%                value if you have noise on otherwise clear tracks.
% ADDEXTRA     - A switch to look for missing localisations in the last
%                step of making 3D trajectories
%
% NO OUTPUTS; EVERYTHING IS SAVED
%
% example code: 
% TrackFolder2_noSIM('Analysis',[500 0.01 100],2,51.5,0.9,p,'Calib504',p_calib,5,2)
%
% Helen Miller April 2020. The coronavirus lockdown.

%deal with the calibration data assuming in standard form (using
%make_z_lines_slower 12000 250Hz  600 6.667 50.4
%make the calibration data
close all %get rid of any open figures or they will be saved with this analysis

disp('This code is going to ask for input, do not leave');
[~, ~, ~, calib_image_data, ~] = ExtractImageSequence3(CalibFileName, 1, 1, 600);
rotimage1=rot90(calib_image_data,1);
rotimage=flipud(rotimage1);
[SpotsCh1, SpotsCh2,~,~, ~, ~,~,~] = ADEMScode2_0_vanilla_HM(rotimage,p_calib);
[calibtop]=ADEMS2TSCalib(SpotsCh1,pixsize,linkcons);
[calibbottom]=ADEMS2TSCalib(SpotsCh2,pixsize,linkcons);
%Get the user to match up the different spots by showing them on the first
%frame of the calibration
figure;
imshow(calib_image_data(:,:,1),[min(min(calib_image_data(:,:,1))) max(max(calib_image_data(:,:,1)))])
hold on
minispotstop=calibtop(calibtop(:,2)==1,:);
minispotsbottom=calibbottom(calibbottom(:,2)==1,:);
for jj=1:length(minispotstop(:,1))
scatter(minispotstop(jj,3)./pixsize,minispotstop(jj,4)./pixsize,'or');
textstring=num2str(minispotstop(jj,5));
text((minispotstop(jj,3)./pixsize)+5,minispotstop(jj,4)./pixsize,textstring,'Color','r');
end
title('Please match up the top and bottom localisations')
for kk=1:length(minispotsbottom(:,1))
   scatter(minispotsbottom(kk,3)./pixsize,minispotsbottom(kk,4)./pixsize,'ob');
   textstring2=num2str(minispotsbottom(kk,5));
   text((minispotsbottom(kk,3)./pixsize)+5,minispotsbottom(kk,4)./pixsize,textstring2,'Color','b');
end

Pcorrect=0;
while Pcorrect==0
%ask the user to match them up
Pairings=zeros(length(minispotstop(:,1)),2);
str='';
for jjj=1:length(minispotstop(:,1))
text1=strcat('Top localisation ',num2str(minispotstop(jjj,5)),' goes with which bottom localisation?\nPlease enter a number, or zero if the same spot is not in the bottom image\n');
promptlink = text1;
Ptemp = input(promptlink);
Pairings(jjj,:)=[minispotstop(jjj,5) Ptemp];
str=strcat(str,';',num2str(Pairings(jjj,:)));
end
text2=strcat('The pairings are ', str, ' Are these correct (1 for yes, 0 for no)?');
promptlink2=text2;
Pcorrect=input(promptlink2); 
end
disp('Please wait...');

%work out which folder you are in
OriginFolder = pwd;

%create a folder to put the analysis into
mkdir(OutputFolder);
cd(OutputFolder);
Outputfolderpath=pwd;


%now start the calib
% check the pairings and use the highest intensity one with a single localisation in each frame
[TopCalibLoc, BottomCalibLoc,FLAG]=CheckCalib2(Pairings,calibtop,calibbottom,600);
if FLAG==1  %this means a pairing wasn't made
    disp('Retry the tracking in cursor mode. Select the same spot in each image')
    clear TopCalibLoc BottomCalibLoc
    [TopCalibLoc,BottomCalibLoc]=MakeMeACalib(rotimage,p_calib,pixsize,linkcons);
end
[CalibMap]=CreateCalibMap(TopCalibLoc,BottomCalibLoc);
cd(OriginFolder); % this is here so if it errors out in calibratez4 you don't have to navigate paths
[ rampcalibdata,symcalibdata]=calibratez4(TopCalibLoc,BottomCalibLoc,12000,250, 600, 6.67,50.4);
cd(OutputFolder);
symcalibdata=[symcalibdata 50.4*10];   %this is so the calib range gets passed through for solving

%For Trackfolder2_noSIM
symcalibdata(:,2:5)=0;
disp('No more user input is required.');

%save all the figures made so far
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = get(FigHandle, 'Number');
  figfilename1=strcat(Outputfolderpath, '\',num2str(FigName),'.fig');
  pngfilename1=strcat(Outputfolderpath, '\', num2str(FigName),'.png');
  savefig(FigHandle,figfilename1);
  saveas(FigHandle,pngfilename1);
end
close all

%Save all the tracking params you are using into a structure
save('AnalysisParameters.mat', 'linkcons','n','pixsize','corr_coeff','p','p_calib','CalibFileName','rampcalibdata','symcalibdata','Pairings','tolfactor','CalibMap','minCorr','calibtop','calibbottom','addextra')
cd(OriginFolder)

%find all the images in the folder you are in
TifFiles=dir('*.tif');
NumberTifs=size(TifFiles); 

for ii=1:NumberTifs(1)  %Loop to analyse each file and save appropriate things
disp(strcat('Image number: ',num2str(ii),' of ',num2str(NumberTifs(1))));
Im_name=TifFiles(ii).name;
FileName = Im_name(1:end-4);

%track each image file in turn - see if you're tracking the calibration
%file
tf = strcmp(FileName,CalibFileName);
    if tf==1
    %use P calib for tracking if you are looking at thecalibration file
        [SpotsCh1,SpotsCh2,topsmatched,bottomsmatched,xyzPoints ,SpotsTrajtop,SpotsTrajbottom,fl_stack,bf_stack]=Track3D(FileName,linkcons,n,pixsize,corr_coeff,p_calib,1,rampcalibdata,symcalibdata,CalibMap,tolfactor,minCorr);
    elseif tf==0
        [SpotsCh1,SpotsCh2,topsmatched,bottomsmatched,xyzPoints ,SpotsTrajtop,SpotsTrajbottom,fl_stack,bf_stack]=Track3D_2(FileName,linkcons,n,pixsize,corr_coeff,p,1,rampcalibdata,symcalibdata,CalibMap,tolfactor,minCorr,addextra);
    end
    
% go into the analysis folder and save things:
cd(OutputFolder)
Outputfolderpath=pwd;
view(2)
figfilename=strcat(Outputfolderpath, '\', '3DFig_',FileName,'.fig');
pngfilename=strcat(Outputfolderpath, '\', '3DFig_',FileName,'.png');
savefig(figfilename);
saveas(gcf,pngfilename);
close all
datafilename=strcat(Outputfolderpath, '\', 'OUTPUTS_',FileName,'.mat');
save(datafilename,'SpotsCh1','SpotsCh2','topsmatched','bottomsmatched','xyzPoints' ,'SpotsTrajtop','SpotsTrajbottom','fl_stack','bf_stack');

%in case I decide I want to save images too
% imagefilename=strcat(Outputfolderpath, '\', 'frame_average',FileName,'.tif');
% imwrite(frame_average,imagefilename);
clear SpotsCh1 SpotsCh2 topsmatched bottomsmatched xyzPoints  SpotsTrajtop SpotsTrajbottom fl_stack bf_stack
cd(OriginFolder)
end

end

