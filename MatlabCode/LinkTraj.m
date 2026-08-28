function [ LinkedTraj] = LinkTraj(SpotsTraj, LinkCons)
%LINKTRAJ
%   This function takes in the output of LinkSpots3 and links found
%   trajectories into longer trajectories, allowing skipped frames
%
%   Required inputs:
%   SpotsTraj  - LinkSpots3 output
%           (Spot#;frame#;x;y;sigma;I;Offset;bkgd;chi2;uncertainty;trajectory#)
%           N.B. you must have imported this as a numeric matrix so format is
%           a double
%   LinkCons  - conditions for linking 2 trajectories e.g [2 500]
%           (1) Maximum frame number difference to use
%           (2) Maximum spatial distance to use (nm)(These should be related -  
%           ideally imaging should be performed at a frame rate such that
%           the spot only moves around 1 psf per frame in order for it to
%           be accurately tracked.
%
%   Outputs: 
%   LinkedTraj - same as input SpotsTraj but with updated trajectory numbers
%                for longer trajectories 
%
%   Example command line input [ LinkedTraj] = LinkTraj(SpotsTraj, [2 250])
%
%   Helen Miller. October 2017, Edited March 2018

% Check if the link conditions have been programmed, if not, define some
% defaults
if exist('LinkCons')==1
    % If LinkCons has been programmed, use that
else
    % Define some defaults
    LinkCons=[2 500];
    % These are based on an assumption of a psf of 250nm that is skipped in
    % 2 frames therefore moving up to 750nm before being tracked again.
end

% preallocate variables
FirstFrame=zeros(max(SpotsTraj(:,11)),3);
FinalFrame=zeros(max(SpotsTraj(:,11)),3);
TrajNo=zeros(max(SpotsTraj(:,11)),1);

%Loop over trajectory numbers
for ii=1:max(SpotsTraj(:,11))
    [r]=find(SpotsTraj(:,11)==ii);
    %Find the frame number of the first and last frames in a trajectory
    FirstFrame(ii,:)=SpotsTraj(r(1),2:4);
    FinalFrame(ii,:)=SpotsTraj(r(end),2:4);
    TrajNo(ii,1)=ii;
end

%Make a table with the trajectory number, first and last frame frame
%numbers and positions
TrajTable=[TrajNo FirstFrame FinalFrame];

%Loop through trajectories and then for each one (apart from the last one)
% find ones that start after this one finishes and calculate
%the time and spatial distances from the localisation in this frame
for jj=1:max(SpotsTraj(:,11))-1
    Lastx=TrajTable(jj,6);
    Lasty=TrajTable(jj,7);
    Lastframe=TrajTable(jj,5);
    %find all the trajectories that start after this
    [r1]=find(TrajTable(jj+1:end,2)>Lastframe);
    %make a table of their trajectory number, time diff and distance from
    %prev trajectory
    temptable=zeros(length(r1),3);
    % Loop over trajectories after the one being linked to
    for kk=1:length(r1)
         % make a table of the traj no, time diff and distance from previous trajectory
    timedist=TrajTable(jj+r1(kk),2)-Lastframe;
    dist=((TrajTable(jj+r1(kk),3)-Lastx).^2+(TrajTable(jj+r1(kk),4)-Lasty).^2).^0.5;
    temptable(kk,:)=[TrajTable(jj+r1(kk),1) timedist dist];
    end
    % need to search through temp table to minimise on both distances.
    %first delete any lines of temptable that don't meet the linking
    %conditions.
    %Go from bottom of table upwards as counting over line numbr and
    %deleting lines
    for ll=length(r1):-1:1
        if temptable(ll,2)>LinkCons(1,1)
            temptable(ll,:)=[];
        elseif temptable(ll,3)>LinkCons(1,2)
            temptable(ll,:)=[];
        else
        end
    end
    %Now need to see how many trajectories meet both criteria. If only one
    %remains it is ok to  just use it. First see if any met the criteria
    dimstemp=size(temptable);
    if dimstemp(1,1)>0
        dimstemp=size(temptable);
        if dimstemp(1,1)==1
           % change the trajectory number of the looping trajectory to the trajectory number of the identified trajectory to
           % the same as the one you are counting against find the rows of the looping trajectory
           rOld=find(SpotsTraj(:,11)==jj);
           %update to new ones
           SpotsTraj(rOld,11)=temptable(1,1);
           %update trajTable first and last numbers to avoid branching
          % Find rows in trajTable which are being changed
           roldtable=find(TrajTable(:,1)==jj);
           rnewtable=find(TrajTable(:,1)==temptable(1,1));
           %Next combine them and set redundant to zero
           TrajTable(rnewtable,2:4)=TrajTable(roldtable,2:4);
           TrajTable(roldtable,:)=[0 0 0 0 0 0 0];
        else % if there are multiple candidates meeting the criteria need to choose between them
            % Choose one of the candidates
            %Assuming the particle moves at constant speed choose the
            %localisation which shows the lower speed i.e. lower
            %distance/frames
            temptable(:,4)=temptable(:,3)./temptable(:,2);
            rTemp=find(temptable(:,4)==min(temptable(:,4)));
            %find the rows of the looping trajectory
           rOld=find(SpotsTraj(:,11)==jj);
           %update to new ones
            SpotsTraj(rOld,11)=temptable(rTemp,1);
            %update trajtable to avoid branching
             % Find rows in trajTable which are being changed
           roldtable=find(TrajTable(:,1)==jj);
           rnewtable=find(TrajTable(:,1)==temptable(rTemp,1));
           %Next combine them and set 
           TrajTable(rnewtable,2:4)=TrajTable(roldtable,2:4);
           TrajTable(roldtable,:)=[0 0 0 0 0 0 0];
            
        end
    else 
    end
    clear Lastx Lasty Lastframe r1 temptable
end

LinkedTraj=SpotsTraj;
end