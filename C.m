function Flow = C(x)
% Timer = Desired interval of time between MPC optimizations. 
T = 0.1; 
%q = Amount of time between current time and previous MPC optimization.
t = x(10);
if (t < T)
   Flow = 1;
else
   Flow = 0; 
end
end
