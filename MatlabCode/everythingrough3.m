function [topsmatched,bottomsmatched,xyzPoints ,SpotsTrajtop,SpotsTrajbottom ] = everythingrough3( SpotsCh1top,SpotsCh1bottom,showgraphs, linkcons,n,pixsize,corr_coeff,firstLeft,firstRight,minCorr)
% EVERYTHINGOUGH3
% Links spots into trajectories and then trajectories into gappy
% trajectories within top/bottom image
% Next it correlates these allowing there to be gaps in the tracks
% Then it allows the top and bottom trajectories to be linked together based
% on their correlation, and plots them
% Does not use calibration data. Z is just fudged a bit so you can get a
% quick look at how things would look in 3D without the full calibration
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
% CORR_COEFF    - threshold correlation to accept the particles as the same.
%                range [-1 1]. 1 is most correlated
% FIRSTLEFT     - frame number of the first fluorescent frame in the top image
% FIRSTRIGHT    - frame number of the first fluorescent frame in the bottom image
% MINCORR       - minimum number of localisations in tracks to try
%                correlation. Use 2 for maximum  data linkage, but a higher
%                value if you have noise on otherwise clear tracks.
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
% everythingrough3( SpotsCh1,SpotsCh2,0, linkcons,n,pixsize,corr_coeff,firstLeft,firstRight,minCorr);
%
% Helen Miller April 2020. The coronavirus lockdown.

[top,SkipFlag1]=ADEMS2TS(SpotsCh1top,pixsize);
[bottom,SkipFlag2]=ADEMS2TS(SpotsCh1bottom,pixsize);

if SkipFlag1==0 &&SkipFlag2==0
[ SpotsTrajtop] = LinkSpotsHM2(top, linkcons,firstLeft);
disp('Top spots linked');
[ SpotsTrajbottom] = LinkSpotsHM2(bottom, linkcons,firstRight);
disp('Bottom spots linked');
[ LinkedTrajtop] = LinkTraj(SpotsTrajtop, [n linkcons(1,1)*n]);
disp('Top traj linked');
[ LinkedTrajbottom] = LinkTraj(SpotsTrajbottom, [n linkcons(1,1)*n]);
disp('Bottom traj linked')
[CCmatrix] = correlate4( LinkedTrajtop,LinkedTrajbottom,showgraphs,minCorr );
figure
histogram(CCmatrix(:,3),20);


[topsmatched,bottomsmatched]=stitchtraj(CCmatrix,corr_coeff,LinkedTrajtop,LinkedTrajbottom,showgraphs);
%[ xyzPoints ]=plotstitched2(topsmatched,bottomsmatched,1);
[ xyzPoints ]=plotstitched4(topsmatched,bottomsmatched,1);
%%fitcylinder
else %if there weren't any localisations assign null variables 
 topsmatched=0;
 bottomsmatched=0;
 xyzPoints=0;
 SpotsTrajtop=0;
 SpotsTrajbottom=0;  
end
end

