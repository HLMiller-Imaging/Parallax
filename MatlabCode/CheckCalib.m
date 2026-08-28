function [TopCalibLoc, BottomCalibLoc]=CheckCalib(Pairings,calibtop,calibbottom,nframes)
%this function takes  a set of user defined pairings for bead calibration
%data and then sees which of them have a single location in all the frames.
% INPUTS
% Pairings - the user defined pairing data column 1 is the top traj no and
%            column 2 is the bottom traj no
% calibtop - the top spot localisations from ADEMS code reshaped using
%            ADEMS2TSCalib
% calibbottom - the bottom spot localisations from ADEMS code reshaped using
%            ADEMS2TSCalib
% nframes - number of frames in the calibration data
%
% OUTPUTS
% TopCalibLoc - the top localisation that is chosen for the calibration 
% BottomCalibLoc - the bottom localisation that is chosen for the
%                  calibration
%
% example code [TopCalibLoc, BottomCalibLoc]=CheckCalib(Pairings,calibtop,calibbottom,600)
%
% Helen Miller March 2020

% determine if there actually are any pairings
% 1. delete any pairings without a bottom loc
for jj=length(Pairings(:,2)):-1:1 %count backwards so deleting doesn't mess up row numbers
   if Pairings(jj,2)==0
       Pairings(jj,:)=[];
   end
end

% 2. Determine which pairings have nframes in top and bottom
for kk=length(Pairings(:,2)):-1:1
   %traj no is in column five
   %a)for each row of pairing find the set of localisations that corresponds
   %to it.
   rowstop=find(calibtop(:,5)==Pairings(kk,1));
   rowsbottom=find(calibbottom(:,5)==Pairings(kk,2));
   % b) Check there are nframes localisations
   ntop=length(rowstop);
   nbottom=length(rowsbottom);
   if nbottom==ntop &&ntop==nframes
       %right number, carry on
       % c) Check that the localisations are in sequential frames (i.e. 1 per
       % frame)
       tdiff2=diff(calibtop(rowstop,2),2); %find second order differences, should all be 0; could be -1, 0 or 1
       bdiff2=diff(calibbottom(rowsbottom,2),2); %find second order differences, should all be 0; could be -1, 0 or 1
       tnonzero=find(tdiff2); % top rows that aren't zero
       bnonzero=find(bdiff2); % bottom rows that aren't zero
       if length(bnonzero)==0
           if length(tnonzero)==0 %it's ok
           else
               Pairings(kk,:)=[];
           end
       else
           Pairings(kk,:)=[];
       end
       clear tdiff2 bdiff2
   else %get rid of the pairings if there aren't the right number
      Pairings(kk,:)=[]; 
   end
   clear rowstop rowsbottom ntop nbottom 
end

% 3. See how many pairings there are that meet these criteria - if only one return it
RowsLeft=length(Pairings(:,1));
if RowsLeft==1 %if there's only one left return it
    TopCalibLoc=calibtop(calibtop(:,5)==Pairings(1,1),:);
    BottomCalibLoc=calibbottom(calibbottom(:,5)==Pairings(1,2),:);
elseif RowsLeft==0
    error('There are no suitable candidates for the calibration');
else %choose between the ones that are best
% see which have the most intensity in the first top frame (usually equivalent to be sigma); col 6
    I=zeros(1,RowsLeft);
    for ii=1:RowsLeft
        r=find(calibtop(:,5)==Pairings(ii,1));
        I(ii)=calibtop(r(1),6);
    end
    MaxIrow=find(I==max(I)); %should return the row with max I in first frame
    TopLocTrajNo=Pairings(MaxIrow,1);
    TopCalibLoc=calibtop(calibtop(:,5)==Pairings(MaxIrow,1),:);
    BottomCalibLoc=calibbottom(calibbottom(:,5)==Pairings(MaxIrow,2),:);
end