function [topsmatched,bottomsmatched]=MultiOverlap(PairingsList,topsmatched,bottomsmatched,linkcons)
% MULTIOVERLAP
% This function decided how to link trajectories together based on created
% the longest matched trajectories it can
%
% INPUTS %% 
% PAIRINGSLIST  the list of pairings (traj no's) that are allowed according
%               to the user defined criteria (created in stitchtraj3)
% TOPSMATCHED   Exact copy of toptrajs with empty column 12 for the
%               matched trajectory numbers
% BOTTOMSMATCHEDExact copy of bottomtrajs with empty column 12 for the
%               matched trajectory numbers
% LINKCONS      params for linking
%
% OUTPUTS %%
% TOPSMATCHED   Exact copy of toptrajs with new column 12 including the
%               matched trajectory numbers
% BOTTOMSMATCHEDExact copy of bottomtrajs with new column 12 including the
%               matched trajectory numbers
%
% EXAMPLECODE %%
% [topsmatched,bottomsmatched]=MultiOverlap(PairingsList,topsmatched,bottomsmatched)
%
% Helen Miller May 2020

% Define a variable for giving new pairing assignments
cmatched=1;
%make a matrix toptrajno, first frame, lastframe,assigned trajno 
%create a matrix to put them into where row number is traj number (could
%delete the zeros but this way means less indexing later)
[TopFrameNos] = CreateFrameNos(PairingsList(:,1),topsmatched);
%do the same for the bottom
[BottomFrameNos] = CreateFrameNos(PairingsList(:,2),bottomsmatched);

%Make matrices showing which top trajs overlap with each other (1's and
%zeros) and same for bottom
[OMatrixtop]=OverlapMatrix(reshape([TopFrameNos(:,2)';TopFrameNos(:,3)'], [],1));
[OMatrixbottom]=OverlapMatrix(reshape([BottomFrameNos(:,2)';BottomFrameNos(:,3)'], [],1));

% Check for one frame overlaps and see if they are due to split
% localisations:
[topsmatched,TopFrameNos,PairingsList(:,1)] = MergeTraj(OMatrixtop,TopFrameNos,linkcons,topsmatched,PairingsList(:,1));
[bottomsmatched,BottomFrameNos,PairingsList(:,2)] = MergeTraj(OMatrixbottom,BottomFrameNos,linkcons,bottomsmatched,PairingsList(:,2));

% remake the diagnostic matrices with these new merged trajectories
[OMatrixtop]=OverlapMatrix(reshape([TopFrameNos(:,2)';TopFrameNos(:,3)'], [],1));
[OMatrixbottom]=OverlapMatrix(reshape([BottomFrameNos(:,2)';BottomFrameNos(:,3)'], [],1));

%make a big matrix with all top trajs on one side and all bottom trajs on 
%the top calculate the number of frames overlap for each 
CrossOverlap=zeros(max(PairingsList(:,1)),max(PairingsList(:,2)));
for ii=1:max(PairingsList(:,1))
    for jj=1:max(PairingsList(:,2))
        %I think this should give me whether or not they overlap, but I
        %want to know how much by
        %determine if the pairing is possible (i.e. see if it's in the
        %pairings list
        rowsii=find(PairingsList(:,1)==ii);
        rowiijj=find(PairingsList(rowsii,2)==jj);
        if size(rowiijj,1)>0
        CrossOverlap(ii,jj)=OverlapCalc2(TopFrameNos(ii,2:3), BottomFrameNos(jj,2:3));
        else %leave as a zero
        end
    end
end
%if there are potential assignments, make them
if length(find(CrossOverlap))>=1
    KeepGoing=1;
    %Loop through assigning what trajectory numbers you can
    while KeepGoing==1
        %check for possible unique assignments and assign
        %these are places in cross overlap where everything else in the row and
        %column are zeros - look for rows with only one nonzero element: if you
        %find one see if the column only has one nonzero element too.
        for kk=1:max(PairingsList(:,1))
            NNonZero=nnz(CrossOverlap(kk,:));
            if NNonZero==1
                %see if it's the only possibility
                Col=find(CrossOverlap(kk,:));
                NNonZero2=nnz(CrossOverlap(:,Col));
                if NNonZero2==1
                    %it is the only possibility. Check if either numbered
                    %trajectory has a traj no assigned and assign appropriately
                    %it doesn't overlap: assign - check in case anything is
                    %already assigned
                    [TopFrameNos,BottomFrameNos,topsmatched,bottomsmatched,cmatched]=AssignTrajNum(TopFrameNos,BottomFrameNos,kk,Col,topsmatched,bottomsmatched,cmatched);
                    %now remove the entries from the matrices
                    CrossOverlap(kk,Col)=0;
                    OMatrixtop(kk,kk)=0;
                    OMatrixbottom(Col,Col)=0;
                end
            end 
        end
        %Now find the largest overlap and assign traj numbers to it
        [rowM,colM,~]=find(CrossOverlap==max(max(CrossOverlap)));
        if max(max(CrossOverlap))>0
            %see if there's only one instance of the largest value
            %otherwise determine if the order matters
            if size(rowM,1)==1 %only one - keep the order
            elseif size(rowM,1)>10000 %there's too many; probably means lots of pairs. Shouldn't really happen
                disp(strcat('There are thousands of tracks with a length of ', num2str(max(max(CrossOverlap)))));
                disp('They will be dealt with sequentially. You might be able to avoid this by increasing minCorr');
            else
               %Do these overlaps overlap with each other?
               RowTrajOverlap=zeros(size(rowM,1),size(rowM,1));
               ColTrajOverlap=zeros(size(rowM,1),size(rowM,1));
               for pp=1:size(rowM,1)
               [OverlapInterval(pp,:)]=OverlapCalc3(TopFrameNos(rowM(pp),2:3), BottomFrameNos(colM(pp),2:3));
                   for qq=1:size(rowM,1)
                       if rowM(pp)==rowM(qq)
                       RowTrajOverlap(pp,qq)=1;
                       end
                       if colM(pp)==colM(qq)
                       ColTrajOverlap(pp,qq)=1;
                       end
                   end
               end
               [OMatrix2]=OverlapMatrix(reshape([OverlapInterval(:,1)';OverlapInterval(:,2)'], [],1));
               tf_diag = isdiag(OMatrix2);
               if tf_diag==1
                    %the intervals don't overlap in time- just assign in current order
               elseif tf_diag==0 %there's at least one overlap in time
                    %let's loop over the things that overlap in time and
                    %see if they have the same possible trajectory (do it
                    %backwards to avoi screwing the indexing)
                    deleteflag=zeros(size(rowM,1),1);
                    for pr=size(rowM,1):-1:2
                        for ps=size(rowM,1):-1:1
                            if ps<pr %only need to evaluate each pair once
                               if OMatrix2(pr,ps)==1
                                  if ColTrajOverlap(pr,ps)==1
                                     %overlaps in time and has same
                                     % col trajectories - delete the
                                     %contradiction
                                     CrossOverlap(rowM(pr),colM(ps))=0;
                                     CrossOverlap(rowM(ps),colM(ps))=0;
                                     deleteflag([ps,pr],1)=1;
                                     disp('A contradiction has been deleted; no trajectory assigned. Try a lower tolfactor to avoid this')
                                  elseif RowTrajOverlap(pr,ps)==1
                                     CrossOverlap(rowM(pr),colM(pr))=0;
                                     CrossOverlap(rowM(pr),colM(ps))=0;
                                     deleteflag([ps,pr],1)=1;
                                     disp('A contradiction has been deleted; no trajectory assigned. Try a lower tolfactor to avoid this')
                                  elseif  RowTrajOverlap(pr,ps)==1&&ColTrajOverlap(pr,ps)==1
                                      disp('You should not be able to duplicate traj pairings- investigate')
                                      pause
                                  else % overlaps are spatially separated- fine to assign
                                  end
                               end
                            end
                        end
                    end
                    rowM(deleteflag(:,1)==1,:)=[];
                    colM(deleteflag(:,1)==1,:)=[];
                    clear deleteflag
               end
               clear OMatrix2 OverlapInterval 
            end
            %now go through through the rows and columns assigning
            for iii=1:size(rowM,1)
                [TopFrameNos,BottomFrameNos,topsmatched,bottomsmatched,cmatched]=AssignTrajNum(TopFrameNos,BottomFrameNos,rowM(iii),colM(iii),topsmatched,bottomsmatched,cmatched);
                %also set the values you assigned to zero e.g.
                CrossOverlap(rowM(iii),colM(iii))=0;
                OMatrixtop(rowM(iii),rowM(iii))=0;
                OMatrixbottom(colM(iii),colM(iii))=0;
                %find the possible assignments that now can't be and remove them from the
                %matrices of possibilities.       
                %find the non zero elements in the right CrossOverlap row/column
                %then cross check each of these with OMatrixtop and OMatrixbottom
                %to see if they overlap.
                BtoCheck=find(CrossOverlap(rowM(iii),:));
                if size(BtoCheck,2)>=1
                    for jjk=1:size(BtoCheck,2)                   
                        if OMatrixbottom(BtoCheck(1,jjk),colM(iii))==1
                            %if they overlap that crossoverlap is out (set to zero) and so are
                            %the Omatrix top/bottom vals (there are two of each of these)
                            OMatrixbottom(BtoCheck(1,jjk),colM(iii))=0;
                            OMatrixbottom(colM(iii),BtoCheck(1,jjk))=0;
                            CrossOverlap(rowM(iii),BtoCheck(1,jjk))=0;
                        end
                    end
                end
                TtoCheck=find(CrossOverlap(:,colM(iii)));
                if size(TtoCheck,1)>=1
                    for jjj=1:size(TtoCheck,1)
                        if OMatrixtop(rowM(iii),TtoCheck(jjj,1))==1
                            %if they overlap that crossoverlap is out (set to zero) and so are
                            %the Omatrix top/bottom vals (there are two of each of these)
                            OMatrixtop(rowM(iii),TtoCheck(jjj,1))=0;
                            OMatrixtop(TtoCheck(jjj,1),rowM(iii))=0;
                            CrossOverlap(TtoCheck(jjj,1),colM(iii))=0;
                        end
                    end
                end
                clear BtoCheck TtoCheck
            end
        end
        %check to see if there are any assignments still to be made
        if length(find(CrossOverlap))==0
            KeepGoing=0;
        end
    end
end
end
