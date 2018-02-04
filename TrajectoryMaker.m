%Author: Calvin John. Last Updated on 7/13/2016. 
function XYZ = TrajectoryMaker(x,N,K,deltaT)
%Construction of K linear trajectories from current position (x0,y0) that span
%a circle of radius R = N*deltaT*vMax centered about (x0,y0), where N = event
%horizon, deltaT = discrete timer, and vMax = maximum velocity of the quadcopter. 

x0 = x(1);
y0 = x(2); 
%z0 = x(3); 
vMax = 3; 
R = N*deltaT*vMax; 

%Discretize circle angle range = [0,2pi] into K evenly spaced angles. These
%angles will be stored in the angle array theta so that theta(1) = 0,
%theta(2) = 2pi/(K-1),...,theta(K) = 2pi. 

theta = linspace(0,2*pi,K); 

%The arrays x and y each store all x(i) and y(i) coordinates--where i is an
%integer in 1:K. Each (x(i),y(i)) denotes a point on the circle C = C((x0,y0),R)
%associated with the angle 0(i) in the array theta, where C((x,y),r) refers
%to a circle of radius r centered at (x,y). 

x = x0 + double(R)*double(cos(theta)); 
y = y0 + double(R)*double(sin(theta)); 

%XY = Three dimensional matrix comprised of all discretized lines extending
%from (x0,y0) to the circle C = C((x0,y0);R). 

XYZ = zeros(K,N,2); 

%In the following double for-loop, each line connecting the origin (x0,y0) to
%(x(i),y(i)), for some x(i) in the array x and some y(i) in the array y, is
%discretized to an array of points = [(x0,y0);(x0+x(i)/N,y0+y(i)/N);...;
%(x0+x(i),y0+y(i))]. The ith discretized line is stored in the ith vector
%of the K x N x 2 matrix XY. 

for i = 1:K
    for j = 1:N-1
        XYZ(i,j,1) = x(i)*((j)/N);
        if(XYZ(i,j,1) > 1.5)
            XYZ(i,j,1) = 1.5; 
        elseif(XYZ(i,j,1) < -1.5)
            XYZ(i,j,1) = -1.5; 
        end
        
        XYZ(i,j,2) = y(i)*((j)/N); 
        if(XYZ(i,j,2) > 1.5)
            XYZ(i,j,2) = 1.5; 
        elseif(XYZ(i,j,2) < -0.3)
            XYZ(i,j,2) = -0.3; 
        end
        
        %XYZ(i,j,3) = z0; 
    end
    XYZ(i,N,1) = x(i); 
    XYZ(i,N,2) = y(i); 
    %XYZ(i,N,3) = z0; 
end

end

