function [TopFrameNos,BottomFrameNos,topsmatched,bottomsmatched,cmatched]=AssignTrajNum(TopFrameNos,BottomFrameNos,kk,Col,topsmatched,bottomsmatched,cmatched)
% ASSIGNTRAJNUM
% It checks whether trajectory numbers are already assigned for linking 
% between the top and bottom set of lcalisations for an image, and then
% assigns, and changes anything necessary to make everything consistent
%
% INPUTS
% TopFrameNos     4 column input; traj no (within set); start frame; end
%                 frame; assigned traj no (all zeros when passed to this
%                 function). The row number is the trajectory number
% BottomFrameNos  As TopFrameNos but for the bottom image
% kk              the top frame trajectory number
% Col             bottom frame trajectory number
% topsmatched     all the existing top localisation information. Column 12
%                 is blank waiting for assigned traj nos.
% bottomsmatched  like topsmatched but for the bottom image localisation
%                 information
% cmatched        Counter for assigning trajectory numbers
%
% OUTPUTS
% TopFrameNos     4 column input; traj no (within set); start frame; end
%                 frame; assigned traj no (now allocated). The row number 
%                 is the trajectory number in the top localisation data
% BottomFrameNos  As TopFrameNos but for the bottom image
% topsmatched     all the existing top localisation information. Column 12
%                 contains assigned traj nos.
% bottomsmatched  like topsmatched but for the bottom image localisation
%                 information
% cmatched        Counter for assigning trajectory numbers
%
% EXAMPLECODE
% [~,~,topsmatched,bottomsmatched,~]=AssignTrajNum(TopFrameNos,BottomFrameNos,3,10,topsmatched,bottomsmatched,1)
%
% Helen Miller May 2020

testmatchedtop=TopFrameNos(kk,4);
testmatchedbottom=BottomFrameNos(Col,4);
toptrajrows=find(topsmatched(:,11)==kk);
bottomtrajrows=find(bottomsmatched(:,11)==Col);
if testmatchedbottom==0&&testmatchedtop==0 %no traj no assigned
    topsmatched(toptrajrows,12)=cmatched;
    bottomsmatched(bottomtrajrows,12)=cmatched;
    TopFrameNos(kk,4)=cmatched;
    BottomFrameNos(Col,4)=cmatched;
    cmatched=cmatched+1;
elseif testmatchedbottom>0&&testmatchedtop==0
    topsmatched(toptrajrows,12)=testmatchedbottom;
    bottomsmatched(bottomtrajrows,12)=testmatchedbottom;
    TopFrameNos(kk,4)=testmatchedbottom;
elseif  testmatchedbottom==0&&testmatchedtop>0
    topsmatched(toptrajrows,12)=testmatchedtop;
    bottomsmatched(bottomtrajrows,12)=testmatchedtop;
    BottomFrameNos(Col,4)=testmatchedtop;
else %this is when both trajectories have already been assigned numbers; 
%keep testmatched top, change all the ones that have already been assigned
    topsmatched(toptrajrows,12)=testmatchedtop;
    bottomsmatched(bottomtrajrows,12)=testmatchedtop;
    BottomFrameNos(Col,4)=testmatchedtop;
    %change all the ones with the old assignment
    rowsOldAssignB=find(bottomsmatched(:,12)==testmatchedbottom);
    rowsOldAssignT=find(topsmatched(:,12)==testmatchedbottom);
    %find what all of these had in row 11 and change to topframeno and
    %bottomframenos 
    if size(rowsOldAssignB,1)>0
    for pp=1:size(rowsOldAssignB,1)
       BottomFrameNos(bottomsmatched(rowsOldAssignB(pp),11),4)=testmatchedtop; 
    end
    end
    if size(rowsOldAssignT,1)>0
    for qq=1:size(rowsOldAssignT,1)
       TopFrameNos(topsmatched(rowsOldAssignT(qq),11),4)=testmatchedtop; 
    end
    end
    bottomsmatched(rowsOldAssignB,12)=testmatchedtop;
    topsmatched(rowsOldAssignT,12)=testmatchedtop;
    
end

end