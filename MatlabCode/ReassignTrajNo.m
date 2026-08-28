function [NewTrajNo]=ReassignTrajNo(TrajNos)
% This function takes in a column of trajectory numbers that work with a
% set of x, y positions and reassigns the trajectory numbers so that
% instead of 4000, 5135,6720,6836 etc they go 1,2,3,4...
% This only works assuming that the data are already sorted into blocks of
% the same trajectory
%
% INPUTS
% TrajNos - The column of input trajectory numbers
%
% OUTPUTS
% NewTrajNo - The column of new trajectory numbers
%
% Helen Miller December 2019

NewTrajNo=zeros(length(TrajNos),1);
%first find the differences in the column of trajectory numbers, any that
%aren't zeros are changepoints
Diffs=diff(TrajNos);
%NB the differences will be aligned with the previous number eg 1 1 2 diffs
%= 0 1
DiffRows=find(Diffs~=0);
counter=1;
if isempty(DiffRows)==1
    %there's only one traj, give it number 1
    NewTrajNo(:,1)=1;
else
    for ii=1:length(DiffRows)+1
        if ii==1 %1 to first change
            NewTrajNo(1:DiffRows(ii),1)=counter;
            counter=counter+1;
        elseif ii==length(DiffRows)+1    % last change to end
            NewTrajNo(DiffRows(ii-1)+1:end,1)=counter;
            counter=counter+1;
        else      % between two changepoints
            NewTrajNo(DiffRows(ii-1)+1:DiffRows(ii),1)=counter;
            counter=counter+1;
        end

    end
end
end