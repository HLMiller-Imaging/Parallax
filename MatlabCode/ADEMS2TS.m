function [spots,SkipFileFlag]=ADEMS2TS(SpotsCh1,pixsize)
% ADEMS2TS
% Takes the output of ADEMS code and converts the columns to the same order
% as ThunderSTORM. This is purely to deal with the historical hangover of
% initially having written these codes to analyse THUNDERSTORM data.
%
% INPUTS
% SPOTSCH1 - 12 column output from ADEMS code
% PIXSIZE  - size of one pixel in nm
%
% OUTPUTS
% spots    - 10 column output with same columns as ThunderSTORM tracking
% SkipFileFlag - returns a one if the file hasn't tracked and you need to
%                move to next file. 0 otherwise
%
% Example code: [spots]=ADEMS2TS(SpotsCh1,51.5)
%
% Helen Miller March 2020
a=size(SpotsCh1,1);
spots=zeros(size(SpotsCh1,1),10);
SkipFileFlag=0;
if a==0
    disp('No spots were found')
    SkipFileFlag=1;
else
spots(:,1)=SpotsCh1(:,12); %laser on frame
spots(:,2)=SpotsCh1(:,9); %frame no
spots(:,4)=SpotsCh1(:,1)*pixsize; %x incorporating switch from using rotating images
spots(:,3)=SpotsCh1(:,2)*pixsize; %yincorporating switch from using rotating images
spots(:,6)=SpotsCh1(:,5); %I bg corrected
spots(:,7)=SpotsCh1(:,11); % SNR
spots(:,8)=SpotsCh1(:,4); % mean local bg
spots(:,9)=SpotsCh1(:,6); %sigma x
spots(:,10)=SpotsCh1(:,7); %sigma y
end
end