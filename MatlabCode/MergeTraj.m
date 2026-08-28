function [trajmatched,FrameNos,PairingsListCol] = MergeTraj(OMatrix,FrameNos,linkcons,trajmatched,PairingsListCol)
% MERGETRAJ
% Sometimes, as a result of the distorted psf's produced by the 3D method
% multiple spots can be found in one psf image. This code looks for
% instances where a spot might have been erroneously split in two because
% there is a single frame temporal overlap between two trajectories. It
% then determines if averaging the two spot locations would enable both
% trajectories to be linked together and meet the linkcons. If it does, ti
% updates the trajmatched location (not the other columns) and the Pairings 
% list appropriately.
% After you run this code you need to make a new OMatrix (easier than changing).
%
% INPUTS
% OMatrix        Overlap Matrix
% FrameNos       3 columns; trajno, start frame no, end frame no
% LinkCons       parameters for accepting a linking or merging or two
%                trajectories
% trajmatched    the topsmatched or bottomsmatched you are updating
% PAIRINGLISTCOL the column of the pairings list corresponding to the traj
%                numbers you are updating
%
% OUTPUTS
% trajmatched    the topsmatched or bottomsmatched now updated with merged
%                trajs
% FrameNos       3 columns; trajno, start frame no, end frame no updated
% PAIRINGLISTCOL the column of the pairings list corresponding to the traj
%                numbers after merging
%
% Helen Miller May 2020

%take in an overlap matrix and find where there are overlaps
[rowsO, colsO]=find(OMatrix);

%problem when you look for a traj you already changed in an eariler loop

%loop over the locations of the overlaps determining how big they are
for ii=1:size(rowsO,1)
OverlapSwitch=OverlapCalc2(FrameNos(rowsO(ii),2:3), FrameNos(colsO(ii),2:3));
    if OverlapSwitch==1 % if the overlap is only one frame
        %check if you already did this one
        if OMatrix(colsO(ii),rowsO(ii))==1
            %determine which frame no it is
            [interval]=OverlapCalc3(FrameNos(rowsO(ii),2:3),  FrameNos(colsO(ii),2:3));
            %find the localisations that correspond to the start and end values
            %and the one before after
            trajrows1=find(trajmatched(:,11)==rowsO(ii)); %rows corresponding to this trajnum
            Locs1=trajmatched(trajrows1,:);
            trajrows2=find(trajmatched(:,11)==colsO(ii)); %rows corresponding to this trajnum
            Locs2=trajmatched(trajrows2,:);
            maxframes=[max(Locs1(:,2)) max(Locs2(:,2))];
            if maxframes(1,1)==interval(1,1) %locs 1 finishes first
               Locs=vertcat(Locs1(end-1:end,2:4),Locs2(1:2,2:4));
               trajrowsfirst=trajrows1;
               trajrowssecond=trajrows2;
            elseif maxframes(1,2)==interval(1,1) %locs2 finishes first
               Locs=vertcat(Locs2(end-1:end,2:4),Locs1(1:2,2:4));
               trajrowsfirst=trajrows2;
               trajrowssecond=trajrows1;
            else
                error('This should not be possible. Debug');
            end
            %check frame no sequence
           if sum((diff(Locs(:,1))-[1;0;1]).^2)==0
               %it should be this, otherwise too much uncertaintity
               %create the average localisation of the shared point
               newLoc=mean(Locs(2:3,2:3),1);
               dists=((Locs([1;4],2)-newLoc(1,1)).^2+(Locs([1;4],3)-newLoc(1,2)).^2).^0.5;
               if dists(1,1)<linkcons(1,1) &&dists(2,1)<linkcons(1,1)
                  %then it can be done
                  %replace the last old point location with the average
                  %point, leave everythng else the same
                  trajmatched(trajrowsfirst(end),3:4)=newLoc;
                  %change the trajnums in the pairings list - we were
                  %only passed the column that we needed so we'll just
                  %updte this
                  rowsOld=find(PairingsListCol(:,1)==trajmatched(trajrowssecond(1,1),11));
                  PairingsListCol(rowsOld)=trajmatched(trajrowsfirst(1,1),11);
                  %update your possible rowsO and colsO
                  rowsNews=find(rowsO(:,1)==trajmatched(trajrowssecond(1,1),11));
                  colsNews=find(colsO(:,1)==trajmatched(trajrowssecond(1,1),11));
                  colsO(colsNews)=trajmatched(trajrowsfirst(1,1),11);
                  rowsO(rowsNews)=trajmatched(trajrowsfirst(1,1),11);
                  %then update the framenos
                  FrameNos(trajmatched(trajrowsfirst(1,1),11),3)=FrameNos(trajmatched(trajrowssecond(1,1),11),3);
                  FrameNos(trajmatched(trajrowssecond(1,1),11),:)=[0 0 0 0];
                  %replace all the trajectory numbers in the second
                  %trajectory with the ones from the first
                  trajmatched(trajrowssecond(:,1),11)=trajmatched(trajrowsfirst(1,1),11);
                  %delete the first point of the second trajectory
                  trajmatched(trajrowssecond(1,1),:)=[];
                  %then update the matrices: set the partner overlap to zero so
                  %you don't check this one again
                  OMatrix(colsO(ii),rowsO(ii))=0;
               end
           else
               disp('This should not be possible')
               pause
           end
        end
    end
    clear OverlapSwitch trajrows Frames
end

end

