function [CCmatrix] = correlate4( toptrajs,bottomtrajs,showgraphs,minCorr )
% CORRELATE4
% This code looks at top and bottom trajectories and sees how correlated 
% they are. It will only compare time overlapping segments of tracks of at
% least 2 frames. In comparison to correlate, correlate3 allows the use of
% gappy tracks compared to correlate2 it looks of segments of 2 frames
%
% INPUTS
% TOPTRAJS      ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% BOTTOMTRAJS   ThunderSTORM outputs of tracking on the bottom image of a 3D
%               acquisiton run through linkspots3 or some similar code to 
%               give trajectories
% SHOWGRAPHS    flag to show the graphs of the two trajectories being
%               compared; 1 to turn on figures, 0 else
% MINCORR       Minimimum length of trajectories to be correlated
%
% OUTPUT
% CCMatrix      All the CC values for determining which trajectories might
%               be correlated columns toptrajnumber, bottomtrajnumber,cc
%
% Example code [CC]=correlate(top,bottom,0); where 'top' and 'bottom' are
% trajectory files from running LinkSpots on ThunderSTORM outputs.
%
% Helen Miller May 2019

%Establish a counter for adding numbers to the correlation
counter=1;
already_calc=0;
%Establish the trajectory numbers to loop over
mintrackno=min(toptrajs(:,11));
if mintrackno==0
    % In the case that there are unlinked frames ignore them
    mintrackno=1;
end
maxtrackno=max(toptrajs(:,11));
% Loop over the top trajectories
for n=mintrackno:maxtrackno    
toprows=find(toptrajs(:,11)==n);
traj=toptrajs(toprows,:);
dims=size(traj);
if dims(1)>0
firstframe=traj(1,2);
lastframe=traj(end,2);
for mm=firstframe:lastframe
%now look for trajectories that nclude a localisation in this frame
rowsinc=find(bottomtrajs(:,2)==mm);
trajnums=bottomtrajs(rowsinc,11);
%loop over the trajectories that include that frame number
for nn=1:length(trajnums)
    % CHECK WHETHER THIS COMBINATION HAS ALREADY BEEN ASSESSED
    if counter>1
     [r_already]=find(CCmatrix(:,1)==n&CCmatrix(:,2)==trajnums(nn));
     already_calc=size(r_already);
    end
     if already_calc(1)>0
         % skip to next
     else
        if trajnums(nn)>0
            rowsoftrajinc=find(bottomtrajs(:,11)==trajnums(nn));
            btraj=bottomtrajs(rowsoftrajinc,:);
            lastframebottom=bottomtrajs(rowsoftrajinc(end,1),2);
            firstframebottom=bottomtrajs(rowsoftrajinc(1,1),2);
            %now need to work out which trajectory started first
            [firstframeinboth] = CompareNums(firstframebottom,firstframe,1);
            %now need to work out which trajectory ended first
            [lastframeinboth] = CompareNums(lastframebottom,lastframe,2);
            %find the appropriate rows for this
            firstrowtop=find(traj(:,2)==firstframeinboth);
            lastrowtop=find(traj(:,2)==lastframeinboth);
            firstrowbottom=find(btraj(:,2)==firstframeinboth);
            lastrowbottom=find(btraj(:,2)==lastframeinboth);
            %check that all of these where only one localisation
            if length(lastrowbottom)>1||length(lastrowtop)>1||length(firstrowtop)>1|| length(firstrowbottom)>1
                disp('Error one of these trajectories includes multiple localisations in either the first or last frames, and this may happen in the middle too')
            else
                % now make minitracks of these to compare/test the correlation
                minibottom=btraj(firstrowbottom:lastrowbottom,:);
                dimsmb=size(minibottom);
                minitop=traj(firstrowtop:lastrowtop,:);
                dimsmt=size(minitop);
                %correlate only things that have at least minCorr frames of overlap 
                if dimsmb(1)>(minCorr-1)&&dimsmt(1)>(minCorr-1)
                    %check the steps are consecutive and pad with zeros to make
                    %them. Also delete multiple localisations arbitrarily
                     [topPad] = CheckConseqAndPad( minitop,2 );
                     [bottomPad]=CheckConseqAndPad(minibottom,2);
                    %Now do the correlations only on the non zero rows.
                    %first find those rows - look at the x positions in top and
                    %bottom
                    testmat=horzcat(topPad(:,3),bottomPad(:,3));
                    [rows,cols]=find(testmat);
                    %now loop identify the row numbers that appear twice
                    rcounter=1;
                    for ii=min(rows):max(rows)
                        countrows=find(rows==ii);
                        if length(countrows)==2
                            inc_rows(rcounter)=ii;
                            rcounter=rcounter+1;
                        end
                    end
                    CC=corrcoef(topPad(inc_rows,3),bottomPad(inc_rows,3));
                    %Plot me the two graphs and write the value of CC on it
                    if showgraphs==1
                        figure;
                        plot(topPad(inc_rows,2),topPad(inc_rows,3),'r'); hold on
                        scatter(topPad(inc_rows,2),topPad(inc_rows,3),'xr');
                        plot(bottomPad(inc_rows,2),bottomPad(inc_rows,3),'b');
                        scatter(bottomPad(inc_rows,2),bottomPad(inc_rows,3),'xb');
                        xlabel('Frame number');ylabel('X coordinate'); title(['CC=', num2str(CC(1,2))]);
                        pause
% %                             %%edit 12May2020
% %                             CC
% %                             AvSigtop=mean(topPad(inc_rows,9))*51.5
% %                             AvSigbottom=mean(bottomPad(inc_rows,9))*51.5
% %                             tolfactor=5;
% %                             disp('Put in pixsize  and tolfactor varible if you keep this')
% %                             calibmap=[-3.629449468376127e+03,1.480173305016237e+04];
% %                             figure;
% %                             plot(topPad(inc_rows,3)+calibmap(1,1),topPad(inc_rows,4)+calibmap(1,2),'r'); hold on
% %                             plot(bottomPad(inc_rows,3),bottomPad(inc_rows,4),'b');
% %                             line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*51.5); topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*51.5)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*51.5); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*51.5)]);
% %                             line([topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*51.5); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*51.5)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*51.5); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*51.5)]);
% %                             line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*51.5); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*51.5)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*51.5); topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*51.5)]);
% %                             line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*51.5); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*51.5)],[topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*51.5); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*51.5)]);
% %                             framegaps=diff(inc_rows);
% %                             for jj=1:length(inc_rows)-1
% %                             topdist(jj)=(topPad(inc_rows(jj+1),3)-topPad(inc_rows(jj),3))./framegaps(jj);
% %                             bottomdist(jj)=(bottomPad(inc_rows(jj+1),3)-bottomPad(inc_rows(jj),3))./framegaps(jj);
% %                             end
% %                             Avdisttop=rms(topdist)
% %                             Avdistbottom=rms(bottomdist)
% %                             pause
% %                             close
% %                             %%end edit 12 May2020
                        close
                    end
                    % put the value of the correlation coefficient into a table using the
                    % counter and increment the counter
                    CCmatrix(counter,:)=[n trajnums(nn) CC(1,2)];
                    counter=counter+1;
                    clear inc_rows
                end
             end
        end
     end
end

end
clear toprows firstframe lastframe traj trajnums
end
%after this need to consider each possible bottom one start point with all
%the possible top one start points
end

