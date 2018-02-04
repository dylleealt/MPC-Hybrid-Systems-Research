function XDot = f(x,optXY)
%The equation for a parametrized line from point p1 to p2 is given by 
%p1 + t*(p2-p1), where t ranges from 0 to 1. Differentiating with respect 
%to t, this equation reduces to p2-p1. In this case, the derivative of 
%the concerned parametrized line equation is therefore optXY - x(1:3). 
optXY = optXY';
slopeVector = optXY - x(1:2); 
p0 = x(4:9); 
pDot = fP(p0); 
XDot = [slopeVector; x(3); pDot; 1]; 
end