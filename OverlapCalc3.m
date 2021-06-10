function [interval]=OverlapCalc3(times1, times2)
%OVERLAPCALC3
%takes two start and end times and determines the interval of frame numbers
%over which they overlap.
%
% INPUTS
% times1         [startframe endframe] of one interval
% times2         [startframe endframe] of second interval
%
% OUTPUTS
% [interval]     [overlapintervalstart1 overlapintervalend] in frame nos
%
% EXAMPLE CODE
% [Interval]=OverlapCalc([1 10], [5 15])
%
% Helen Miller May 2020

%check if you have values at all
if times1(1,1)>0&&times2(1,1)>0
    %first level, define which starts first
    if times1(1,1)<times2(1,1) %times1 starts first
       if times1(1,2)>=times2(1,1) %times1 finishes after times2 starts
           interval=[times2(1,1) min(times1(1,2), times2(1,2))];
       else interval=[0 0];
       end
    elseif times1(1,1)>times2(1,1) %times2 starts first
       if times2(1,2)>=times1(1,1) %times2 finishes after times1 starts
           interval=[times1(1,1) min(times1(1,2), times2(1,2))];
       else interval=[0 0];
       end
    elseif times1(1,1)==times2(1,1)
        interval=[times1(1,1) min(times1(1,2), times2(1,2))];
    end 
else
    OverlapSwitch=0;
end
end