function [topsmatched,bottomsmatched,xyzPoints,SpotsTrajtop,SpotsTrajbottom  ] = everything4(SpotsCh1top,SpotsCh1bottom,showgraphs, linkcons,n,pixsize,firstLeft,firstRight,rampcalibdata,symcalibdata,calibmap,tolfactor,minCorr,addextra)
% EVERYTHING4
% Links spots into trajectories and then trajectories into gappy
% trajectories within top/bottom image
% Next it looks for tracks that fall within a certain mapping of each
% other, defined by the user
% Then it allows the top and bottom trajectories to be linked together based
% on their mapping, and plots them
% Uses calibration data to make z correct.
% everythingrough3 has relaxed linking conditions compared for everything
% rough which are designed for EP data
%
% INPUTS
% SPOTSCH1top   - top spots 
% SPOTSCH1bottom- bottom spots
% SHOWGRAPHS    - switch to show graphs. 1 for figures, 0 for no figures.
% LINKCONS      - params for linking
% N             - number of steps that can be jumped
% PIXSIZE       - size of pixels in nm
% FIRSTLEFT     - frame number of the first fluorescent frame in the top image
% FIRSTRIGHT    - frame number of the first fluorescent frame in the bottom image
% RAMPCALIBDATA - The calibration data part 1
% SYMCALIBDATA  - The calibration data part 2
% CALIBMAP      - The mapping between top and bottom images found according
%                to the user matched up localisations in the calibration
%                frame
% TOLFACTOR     - the number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% MINCORR       - minimum number of localisations in tracks to try
%                correlation. Use 2 for maximum  data linkage, but a higher
%                value if you have noise on otherwise clear tracks.
% ADDEXTRA      - switch to look for extra points whilst plotting
%
% OUTPUTS
% TOPSMATCHED  - top spots with column linking localisations in top and
%                bottom images
% BOTTOMSMATCHED- bottom spots with column linking localisations in top and
%                bottom images
% XYZPOINTS    - x,y,z,frame no, traj no of found trajectories
% SPOTSTRAJTOP - the trajectories found for spotsch1
% SPOTSTRAJBOTTOM- the trajectories found for spotsch2
%
% example code: 
% everything3(SpotsCh1,SpotsCh2,0, linkcons,n,pixsize,corr_coeff,firstLeft,firstRight,rampcalibdata,symcalibdata,calibmap,tolfactor,minCorr);
%
% Helen Miller April 2020. The coronavirus lockdown.

[top,SkipFlag1]=ADEMS2TS(SpotsCh1top,pixsize);
[bottom,SkipFlag2]=ADEMS2TS(SpotsCh1bottom,pixsize);
%top=SpotsCh1top;
%bottom=SpotsCh1bottom;

%Only do the following if SkipFlags are zero
if SkipFlag1==0 &&SkipFlag2==0
[ SpotsTrajtop] = LinkSpotsHM2(top, linkcons,firstLeft);
disp('Top spots linked');
[ SpotsTrajbottom] = LinkSpotsHM2(bottom, linkcons,firstRight);
disp('Bottom spots linked');
[ LinkedTrajtop] = LinkTraj(SpotsTrajtop, [n linkcons(1,1)*n]);
disp('Top traj linked');
[ LinkedTrajbottom] = LinkTraj(SpotsTrajbottom, [n linkcons(1,1)*n]);
disp('Bottom traj linked')
[Cmatrix] = CalcAvMap( LinkedTrajtop,LinkedTrajbottom,showgraphs,minCorr, pixsize, tolfactor,calibmap );
    if sum(sum(Cmatrix))==0
        %nothing to link - just assign null and carry on
        topsmatched=0;
        bottomsmatched=0;
        xyzPoints=0;
    else
        [topsmatched,bottomsmatched]=stitchtraj3(Cmatrix,LinkedTrajtop,LinkedTrajbottom,showgraphs,linkcons);
        %Apply plotstitched3 which calls ApplyCalib4 within it to apply the calibration data to the real data to get 3D tracks 
        [ xyzPoints ]=plotstitched3(topsmatched,bottomsmatched,1,rampcalibdata,symcalibdata,calibmap,tolfactor,pixsize,addextra,linkcons);
    end
else %if there weren't any localisations assign null variables 
 topsmatched=0;
 bottomsmatched=0;
 xyzPoints=0;
 SpotsTrajtop=0;
 SpotsTrajbottom=0;   
end

end

