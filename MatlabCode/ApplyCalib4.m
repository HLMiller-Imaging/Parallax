function [threeDtrack] = ApplyCalib4(rampcalibdata,symcalibdata, top, bottom)
%
% This function takes in the results of fitting a calibration file and
% applies it to real data taken with the half mirror 3D microscope to
% extract 3D tracking information.
%
%calibdata=output from calibratez2
%
%top/bottom=numeric tables of ThunderSTORM output
%
% ApplyCalib4 works out z for just one x,y
% Helen Miller January 2018
%% 

dimsdatatop=size(top);
dimsdatabottom=size(bottom);
%calculate the differences between the x and y localisations
xDifferences=top(:,3)-bottom(:,3);
yDifferences=top(:,4)-bottom(:,4);

    %for each localisation work out the position
    for ii=1:dimsdatatop(1)
        %define z position by the y difference between the localisations.
        %This is done first to use the corrections calibrated in
        %calibratez3 on x and y 
        % Find the threee roots of the cubic
        temp = roots( [rampcalibdata(1,1) rampcalibdata(1,2) rampcalibdata(1,3) rampcalibdata(1,4)-yDifferences(ii)] );
        % get rid of the complex solutions
        temp(imag(temp) ~= 0) = [];
        %look for the solution in the calibration range +/- 100 (allow a
        %factor 2 extrapolation)
        testvector=zeros(1,length(temp(:,1)));
        for kk=1:length(temp(:,1))
            if abs(temp(kk))<symcalibdata(6)*2
                testvector(1,kk)=1;
            end
        end
        if sum(testvector)==1
            x1(ii)=testvector*temp;
        elseif sum(testvector)==0
            disp('No positions with the calib range were found. Assigning the closest. This is an extrapolation');
            [~,Index]=min(abs(temp));
            x1(ii)=temp(Index,1);
        elseif sum(testvector)>1
            error('Your calibration is multivalued within the working range - you cannot resolve this');
            pause
        end
        clear temp
        zpos(ii)=-1*x1(ii);
%         RemoveCalibOffset=yDifferences(ii)-calibdata(3); 
%         zpos(ii)=-1*(RemoveCalibOffset./calibdata(1)); %The minus one is to correct for all the changes in what is up or down in matlab image representation vs real world
        
        %define y position as the halfway point between the two
        %localisations- with a correction due to the found z position
        meanypos(ii)=top(ii,4)-(yDifferences(ii)./2); % sign is because ydiffs are negative
        ycorrection(ii)=(symcalibdata(4)*zpos(ii))+symcalibdata(5);%using mx+c from calibration fit
        ypos(ii)=meanypos(ii)+ycorrection(ii); %add because of way matlab displays images
        
        %define x position as the halfway point between the two
        %localisations with a correction due to found z position see which
        %image is further to the left to decide the correction
        if top(ii,3)>bottom(ii,3)
            meanxpos(ii)=bottom(ii,3)+(xDifferences(ii)./2);
            xcorrection(ii)=(symcalibdata(2)*zpos(ii))+symcalibdata(3); %using mx+c from calibration fit
            xpos(ii)=meanxpos(ii)-xcorrection(ii);
        else
            meanxpos(ii)=top(ii,3)+(xDifferences(ii)./2);
            xcorrection(ii)=(symcalibdata(2)*zpos(ii))+symcalibdata(3);%using mx+c from calibration fit
            xpos(ii)=meanxpos(ii)-xcorrection(ii);
        end
        
    end
    threeDtrack=[xpos' ypos' zpos'];
%     figure;
%     subplot(2,2,1);plot3(threeDtrack(:,1),threeDtrack(:,2),threeDtrack(:,3))
%     xlabel('x');ylabel('y');zlabel('z')
%     subplot(2,2,2);plot(threeDtrack(:,1),threeDtrack(:,2));
%     xlabel('x');ylabel('y');
%     subplot(2,2,3);plot(threeDtrack(:,1),threeDtrack(:,3));
%     xlabel('x');ylabel('z');
%     subplot(2,2,4);plot(threeDtrack(:,2),threeDtrack(:,3));
%     xlabel('y');ylabel('z');
end

