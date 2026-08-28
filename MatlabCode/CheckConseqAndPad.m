function [ MatOut ] = CheckConseqAndPad( MatIn,Column )
%CHECKCONNSEQANDPAD
% takes in a matrix and a column number you  want to check if the values
% are consecutive  - outputs a matrix padded with zeros so the required
% variable is consecutive.
% INPUTS %%
% MATIN     Matrix in that you want to check if it is consecutive
% COLUMN    Numeric column number that you want to check if it's
%           consequetive on
%
% OUTPUTS %%
% MATOUT    Matrix output which is MatIn padded with zeros so there is a
%           row for every possible time value
%
% EXAMPLE CODE [SpotsTrajPadded]=CheckConseqAndPad(LinkedTrajs,2);
% Helen Miller May 2019

Dims=size(MatIn);
Diffs=MatIn(2:end,Column)-MatIn(1:end-1,Column);
%find the min and max value on the column you are sorting on and create a
%blank matrix
MinVal=min(MatIn(:,Column));
MaxVal=max(MatIn(:,Column));
Nrows=MaxVal-MinVal+1;
MatOut=zeros(Nrows,Dims(2));
%first line definitely goes in
MatOut(1,:)=MatIn(1,:);
Rcount=0; % keeps count of how many additional rows have been added
for ii=1:Dims(1)-1
    if Diffs(ii)==1
        %it's consecutive, add it to the table
        MatOut(ii+Rcount+Diffs(ii),:)=MatIn(ii+1,:);
    elseif Diffs(ii)>1
        %it's not consecutive, skip the rows that would have been
        %consecutive
        MatOut(ii+Rcount+Diffs(ii),:)=MatIn(ii+1,:);
        Rcount=Rcount+Diffs(ii)-1;
    elseif Diffs(ii)==0
        disp('Warning - There are multiple localisations in one of these frames and I arbitrarily deleted the second one of them')
        %don't add it to the table
        Rcount=Rcount-1;
    else
        disp('Something unexpected has gone wrong in correlating the trajectories')
    end
end

end

