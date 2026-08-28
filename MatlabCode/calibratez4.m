function [rampcalibdata,symcalibdata,neutral]=calibratez4(top,bottom,nSample,sHz, nframes, fHz,zcalibstepsize)
%% calibratez4
%This function calibrates z based on the input parameters of an image file
%in which fluorescent beads are repeatedly ramped up and down, staying at
%each step position for several frames (here assumed to be at least 6 - line 59 and 60). It fits the z ramp with a cubic
%equation, and also assesses how far the x and y mean position moves from
%neutral as a function of the applied z separation.
%
% Inputs:
% top;      the localisations from the upper image in the calibration file
% bottom;   the localisations from the lower image in the calibration file
% nSample;  the number of samples in the calibration program covering one
%           cycle. 12000 default
% sHz;      the frequency of the sampling in the labview calibration program.
%           default 250Hz.
% fHz;      the frame rate of image acquisition of the calibration file in Hz
%           6.6667 default
% nframes;  number of image frames in the calibration file
% zcalibstepsize;   size of z step in nm (usually 100nm). Calculated as the
%           amplitude used in the calibration program/number of steps in each 
%           direction (10 steps is usual).
%
% Outputs:
% rampcalibdata;    The means (top row) and std (bottom row) of the coefficients
%                   of the cubic fitted to the complete z ramps. The cubic value is
%                   in the first column, down to the intercept in the final
%                   column.
% symcalibdata;     nramps, xgrad,xintercept,ygrad,yintercept, where the
%                   final four columns relate to the linear fit to the deviation 
%                   from zero of the mean of the x and y positions on the
%                   first full ramp.
% neutral;          the mean position of the neutral position on the ramp
%                   used to calculate the calibration, no calibration
%                   applied.
%
% N.B. Up/down in the y direction are defined arbitrarily in this code, so
% are actually inverted. Corrections to convert back to the real world 
% situation are applied in the follow on code 'ApplyCalib'.
% 
% Helen Miller January 2018
%%
%calculate the number of steps
TimeCycle=nSample./sHz;
TimeImages=nframes./fHz;
Ncycles=TimeImages./TimeCycle;
noSteps=floor(40*Ncycles);
%pause
%Work out the difference in x and y coords between the two images
xDifferences=top(:,3)-bottom(:,3);
yDifferences=top(:,4)-bottom(:,4); 

% find the changepoints in the signal to identify the different levels
figure;
scatter(top(:,2),yDifferences);
hold on
title('Distance between localisations over time')
xlabel('Frame number')
ylabel('Distance between localisations (nm)')
findchangepts(yDifferences,'MaxNumChanges',noSteps,'Statistic','mean','MinDistance',6); %the assumption that there are at least 6 stationary frames is here in the MinDistance value
ipt=findchangepts(yDifferences,'MaxNumChanges',noSteps,'Statistic','mean','MinDistance',6);
for ii=1:noSteps
    if ii==1
        meanlevel(ii)=mean(yDifferences(1:ipt(ii)));
        stdmean(ii)=std(yDifferences(1:ipt(ii)));
        meantopxlevel(ii)=mean(top(1:ipt(ii),3));
        meantopylevel(ii)=mean(top(1:ipt(ii),4));
        meanbottomxlevel(ii)=mean(bottom(1:ipt(ii),3));
        meanbottomylevel(ii)=mean(bottom(1:ipt(ii),4));
    else
        meanlevel(ii)=mean(yDifferences(ipt(ii-1):ipt(ii)));
        stdmean(ii)=std(yDifferences(ipt(ii-1):ipt(ii)));
        meantopxlevel(ii)=mean(top(ipt(ii-1):ipt(ii),3));
        meantopylevel(ii)=mean(top(ipt(ii-1):ipt(ii),4));
        meanbottomxlevel(ii)=mean(bottom(ipt(ii-1):ipt(ii),3));
        meanbottomylevel(ii)=mean(bottom(ipt(ii-1):ipt(ii),4));
    end
end

%Look for extrema of levels to identify the up and down ramps
[minval indexpos]=min(meanlevel);
[maxval indexmax]=max(meanlevel);
sanitycheck=mod(indexmax-indexpos,20);
if sanitycheck~=0
    disp('ERROR - wrong number of steps identified. Please check that the step data covers 10 steps in each direction from the neutral position.')
else
    %If it looks ok, carry on and identify the levels.
    %calculate number of complete ramps
    firstminpos=mod(indexpos,40);
    firstmaxpos=mod(indexmax,40);
    %calculate the mean neutral position
    x0=(meantopxlevel(10+firstminpos)+meanbottomxlevel(10+firstminpos))./2;
    y0=(meantopylevel(10+firstminpos)+meanbottomylevel(10+firstminpos))./2;
    neutral=[x0,y0];
    
    %make a plot of the x/y traces against z from first min position.
    %assumes 21 steps %also plot the difference between them so you can see how you expect
    %the centre position to vary with defocus    
    figure; 
    subplot(1,2,1);plot((-10:10)*zcalibstepsize,meantopxlevel(firstminpos:20+firstminpos)-meantopxlevel(10+firstminpos));
    hold on
    plot((-10:10)*zcalibstepsize,meanbottomxlevel(firstminpos:20+firstminpos)-meanbottomxlevel(10+firstminpos));
    plot((-10:10)*zcalibstepsize,meantopylevel(firstminpos:20+firstminpos)-meantopylevel(10+firstminpos));
    plot((-10:10)*zcalibstepsize,meanbottomylevel(firstminpos:20+firstminpos)-meanbottomylevel(10+firstminpos));
    legend('top x','bottom x','top y','bottom y');
    xlabel('z distance travelled from focus position');
    ylabel('position (nm) relative to lowest position');
    title('raw x and y shapes against z')
    
    %second subplot, See how far from zero they are (i.e. the y top + y bottom and
    %xtop+xbottom
    subplot(1,2,2);plot((-10:10)*zcalibstepsize,meantopxlevel(firstminpos:20+firstminpos)-meantopxlevel(10+firstminpos)+meanbottomxlevel(firstminpos:20+firstminpos)-meanbottomxlevel(10+firstminpos),'b');
    hold on
    plot((-10:10)*zcalibstepsize,meantopylevel(firstminpos:20+firstminpos)-meantopylevel(10+firstminpos)+meanbottomylevel(firstminpos:20+firstminpos)-meanbottomylevel(10+firstminpos),'k');
    %Set up a linear fit to these
    ft1 = fittype( 'poly1' );
    [zdist, xnonsym] = prepareCurveData( (-10:10)*zcalibstepsize, meantopxlevel(firstminpos:20+firstminpos)-meantopxlevel(10+firstminpos)+meanbottomxlevel(firstminpos:20+firstminpos)-meanbottomxlevel(10+firstminpos) );
    [Fitxnonsym] = fit( zdist, xnonsym, ft1 );
    xintercept=Fitxnonsym.p2;
    xgrad=Fitxnonsym.p1;
    plot(Fitxnonsym,'b')
    [zdist, ynonsym] = prepareCurveData( (-10:10)*zcalibstepsize, meantopylevel(firstminpos:20+firstminpos)-meantopylevel(10+firstminpos)+meanbottomylevel(firstminpos:20+firstminpos)-meanbottomylevel(10+firstminpos) );
    [Fitynonsym] = fit( zdist, ynonsym, ft1 );
    yintercept=Fitynonsym.p2;
    ygrad=Fitynonsym.p1;
    plot(Fitynonsym,'k')
    legend('x differences','y differences','xfit','yfit');
    xlabel('z distance travelled from focus position');
    ylabel('Net movement (nm) of centre of localisations from focus location');
    title('Net centre movement')
    
    %carry on
    nramps=floor((noSteps-firstminpos)./20);
    if firstmaxpos>firstminpos
        %This is likely to be the case, first full ramp is an upramp
        %calc number of ramps
        nUpramps=ceil(nramps./2);
        nDownramps=floor(nramps./2)  ;
    elseif firstmaxpos<firstminpos
            %less likely - implies a delay in triggering image acquisition
        %again calc number of ramps
        nUpramps=floor(nramps./2);
        nDownramps=ceil(nramps./2);
    else
        disp('ERROR - Maximum and minimum identified at the same points')
    end
 %make all the upramps and downramps in a loop and make them all on a
 %figure also fit them each with a polynomial 
 % Set up fittype and options.
ft = fittype( 'poly3' );
%make figure
 figure;
 title('All ramps overlaid')
 xlabel('Step number')
 ylabel('Distance between two paired localisations (nm)')
 hold on
  if nUpramps>0
    for jj=1:nUpramps
        upramp(jj,:)=meanlevel(firstminpos+((jj-1)*40):firstminpos+((jj-1)*40)+20);
        scatter((-10:10)*zcalibstepsize,upramp(jj,:),'+')
        [xupData(jj,:), yupData(jj,:)] = prepareCurveData( (-10:10)*zcalibstepsize, upramp(jj,:) );
        FitVarUp{jj} = fit( xupData(jj,:)', yupData(jj,:)', ft );
        coeffsUp(jj,:)=[FitVarUp{jj}.p1 FitVarUp{jj}.p2 FitVarUp{jj}.p3 FitVarUp{jj}.p4];
    end
  end
  if nDownramps>0
    for kk=1:nDownramps
        downramp(kk,:)=meanlevel(firstmaxpos+((kk-1)*40):firstmaxpos+((kk-1)*40)+20);
        scatter((10:-1:-10)*zcalibstepsize,downramp(kk,:),'x')
        [xdownData(kk,:), ydownData(kk,:)] = prepareCurveData( (10:-1:-10)*zcalibstepsize, downramp(kk,:) );
        FitVarDown{kk} = fit( xdownData(kk,:)', ydownData(kk,:)', ft );
        coeffsDown(kk,:)=[FitVarDown{kk}.p1 FitVarDown{kk}.p2 FitVarDown{kk}.p3 FitVarDown{kk}.p4];
    end         
  end
% plot the neutral position over all the ramps    
   figure;
 if nUpramps>0
    scatter(1:nUpramps,upramp(:,11),'+b')
 end
    hold on
    if nDownramps>0
    scatter(1:nDownramps,downramp(:,11),'xr')
    end
    title('Neutral position over ramps')
    xlabel('Ramp number')
    ylabel('Distance between two paired localisations (nm)')
    
%calculate means and standard deviations of gradients
if nUpramps>0
MeanCoeffsUp=mean(coeffsUp,1);
StdCoeffsUp=std(coeffsUp,0,1);

end

if nDownramps>0
MeanCoeffsDown=mean(coeffsDown,1);
StdCoeffsDown=std(coeffsDown,0,1);
end

if nDownramps>0&&nUpramps>0
Allcoeffs=vertcat(coeffsDown,coeffsUp);
Allmeans=mean(Allcoeffs);
Allstd=std(Allcoeffs);

words=['There are both upramps and downramps present. '];
words1=['Upramp coeffs:', num2str(MeanCoeffsUp)];
words2=['Downramp coeffs:',num2str(MeanCoeffsDown)];
% words1=['Mean up gradient = ',num2str(MeanGradUp),'+/-',num2str(StdGradUp),'Mean down gradient = ',num2str(MeanGradDown),'+/-',num2str(StdGradDown)];
% words2=['Mean up intercept = ',num2str(MeanInterceptUp),'+/-',num2str(StdInterceptUp),'Mean down Intercept = ',num2str(MeanInterceptDown),'+/-',num2str(StdInterceptDown)];
disp(words)
disp(words1)
disp(words2)

elseif nUpramps>0&&nDownramps==0
  Allmeans=MeanCoeffsUp;
  Allstd=StdCoeffsUp;
    
elseif nDownramps>0&&nUpramps==0
    Allmeans=MeanCoeffsDown;
    Allstd=StdCoeffsDown;
    
end    
    
% Should check the means and std of the gradients to ensure they are not hugely
% different
rampcalibdata=vertcat(Allmeans,Allstd);
symcalibdata=horzcat(nramps, xgrad,xintercept,ygrad,yintercept);
end
%calibdata=horzcat(OverallgradMean,OverallgradStd,OverallIntMean,OverallIntStd,nramps, xgrad,xintercept,ygrad,yintercept);
end




% m=-10
% for ii=1:21
% firstnumber=57+(ii*8);
% temp=zeros(2,6);
% for iii=1:6
% temp(1,iii)=xDifferences(firstnumber-1+iii);
% temp(2,iii)=yDifferences(firstnumber-1+iii);
% end
% meanx=mean(temp(1,:));
% meany=mean(temp(2,:));
% stdx=std(temp(1,:));
% stdy=std(temp(2,:));
% output(ii,:)=horzcat(m, meanx, meany, stdx, stdy);
% clear temp
% m=m+1;
% end