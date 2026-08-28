function [ xyzPoints ] = plotstitched3( topsmatched,bottomsmatched,showgraphs,rampcalibdata,symcalibdata,calibmap,tolfactor,pixsize,lookformore,linkcons)
% PLOTSTITCHED3
% This function makes some rough plots out of the tracks that have been stitched
% together. NB this does use the calibration. Plotstitched3 should have up and down the
% correct way around in z
%
% INPUTS %%
% TOPSMATCHED   Exact copy of toptrajs with new column 12 including the
%               matched trajectory numbers
% BOTTOMSMATCHEDExact copy of bottomtrajs with new column 12 including the
%               matched trajectory numbers
% SHOWGRAPHS    flag to show the graphs of the two trajectories being
%               compared; 1 to turn on figures, 0 else
% RAMPCALIBDATA - The calibration data part 1
% SYMCALIBDATA  - The calibration data part 2
% CALIBMAP      - The mapping between top and bottom images found according
%                to the user matched up localisations in the calibration
%                frame
% TOLFACTOR     - the number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% PIXSIZE       - size of pixels in nm
% LOOKFORMORE   - switch to look for extra localisations where you have
%                 either a top loc or a bottom loc 
% LINKCONS      - param for linking
%
% OUTPUTS %%
% XYZPOINTS     5 column output - x,y,z,frameno,trackno of localisations
%               that are in trajectories
%
% EXAMPLE CODE
% [ xyzPoints ] = plotstitched3( topsmatched,bottomsmatched,0 )
%
% Helen Miller May 2019

%loop over the mega tracks
    %initalise localisation counter for making final table of all x,y,z
    loccounter=1;
for ii=1:max(topsmatched(:,12))
    %create minitables of  the trajectory in question
    rowstop=find(topsmatched(:,12)==ii);
    if size(rowstop,1)>0
    minitop=topsmatched(rowstop,:);
    rowsbottom=find(bottomsmatched(:,12)==ii);
    minibottom=bottomsmatched(rowsbottom,:);
    %find which frames a track has both localisations in
    %find which one starts first and ends last
    firstframe= CompareNums( minitop(1,2),minibottom(1,2),2 );
    lastframe=CompareNums(minitop(end,2),minibottom(end,2),1);
    
    %now loop over the frame numbers seeing which frames are in both
   % figure;
        for jj=firstframe:lastframe
        if jj==firstframe
        %initialise prevloc at time -1
        prevloc=[0,0,0,-1];
        end
        rowintop=find(minitop(:,2)==jj);
        rowinbottom=find(minibottom(:,2)==jj);
        %see if these are nonzero
        dimtop=length(rowintop);
        dimbot=length(rowinbottom);
        if dimtop==1&&dimbot==1
            %ideal case, 1 localisation in each frame
            [threeDtrack] = ApplyCalib4(rampcalibdata,symcalibdata, minitop(rowintop,:), minibottom(rowinbottom,:));%%This gives it just the pair to find the z of
            newloc=[threeDtrack(1,1),threeDtrack(1,2),threeDtrack(1,3),jj];
        elseif dimtop==1&&dimbot==0
            %only have toploc
            if lookformore==1
                disp('There is only a toploc -look for a potential pair')
                [MissingLoc]=FindMissing(minitop(rowintop,:),bottomsmatched,0,calibmap,tolfactor,pixsize);
                %check if something was found
                if MissingLoc(1,1)==0 %it wasn't
                    disp('No pair found')
                newloc=[0,0,0,-1];
                else
                [threeDtrack] = ApplyCalib4(rampcalibdata,symcalibdata, minitop(rowintop,:), MissingLoc); 
                newloc=[threeDtrack(1,1),threeDtrack(1,2),threeDtrack(1,3),jj];
                %find the distance from this potential pair in 3D
                dist=((prevloc(1,1)-newloc(1,1)).^2+(prevloc(1,2)-newloc(1,2)).^2+(prevloc(1,3)-newloc(1,3)).^2).^0.5;
                    if dist<linkcons(1,1)
                        %great, keep the new loc
                        disp('Pair Found')
                    else
                        newloc=[0,0,0,-1];
                        disp('No pair found')
                    end
                end
            else
                disp('There is only a toploc')
                newloc=[0,0,0,-1];
            end
        elseif dimtop==0&&dimbot==1
            %only have bottom loc
            if lookformore==1
                disp('There is only a bottomloc - look for a potential pair')

                [MissingLoc]=FindMissing(minibottom(rowinbottom,:),topsmatched,1,calibmap,tolfactor,pixsize);
                %check if something was found
                if MissingLoc(1,1)==0 %it wasn't
                    disp('No pair found')
                newloc=[0,0,0,-1];
                else
                [threeDtrack] = ApplyCalib4(rampcalibdata,symcalibdata, MissingLoc, minibottom(rowinbottom,:)); 
                newloc=[threeDtrack(1,1),threeDtrack(1,2),threeDtrack(1,3),jj];
                %find the distance from this potential pair in 3D
                dist=((prevloc(1,1)-newloc(1,1)).^2+(prevloc(1,2)-newloc(1,2)).^2+(prevloc(1,3)-newloc(1,3)).^2).^0.5;
                    if dist<linkcons(1,1)
                        %great, keep the new loc
                        disp('Pair Found')
                    else
                        newloc=[0,0,0,-1];
                        disp('No pair found')
                    end
                end
             else
                disp('There is only a bottomloc')
                newloc=[0,0,0,-1];
            end   
        elseif dimtop==0&&dimbot==0
            %neither top nor bottom has a trajectory in a frame
            disp('There is neither a top or bottom loc')
            newloc=[0,0,0,-1];
        else
            disp('There is probably more than one localisation in a frame in one of these trajectories');
            newloc=[0,0,0,-1];
        end
            prevloc=newloc;
        %create output x,y,z,frameno,trackno
         allPoints(loccounter,:)=horzcat(newloc(1:3),jj,ii);
         loccounter=loccounter+1;    
        end
    end
end
if exist('allPoints')>0
xyzPoints = allPoints(any(allPoints(:,1:3),2),:);
else 
    xyzPoints=[0 0 0 0 0];
end

if showgraphs==1
    figure; colormap jet
    for ll=1:max(xyzPoints(:,5))
       scatter3(xyzPoints(xyzPoints(:,5)==ll,1),xyzPoints(xyzPoints(:,5)==ll,2),xyzPoints(xyzPoints(:,5)==ll,3),6,xyzPoints(xyzPoints(:,5)==ll,4)); hold on
       plot3(xyzPoints(xyzPoints(:,5)==ll,1),xyzPoints(xyzPoints(:,5)==ll,2),xyzPoints(xyzPoints(:,5)==ll,3),'k')
       xlabel('X');ylabel('Y');zlabel('Z');
    end    
end

%things I might want this to do:
%1) go back and look for missed localisations
end