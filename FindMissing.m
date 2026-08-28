function [MissingLoc]=FindMissing(Localisation,OtherSpotsChannel,whichchannel,calibmap,tolfactor,pixsize)
% Find a missing localisation for a top or bottom localisation by searching in the
% original found spots
% INPUTS
% LOCALISATION - The row from trajectory corresponding to the localisation
%                you wish to find
% OTHERSPOTSCHANNEL - The raw tracking output from ADEMS code (reshaped to 
%                be like thunderstorm) for the channel missing the 
%                localisation(top or bottom)
% WHICHCHANNEL - Switch for which channel the localisation you have is in. 0 is
%                top, 1 is bottom
% CALIBMAP     - The mapping between top and bottom images found according
%                to the user matched up localisations in the calibration
%                frame. How to get from top to bottom. x and y.
% TOLFACTOR    - The number of pixels tolerance (+/-) in linking correlated
%                trajectories. 5 is strongly recommended
% PIXSIZE      - Size of pixels in nm
%
% OUTPUTS
% MISSINGLOC   - The selected localisation matched with. All zeros if
%                nothing was found, a single localisation otherwise. If
%                there were multiple candidates the one closest to the
%                centre of the area will be the one returned.
%
% EXAMPLE CODE  [MissingLoc]=FindMissing(minitop(1,:),SpotsCh1bottom,0,calibmap,5,51.5)
%
% Helen Miller May 2020

%Preallocate a variable of the right size to return a localisation in
Dimsreturn=size(Localisation);
MissingLoc=zeros(Dimsreturn(1,1),Dimsreturn(1,2));

%which frame is the localisation you have in?
FrameNo=Localisation(1,2);

%find all the spots in that frame in the other channel
PotentialLocs=OtherSpotsChannel(OtherSpotsChannel(:,2)==FrameNo,:);

%determine any localisations which are in the tolfactor region of
%acceptance and return the candidates (2 cases)
minX=Localisation(1,3)-(tolfactor*pixsize);
maxX=Localisation(1,3)+(tolfactor*pixsize);
minY=Localisation(1,4)-(tolfactor*pixsize);
maxY=Localisation(1,4)+(tolfactor*pixsize);
loopcounter=1;
    if whichchannel==0 %you have the localisation in the top channel
        %localisation+calibmap
        %loop through the PotentialLocs to see if any meet criteria
        for ii=1:length(PotentialLocs(:,1))
            if PotentialLocs(ii,3)>(minX+calibmap(1,1))&&PotentialLocs(ii,3)<(maxX+calibmap(1,1))&& PotentialLocs(ii,4)>(minY+calibmap(1,2))&&PotentialLocs(ii,4)<(maxY+calibmap(1,2))
                ListOfCands(loopcounter,1)=ii;
                loopcounter=loopcounter+1;
                if loopcounter>2
                    %if you have multiple candidates define the centre of
                    %the search region
                    Centre=[Localisation(1,3)+calibmap(1,1) Localisation(1,4)+calibmap(1,2)];
                end
            end    
        end
    elseif whichchannel==1 % you have the localisation in the bottom channel
        %localisation-calib map
        for jj=1:length(PotentialLocs(:,1))
            if PotentialLocs(jj,3)>(minX-calibmap(1,1))&&PotentialLocs(jj,3)<(maxX-calibmap(1,1))&& PotentialLocs(jj,4)>(minY-calibmap(1,2))&&PotentialLocs(jj,4)<(maxY-calibmap(1,2))
                ListOfCands(loopcounter,1)=jj;
                loopcounter=loopcounter+1;
                if loopcounter>2
                    %if you have multiple candidates define the centre of
                    %the search region
                    Centre=[Localisation(1,3)-calibmap(1,1) Localisation(1,4)-calibmap(1,2)];
                end
            end    
        end
    end

%inspect the list of candidates:
A=exist('ListOfCands');
if A==0 %No candidate for matching
    disp('There was no candidate for matching')
    %The missing loc will be returned as zeros
else %there was at least one candidate
    NoCands=length(ListOfCands(:,1));
    if NoCands==1 %only a single candidate
        disp('There was one suitable candidate and we are returning it')
        MissingLoc=PotentialLocs(ListOfCands(1,1),:);
    elseif NoCands>1 %multiple candidates
        disp('There was more than one candidate it could be matched with; I will return the one that was closest to the centre')
        %work out how far each possible one was from the centre of the region
        DistCand(:,1)=sqrt((PotentialLocs(ListOfCands(:,1),3)-Centre(1,1)).^2+(PotentialLocs(ListOfCands(:,1),4)-Centre(1,2)).^2);
        %take the closest
        rbest=find(DistCand(:,1)==min(DistCand(:,1)));
        MissingLoc=PotentialLocs(ListOfCands(rbest,1),:);
    end
end
end