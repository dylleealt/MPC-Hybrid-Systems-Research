% INITIAL CONDITIONS
%x0 = Position on x-axis.
%y0 = Position on y-axis. 
%z0 = Position on z-axis. 

% File IO from Python -- x is the state vector 
xData = zeros(10000,11); 
optData = zeros(10000,11); 
for i=1:10000
tic; 
if(i>1)
    oldx = x;
end
PtoM = fopen('PtoM.txt', 'r');
x = fscanf(PtoM, '%f');
fclose(PtoM); 
if size(x) == 0
    x = oldx;
end


%z0 = -0.5; 
%X0 = Initial state vector.
X0 = [x(1);x(2);x(3)];
%N = Event horizon. 
N = 4; 
%Simulation horizon
TSPAN = [0 10];
JSPAN = [0 1];
rule = 1;
options = odeset('RelTol',1e-6,'MaxStep',.3);

%PROJECTILE DATA
%[pX0,pY0,pZ0] = Initial x,y,z coordinates of projectile. 
pX0 = x(4);
pY0 = x(5); 
pZ0 = x(6); 
%pTheta0 = Initial angle of projectile. 
pTheta0 = pi/3; 
%[pXDot0,pYDot0] = Initial x,y,z velocities of projectile. 
pXDot0 = x(7); 
pYDot0 = x(8);
pZDot0 = x(9);

%p0 = Initial state vector for projectile. 
p0 = [pX0;pY0;pZ0;pXDot0;pYDot0;pZDot0]; 
%t = Timer.
t = 0; 
%X0 is now redefined to its final form, which includes p0 and T. 
X0 = [X0;p0;t]'; 
X0(4:5) = [.02;-0.3]; 
%g(X0,N); 
%XY0 = Initial target xy location for the quadcopter. Here, it is
%arbitrary, and only defined to initialize the MPCHybridSolver algorithm.
XY0 = X0(1:2); 
if(i > 1)
    xData(i,:) = [x(1:9); toc + xData(i-1,10); i-1]; 
else
    xData(i,:) = [x(1:9); toc; 0]; 
end

[t,j,xout,XY] = MPCHybridSolver(@f,@g,@C,@D,X0,XY0,N,TSPAN,JSPAN,rule,options);
%optData(i,:) = XY; 
end