function [Cmatrix] = CalcAvMap( toptrajs,bottomtrajs,showgraphs,minCorr, pixsize, tolfactor,calibmap )
% CALCAVMAP
% This code looks at top and bottom trajectories and sees how the average 
% mapping between them compares to the mapping defined by the user in the 
% calibration. It will only compare time overlapping segments of tracks of at
% least minCorr frames. It works with gappy tracks by padding them with
% zeros.
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
% MINCORR       Minimimum length of trajectories to be compared
% CALIBMAP      The mapping between top and bottom images found according
%               to the user matched up localisations in the calibration
%               frame. How to get from top to bottom. x and y.
% TOLFACTOR     The number of pixels tolerance (+/-) in linking correlated
%               trajectories. 5 is strongly recommended
% PIXSIZE       Size of pixels in nm
%
% OUTPUT
% CMatrix      All the CC values for determining which trajectories might
%               be correlated columns toptrajnumber, bottomtrajnumber,cc
%
% Example code [CC]=correlate(top,bottom,0); where 'top' and 'bottom' are
% trajectory files from running LinkSpots on ThunderSTORM outputs.
%
% Helen Miller May 2020

%Establish a counter for adding numbers to the correlation
counter=1;
already_calc=0;
%Establish the trajectory numbers to loop over
mintrackno=min(toptrajs(:,11));
%Work out how big your tolerance region is
TolL=pixsize*tolfactor;
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
     [r_already]=find(Cmatrix(:,1)==n&Cmatrix(:,2)==trajnums(nn));
     already_calc=size(r_already,1);
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
                    [rows,~]=find(testmat);
                    %now loop identify the row numbers that appear twice
                    rcounter=1;
                    for ii=min(rows):max(rows)
                        countrows=find(rows==ii);
                        if length(countrows)==2
                            inc_rows(rcounter)=ii;
                            rcounter=rcounter+1;
                        end
                    end
                    %Calculate the average mapping and then decide if these
                    %meet the tolerances
                    avXmap=mean(bottomPad(inc_rows,3)-topPad(inc_rows,3));
                    avYmap=mean(bottomPad(inc_rows,4)-topPad(inc_rows,4));
                    if avXmap>calibmap(1,1)-TolL &&avXmap<calibmap(1,1)+TolL && avYmap>calibmap(1,2)-TolL &&avYmap<calibmap(1,2)+TolL
                       %it's in the user defined tolerance
                       CVal=1;
                    else
                       CVal=0;
                    end
                    %Plot me a graph with the two trajectories
                    if showgraphs==1
                            figure;
                            plot(topPad(inc_rows,3)+calibmap(1,1),topPad(inc_rows,4)+calibmap(1,2),'r'); hold on
                            plot(bottomPad(inc_rows,3),bottomPad(inc_rows,4),'b');
                            line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*pixsize); topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*pixsize)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*pixsize); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*pixsize)]);
                            line([topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*pixsize); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*pixsize)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*pixsize); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*pixsize)]);
                            line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*pixsize); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*pixsize)],[topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*pixsize); topPad(inc_rows(1),4)+calibmap(1,2)-(tolfactor*pixsize)]);
                            line([topPad(inc_rows(1),3)+calibmap(1,1)-(tolfactor*pixsize); topPad(inc_rows(1),3)+calibmap(1,1)+(tolfactor*pixsize)],[topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*pixsize); topPad(inc_rows(1),4)+calibmap(1,2)+(tolfactor*pixsize)]);
                            title({'Trajectories; box indicates the user defined matching','area for the first localisation in both frames'});
                            xlabel('X (nm)'); ylabel('Y (nm)');
                            pause
                        close
                    end
                    % put the value of the correlation coefficient into a table using the
                    % counter and increment the counter
                    Cmatrix(counter,:)=[n trajnums(nn) CVal];
                    counter=counter+1;
                    %already_calc=0;
                    clear inc_rows
                end
             end
        end
     end
end

end
clear toprows firstframe lastframe traj trajnums
end

end
A = exist('Cmatrix');
if A==0
Cmatrix=[0 0 0]; %catch in case no Cmatrix was returned
end
end