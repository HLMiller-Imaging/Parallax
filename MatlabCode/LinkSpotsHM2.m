function [ SpotsTraj] = LinkSpotsHM2(spots, AcceptCons,firstframe)
%LINKSPOTSHM
%   This function takes in the output of the ThunderSTORM ImageJ plugin and 
%   links the spots into trajectories.
%   Trajectories are unbranched - only one spot in frame n+1 can be linked
%   to a spot in frame n. 
%   Frames cannot be skipped - run the LinkTraj code after this one to link
%   whole trajectories rather than skipping single frames one at a time.
%   Required inputs:
%   spots  - Thunderstorm output
%           (Spot#;frame#;x;y;sigma;I;Offset;bkgd;chi2;uncertainty)
%           N.B. you must have imported this a a numeric matrix so format is
%           a double
%   Acceptcons  - conditions for acceptance of spot into trajectory 
%           (1) Distance in nm. Roughly this should be radius of psf
%           (2) Minimum intensity ratio of this frame to previous frame spot
%           (If you think you may have dimers where one bleaches before the 
%           other you need to think carefully about this)
%           (3) Maximum intensity ratio of this frame to previous frame spot
%           The code will choose a spot that meets these conditions; if
%           multiple spots meet the conditions it will choose the one that
%           is spatially closest to the previous localisation.
%
%   Outputs: 
%   SpotsTraj - same as input spots with additional column (column 11) with the 
%   trajectory number
%
% Example command line input: [ SpotsTraj] = LinkSpots3(spots, [250 0.4 2])
%
%   Helen Miller. Sept 2017


%Check to see if AcceptCons exists, if not, use the default values below
if exist('AcceptCons')==1
    % If AcceptCons has been programmed, use that
else
    % Define some defaults
    AcceptCons=[250 0.4 2.0];
end

%When the spots come in they have an ID which is not just 1:length.
%Change this for simplicity
spots(:,1)=1:length(spots(:,1));

%create a counter
m=1;

%create a new column to put the trajectory number in
spots(:,11)=zeros(length(spots(:,1)),1);
%Loop over the frames that you want to link to the previous frame
for ii=firstframe+1:max(spots(:,2))
    % Details for the spots in this frame
    Sn=spots(spots(:,2)==ii,:);
    Dimsnow=size(Sn);
    % Details of the spots in the previous frame
    Sn_1=spots(spots(:,2)==ii-1,:);
    Dimsprev=size(Sn_1);
    %Loop over the spots within a frame to see if you can link them to prev
    %frame
    
        for jj=1:Dimsnow(1)
                [meetsCons,dist,rr]=Linker(Sn,Sn_1,Dimsprev(1),AcceptCons,jj);
        %Then if only one meets the cons use that; if multiple ones meet
        %the conditions, choose the nearest to use; if nothing meets cons,
        %tough. Find the row number (rowno) which applies to each case
        
        if length(rr)==1
        rowno=rr;
            
        elseif length(rr)>1
            %Find nearest spot
        r=find(dist(:)==min(dist(meetsCons==1)));
        rowno=r;
        else         
        rowno=[];     
        end       
        %give this a trajectory number
        if rowno>0
            %Assign the correct matrix for linking
            mini=Sn_1;
            %assign the row numbers
            if spots(mini(rowno,1),11)==0
            spots(mini(rowno,1),11)=m;
            spots(Sn(jj,1),11)=m;
            m=m+1;
            elseif spots(mini(rowno,1),11)>0 
               
                    %just assign if you're in the next frame
                    spots(Sn(jj,1),11)=spots(mini(rowno,1),11);
                end
        end
        clear dist IRatio meetsCons rowno rr I2Ratio meetsCons2 mini
        end
    %Now you've found everything in the frame check that you haven't
    %assigned two spots to the same trajectory, and if you have, choose to
    %only link the one which was closest to the original spot (set the
    %other trajectory numbers to zero).
    %make mini table of row numbers and trajectory 
    checktab=spots(Sn(Sn(:,2)==ii,1),[1,11]);
    dimsct=size(checktab);
    for cc=1:dimsct(1)
        %subtract this row from all the others if it was in a traj. if you get zero need to
        %decide which one
        if checktab(cc,2)>0
            temp=checktab((cc+1):end,2)-checktab(cc,2);
            rtemp=find(temp==0);
            if length(rtemp)>0
                temp2=spots(spots(:,2)==ii-1,[1,2,3,4,11]);
                temp3=spots(spots(:,2)==ii,[1,2,3,4,11]);
                multipleindex=checktab(rtemp+cc,2);
                %This line hacks it to only have one number if same traj is
                %linked mroe than twice in a frame
                multipleindex=multipleindex(1);
                %now find the previous position and calculate the distances
                %of all the potential linked candidates from it
                multipleindex=multipleindex(1);
                prevpos=temp2(temp2(:,5)==multipleindex,[3,4]);
                if length(prevpos)==0 %if it skipped a frame when linking this is needed
                    temp4=spots(spots(:,2)==ii-2,[1,2,3,4,11]);
                    prevpos=temp4(temp4(:,5)==multipleindex,[3,4]);
                end
                nextpos=temp3(temp3(:,5)==multipleindex,[3,4]);
                nextunique=temp3(temp3(:,5)==multipleindex,1);
                mindistrow=find(min(sum((nextpos-prevpos).^2,2)));
                %the one that is minimum can be left as is, the other(s)
                %must have their traj number set to zero
                nextunique(mindistrow)=[];
                spots(nextunique,11)=0;
            end
            clear temp2 temp3 dists nextpos nextunique temp4
        end
        %look for temp==0, do something to them
        clear temp
    end
    
    clear Sn Sn_1 Sn_2 Dimsnow Dimsprev Dimsprev2
end
    
 clear m
 SpotsTraj=spots;
end


