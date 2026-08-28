function [topsmatched,bottomsmatched]=stitchtraj2(CCmatrix,thresh,toptrajs,bottomtrajs,showgraphs,calibmap,tolfactor,pixsize)
% STITCHTRAJ2
%This function applies a threshold on the correlation coefficients 
%to match up localisations from the top and bottom trajectory, it also uses
%information from the user-matched parts of the calibration file to
%distinguish which locs can go together.
%
% INPUTS %% 
% CCMATRIX      Output of CORRELATE code with columns toptrajnum,
%               bottomtrajnum, Correlation Coefficient
% THRESH        Numerical threshold to decide if tracks are correlated
%               enough to link. Value in range [-1,1]; 0.9 recommended - to
%               set your own look at histogram of CCMatrix values to see
%               where there is a clear divide between correlated and
%               uncorrelated tracks.
% TOPTRAJS      ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% BOTTOMTRAJS   ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% SHOWGRAPHS    flag to show the graphs of the two trajectories being
%               compared; 1 to turn on figures, 0 else
%
% OUTPUTS %%
% TOPSMATCHED   Exact copy of toptrajs with new column 12 including the
%               matched trajectory numbers
% BOTTOMSMATCHEDExact copy of bottomtrajs with new column 12 including the
%               matched trajectory numbers
%
% EXAMPLECODE %%
% [topsmatched,bottomsmatched]=stitchtraj2(CC,0.9,SpotsTrajtop,SpotsTrajbottom,0)
%
% Helen Miller March 2020

% Create the two new matrices for including the paired trajectory numbers
topsmatched=zeros(length(toptrajs),12);
bottomsmatched=zeros(length(bottomtrajs),12);
topsmatched(:,1:11)=toptrajs;
bottomsmatched(:,1:11)=bottomtrajs;
% Find the rows of the CCmatrix that meet the threshold to be
% linked together
rowsCChigh=find(CCmatrix(:,3)>=thresh);
% create a counter for the matchedtrajnums
cmatched=1;
%loop over these rows  that meet the threshold
    for jj=1:length(rowsCChigh)
    %find the toptrajs lines that have the appropriate tracknumber
    toptrajrows=find(toptrajs(:,11)==CCmatrix(rowsCChigh(jj),1));
    %find the bottomtrajs lines that have the appropriate tracknumber
    bottomtrajrows=find(bottomtrajs(:,11)==CCmatrix(rowsCChigh(jj),2));
    %check to see if either of these trajectories has been assigned a
    %cmatched number yet
    testmatchedbottom=bottomsmatched(bottomtrajrows(1),12);
    testmatchedtop=topsmatched(toptrajrows(1),12);
    %also now check whether they line up as they should
    %1) work out a frame they both have a localisation in
    minitop=toptrajs(toptrajrows,2:4); %frame nos and localisations of the top
    minibottom=bottomtrajs(bottomtrajrows,2:4); % frame nos and localisations of the bottom
    %loop through the top ones frame numbers until you find one that's also
    %in the bottom frame
    notmatched=1;
   while notmatched==1 
    for jjj=1:length(minitop(:,1)) 
        
        rowsame=find(minibottom(:,1)==minitop(jjj,1));
        if length(rowsame)==1&&notmatched==1 
            notmatched=0;
             % See if the toploc - calibmap +/- a tolerance gets you to the bottom
            %loc.
            topx=minitop(jjj,2);
            bottomx=minibottom(rowsame,2);
            topy=minitop(jjj,3);
            bottomy=minibottom(rowsame,3);
            if (topx+calibmap(1,1))<bottomx+(tolfactor*pixsize) && (topx+calibmap(1,1))>bottomx-(tolfactor*pixsize)
                %might be ok, check y too
                if (topy+calibmap(1,2))<bottomy+(tolfactor*pixsize) && (topy+calibmap(1,2))>bottomy-(tolfactor*pixsize)
                    %it is ok! Go ahead and assign traj numbers
                    if testmatchedbottom==0&&testmatchedtop==0
                    topsmatched(toptrajrows,12)=cmatched;
                    bottomsmatched(bottomtrajrows,12)=cmatched;
                    cmatched=cmatched+1;
                    elseif testmatchedbottom>0&&testmatchedtop==0
                        topsmatched(toptrajrows,12)=testmatchedbottom;
                        bottomsmatched(bottomtrajrows,12)=testmatchedbottom;
                    elseif  testmatchedbottom==0&&testmatchedtop>0
                        topsmatched(toptrajrows,12)=testmatchedtop;
                        bottomsmatched(bottomtrajrows,12)=testmatchedtop;
                    else
                        disp('There is a problem - it looks like both trajectories have already been assigned different numbers, please investigate')
                    end
                end
            end
        elseif length(rowsame)==0 &&jjj==length(minitop(:,1))
            %there wasn't a localisation that worked
            disp('these correlation matched trajs did not  have any points in  common');
        end
    end
    end  
    
    clear minitop minibottom toptrajrows bottomtrajrows testmatchedtop testmatchedbottom notmatched
end
%show the x  vs time and y vs time of matched trajectories if graphs are on
if showgraphs==1
     for ii=1:cmatched
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