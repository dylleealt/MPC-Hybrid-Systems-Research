function [pXDot] = fP(x)
    m=0.1;
    %r=0.1;
    %A=pi*r^2;                    %m^2
    A = 0.06; 
    rho= 1.225;                  %kg/m^3(density of air)
    C=.01;                        %Drag Coefficient of a sphere
    R =rho*C*A/2;               %Drag Force
    g=9.81;                      %gravitational acceleration
   
    x_1=x(1);
    y_1=x(2);
    z_1=x(3);
    vx=x(4);
    vy=x(5);
    vz=x(6);
    
    R_x = R*vx^2; 
    R_y = R*vy^2; 
    R_z = R*vz^2; 
    
    pXDot(1:3) = x(4:6);
    pXDot(4) = -R_x/m; 
    pXDot(5) = -R_y/m; 
    pXDot(6) = - g - R_z/m; 
    pXDot = pXDot'; 
end

