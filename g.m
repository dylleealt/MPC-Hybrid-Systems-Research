%Author: Calvin John. Last Updated on 7/13/2016. 
function [optX, optY] = g(x,N)
tic; 
%T = Timer interval. 
persistent T; 
T = 0.2; 
%x = cell2mat(xout);
%x = xout; 
%optXY is the optimal XY target for the quadcopter given its current 
%state, as well as the projectile's current state. 
optXY = MPC(x,N,T)'; 
optX = optXY(1); 
optY = optXY(2); 

if((optX) > 1.9)
    optX = 1.5; 
end
if(optX < -1.9)
    optX = -1.5; 
end
if(optY < -.5)
    optY = -.3;
end
if(optY > 1.9)
    optY  = 1.5; 
end

if(norm(x(7:9))<0.05)
    optX = x(1); 
    optY = x(2); 
end
% File IO to python -- writes the coordinates
MtoP = fopen('MtoP.txt', 'w');
fprintf(MtoP, '%4.4f\n', optX);
fprintf(MtoP, '%4.4f\n', optY);
fclose(MtoP);

%disp(toc);
end

