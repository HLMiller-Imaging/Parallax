function [OverlapSwitch]=OverlapCalc(times1, times2)
%OVERLAPCALC
%takes two start and end times and determines if they overlap. Returns 1 if
%they do, 0 if they don't.
%
% INPUTS
% times1         [startframe endframe] of one interval
% times2         [startframe endframe] of second interval
%
% OUTPUTS
% overlapswitch  1 if they overlap, 0 if they don't
%
% EXAMPLE CODE
% [Switch]=OverlapCalc([1 10], [5 15])
%
% Helen Miller May 2020

%check if you have values at all
if times1(1,1)>0&&times2(1,1)>0
    %first level, define which starts first
    if times1(1,1)<times2(1,1) %times1 starts first
       if times1(1,2)>=times2(1,1) %times1 finishes after times2 starts
           OverlapSwitch=1;
       else OverlapSwitch=0;
       end
    elseif times1(1,1)>times2(1,1) %times2 starts first
       if times2(1,2)>=times1(1,1) %times2 finishes after times1 starts
           OverlapSwitch=1;
       else OverlapSwitch=0;
       end
    elseif times1(1,1)==times2(1,1)
        OverlapSwitch=1;
    end 
else
    OverlapSwitch=0;
end
end