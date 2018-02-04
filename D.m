function Jump = D(x)
% Timer = Desired interval of time between MPC optimizations. 
T = 0.1; 
%q = Amount of time between current time and previous MPC optimization.
t = x(10);
if(t >= T)
    Jump = 1; 
else
    Jump = 0; 
end

end
