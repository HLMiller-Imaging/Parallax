function [FrameNos] = CreateFrameNos(PairingsListCol,trajmatched)
% CREATEFRAMENOS
% Creates the frame nos matrix; trajnumber (in appropriate row for easier
% indexing later), start frame number, end frame number
%
% INPUTS
% PairingsListCol   So you can work out what the largest traj number
%                   present is
% Trajmatched       the linked spots with all the spot information in
%
% OUTPUTS
% FrameNos          trajnumber (in appropriate row for easier
%                   indexing later), start frame number, end frame number
%
% Helen Miller May 2020

FrameNos=zeros(max(PairingsListCol),4);
for nn=1:max(PairingsListCol)
    rowsmatrix=find(PairingsListCol==nn);
   if size(rowsmatrix,1)>0
       trajrows=find(trajmatched(:,11)==nn); %rows corresponding to this trajnum
       FrameNos(nn,1:3)=[nn trajmatched(trajrows(1),2) trajmatched(trajrows(end),2)];
   end
end
end

