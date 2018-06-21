function [xgrad, ygrad, zgrad] = grad_pattern_rs2d(n_rings)

% Creates the gradient pattern used in the RS2D; that is specifying the  
% number of rings n_rings, one hemishpere is completely calculated from
% equator to pole, then the other hemisphere is calculated. A plot of the
% gradient directions is also generated.


rings = n_rings;
tmp=pi/(2*rings);
areaxsamp=tmp*tmp;
dangle=pi/(2*rings);

nsum=0;
for n = 1:rings
    theta=n*dangle;
	area=2*pi*(1-cos(theta));
	m=round(area/areaxsamp-nsum);
	nv(n)=m;
	nsum=nsum+m;
end
    n_tot = nsum*2;
k=0;
dangz=pi/(2*rings);
for n=1:rings
    j=rings+1-n;
    m=nv(j);
    anglez=(n-.5)*dangz;
    dangh=2*pi/m;
    for nh = 1:m
        k=k+1;
        angleh=(nh-1)*dangh;
        horiz_angle(j,nh) = angleh;
        zgrad(k)=sin(anglez);
        xgrad(k)=cos(anglez)*cos(angleh);
        ygrad(k)=cos(anglez)*sin(angleh);
    end
end


for n=1:rings
    j=rings+1-n;
    m=nv(j);
    anglez=(n-.5)*dangz;
    dangh=2*pi/m;
    for nh = 1:m
        k=k+1;
        angleh=(nh-1)*dangh;
        horiz_angle(j,nh) = angleh;
        zgrad(k)=-sin(anglez);
        xgrad(k)=-cos(anglez)*cos(angleh);
        ygrad(k)=-cos(anglez)*sin(angleh);
    end
end


 figure(1)
 scatter3(xgrad,ygrad,zgrad, '.')
