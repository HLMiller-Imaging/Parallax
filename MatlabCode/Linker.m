function [ meetsCons, dist, rr ] = Linker( spotsn,spotsnlink,dimsnlink,AcceptCons,jj)
% This function finds candidate spots that meet all of the specified
% criteria that a spot can be linked to
       %%%% [dist,rr]=Linker(Sn,Sn_1,Dimsprev(1),AcceptCons,jj)
       
        %preallocate dist, IRatio, meetsCons
        dist=zeros(dimsnlink,1);
        IRatio=zeros(dimsnlink,1);
        meetsCons=zeros(dimsnlink,1);
        %find how it compares to other spots
        dist=(((spotsnlink(:,3)-spotsn(jj,3)).^2)+((spotsnlink(:,4)-spotsn(jj,4)).^2)).^0.5;
        IRatio=(spotsn(jj,6)./spotsnlink(:,6));
        % find spots that meet all the criteria
        for kk=1:dimsnlink
        if dist(kk,1)<AcceptCons(1)&& ...
                    AcceptCons(2)<=IRatio(kk,1) && IRatio(kk,1)<=AcceptCons(3)
        meetsCons(kk,1)=1;
        end
        end
        rr=find(meetsCons==1);

end

