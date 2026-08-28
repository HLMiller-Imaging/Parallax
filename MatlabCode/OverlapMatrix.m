function [OMatrix]=OverlapMatrix(InputMatrix)
% OVERLAPMATRIX
% creates a[OMatrix]=OverlapMatrix(InputMatrix) matrix showing which of the intervals overlap with each other
% If an empty trjectory is put in it is said not to overlap with itself
% INPUTS 
% Input Matrix  [startframe1; endframe1; startframe2; endframe2; ...]
%
% OUTPUTS
% OMatrix       1 if intervals overlap, 0 if not
%
% EXAMPLE CODE
% [OMatrix]=OverlapMatrix[1 4; 3 4;5 7;10 19];
%
% Helen Miller May 2020

Nints=length(InputMatrix)/2;
%Create matrix to put values into
OMatrix=zeros(Nints,Nints);
for ii=1:Nints
    for jj=0+ii:Nints
        if ii==jj
            if InputMatrix((2*ii)-1)>0
                OMatrix(ii,jj)=1;
            else %if trajectory doesn't exist it doesn't line up with itself
                OMatrix(ii,jj)=0;
            end
        else
            OMatrix(ii,jj)=OverlapCalc( [InputMatrix((2*ii)-1) InputMatrix((2*ii))], [InputMatrix((2*jj)-1) InputMatrix((2*jj))]);
        end
        OMatrix(jj,ii)=OMatrix(ii,jj); %Fill in the other half of the matrix without conditional statements for speed
    end
end
end