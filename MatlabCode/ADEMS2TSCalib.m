function [spots]=ADEMS2TSCalib(SpotsCh1,pixsize,AcceptCons)
%reshapes the output of ADEMS code to be same shape as Thunderstorm output
%(historical artefact of switching spot finding codes)

spots=zeros(length(SpotsCh1),10);
spots(:,1)=SpotsCh1(:,12); %laser on frame
spots(:,2)=SpotsCh1(:,9); %frame no
spots(:,4)=SpotsCh1(:,1)*pixsize; %x incorporating switch from using rotating images
spots(:,3)=SpotsCh1(:,2)*pixsize; %yincorporating switch from using rotating images
spots(:,6)=SpotsCh1(:,5); %I bg corrected
spots(:,7)=SpotsCh1(:,11); % SNR
spots(:,8)=SpotsCh1(:,4); % mean local bg
spots(:,9)=SpotsCh1(:,6); %sigma x
spots(:,10)=SpotsCh1(:,7); %sigma y
[SpotsTraj]=LinkSpotsHM2(spots, AcceptCons,1);
spots(:,5)=SpotsTraj(:,11); %trajno 
end