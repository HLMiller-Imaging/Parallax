function [topsmatched,bottomsmatched]=stitchtraj3(Cmatrix,toptrajs,bottomtrajs,showgraphs,linkcons)
% STITCHTRAJ3
%This function applies a threshold on the matching coefficients 
%to match up localisations from the top and bottom trajectory.
%
% INPUTS %% 
% CMATRIX       Output of CALCAVMAP code with columns toptrajnum,
%               bottomtrajnum, matching - the last of these is 1 if the two
%               trajectories are within the expected bounding box and 0
%               otherwise
% TOPTRAJS      ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% BOTTOMTRAJS   ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% SHOWGRAPHS    flag to show the graphs of the two trajectories being
%               compared; 1 to turn on figures, 0 else
% LINKCONS      params for linking
%
% OUTPUTS %%
% TOPSMATCHED   Exact copy of toptrajs with new column 12 including the
%               matched trajectory numbers
% BOTTOMSMATCHEDExact copy of bottomtrajs with new column 12 including the
%               matched trajectory numbers
%
% EXAMPLECODE %%
% [topsmatched,bottomsmatched]=stitchtraj3(C,0.9,SpotsTrajtop,SpotsTrajbottom,0)
%
% Helen Miller May 2020

% Create the two new matrices for including the paired trajectory numbers
topsmatched=zeros(length(toptrajs),12);
bottomsmatched=zeros(length(bottomtrajs),12);
topsmatched(:,1:11)=toptrajs;
bottomsmatched(:,1:11)=bottomtrajs;
% Find the rows of the CCmatrix that are within the user defined tolerance
rowsCChigh=find(Cmatrix(:,3)>=0.5);
%Keep only the rows of the CMatrix that met the user defined criteria
PairingsList=Cmatrix(rowsCChigh,:);

[topsmatched,bottomsmatched]=MultiOverlap(PairingsList,topsmatched,bottomsmatched,linkcons);

%show the x  vs time and y vs time of matched trajectories if graphs are on
if showgraphs==1
     for ii=1:max(bottomsmatched(:,12))
         % these figures should both be smooth in the y direction if tracks
         % have been assigned well.
        figure; 
        subplot(2,1,1); plot(topsmatched(topsmatched(:,12)==ii,2),topsmatched(topsmatched(:,12)==ii,3));hold on; xlabel('Frame number');ylabel('x position');
        plot(bottomsmatched(bottomsmatched(:,12)==ii,2),bottomsmatched(bottomsmatched(:,12)==ii,3));
        subplot(2,1,2); plot(topsmatched(topsmatched(:,12)==ii,2),topsmatched(topsmatched(:,12)==ii,4));hold on; ylabel('Frame number');ylabel('y position')
        plot(bottomsmatched(bottomsmatched(:,12)==ii,2),bottomsmatched(bottomsmatched(:,12)==ii,4));
        pause
        close
     end
end
end