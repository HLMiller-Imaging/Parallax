function [OverlapSwitch]=OverlapCalc2(times1, times2)
%OVERLAPCALC
%takes two start and end times and determines how much they overlap by and 
%returns the amount of overlap. 
%
% INPUTS
% times1         [startframe endframe] of one interval
% times2         [startframe endframe] of second interval
%
% OUTPUTS
% overlapswitch  amount of overlap
%
% EXAMPLE CODE
% [Switch]=OverlapCalc2([1 10], [5 15])
%
% Helen Miller May 2020

if times1(1,1)>0&&times2(1,1)>0
%first level, define which starts first
    if times1(1,1)<times2(1,1) %times1 starts first
       if times1(1,2)>=times2(1,1) %times1 finishes after times2 starts
           %find which ends first
           Endtime = min(times1(1,2),times2(1,2));
           OverlapSwitch=Endtime-times2(1,1)+1;
       else OverlapSwitch=0;
       end
    elseif times1(1,1)>times2(1,1) %times2 starts first
       if times2(1,2)>=times1(1,1) %times2 finishes after times1 starts
           %find which ends first
           Endtime = min(times1(1,2),times2(1,2));
           OverlapSwitch=Endtime-times1(1,1)+1;
       else OverlapSwitch=0;
       end
    elseif times1(1,1)==times2(1,1)
        %find which ends first
        Endtime = min(times1(1,2),times2(1,2));
        OverlapSwitch=Endtime-times1(1,1)+1;
    end 
else
    OverlapSwitch=0;
end
end