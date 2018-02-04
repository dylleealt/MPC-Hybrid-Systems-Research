function [t,j,x,XY] = MPCHybridSolver(f,g,C,D,x0,XY0,N,TSPAN,JSPAN,rule,options,solver)
%IMPORTANT NOTE: MPC-related revisions to HyEqSolver.m are not copy-righted.
%The author of these revisions is Calvin John. Last Updated 7/18/2016. 
%HYEQSOLVER solves hybrid equations.
%   Syntax: [t j x] = HYEQSOLVER(f,g,C,D,x0,TSPAN,JSPAN,rule,options,solver)
%   computes solutions to the hybrid equations
%
%   \dot{x} = f(x,t,j)  x \in C x^+ = g(x,t,j)  x \in D
%
%   where x is the state, f is the flow map, g is the jump map, C is the
%   flow set, and D is the jump set. It outputs the state trajectory (t,j)
%   -> x(t,j), where t is the flow time parameter and j is the jump
%   parameter.
%
%   x0 defines the initial condition for the state.
%
%   TSPAN = [TSTART TFINAL] is the time interval. JSPAN = [JSTART JSTOP] is
%       the interval for discrete jumps. The algorithm stop when the first
%       stop condition is reached.
%
%   rule (optinal parameter) - rule for jumps
%       rule = 1 (default) -> priority for jumps rule = 2 -> priority for
%       flows
%
%   options (optinal parameter) - options for the solver see odeset f.ex.
%       options = odeset('RelTol',1e-6);
%       options = odeset('InitialStep',eps);
%
%   solver (optinal parameter. String) - selection of the desired ode
%       solver. All ode solvers are suported, exept for ode15i.  See help
%       odeset for detailed information.
%
%         Example: Bouncing ball with Lite HyEQ Solver
%
%         % Consider the hybrid system model for the bouncing ball with data given in
%         % Example 1.2. For this example, we consider the ball to be bouncing on a
%         % floor at zero height. The constants for the bouncing ball system are
%         % \gamma=9.81 and \lambda=0.8. The following procedure is used to
%         % simulate this example in the Lite HyEQ Solver:
%
%         % * Inside the MATLAB script run_ex1_2.m, initial conditions, simulation
%         % horizons, a rule for jumps, ode solver options, and a step size
%         % coefficient are defined. The function HYEQSOLVER.m is called in order to
%         % run the simulation, and a script for plotting solutions is included.
%         % * Then the MATLAB functions f_ex1_2.m, C_ex1_2.m, g_ex1_2.m, D_ex1_2.m
%         % are edited according to the data given below.
%         % * Finally, the simulation is run by clicking the run button in
%         % run_ex1_2.m or by calling run_ex1_2.m in the MATLAB command window.
%
%         % For further information, type in the command window:
%         helpview(['Example_1_2.html']);
%
%         % Define initial conditions
%         x1_0 = 1;
%         x2_0 = 0;
%         x0   = [x1_0; x2_0];
%
%         % Set simulation horizon
%         TSPAN = [0 10];
%         JSPAN = [0 20];
%
%         % Set rule for jumps and ODE solver options
%         %
%         % rule = 1 -> priority for jumps
%         %
%         % rule = 2 -> priority for flows
%         %
%         % set the maximum step length. At each run of the
%         % integrator the option 'MaxStep' is set to
%         % (time length of last integration)*maxStepCoefficient.
%         %  Default value = 0.1
%
%         rule               = 1;
%
%         options            = odeset('RelTol',1e-6,'MaxStep',.1);
%
%         % Simulate using the HYEQSOLVER script
%         % Given the matlab functions that models the flow map, jump map,
%         % flow set and jump set (f_ex1_2, g_ex1_2, C_ex1_2, and D_ex1_2
%         % respectively)
%
%         [t j x] = HYEQSOLVER( @f_ex1_2,@g_ex1_2,@C_ex1_2,@D_ex1_2,...
%             x0,TSPAN,JSPAN,rule,options,'ode45');
%
%         % plot solution
%
%         figure(1) % position
%         clf
%         subplot(2,1,1),plotflows(t,j,x(:,1))
%         grid on
%         ylabel('x1')
%
%         subplot(2,1,2),plotjumps(t,j,x(:,1))
%         grid on
%         ylabel('x1')
%
%         figure(2) % velocity
%         clf
%         subplot(2,1,1),plotflows(t,j,x(:,2))
%         grid on
%         ylabel('x2')
%
%         subplot(2,1,2),plotjumps(t,j,x(:,2))
%         grid on
%         ylabel('x2')
%
%         % plot hybrid arc
%         
%         figure(3)
%         plotHybridArc(t,j,x)
%         xlabel('j')
%         ylabel('t')
%         zlabel('x1')
%
%         % plot solution using plotHarc and plotHarcColor
%
%         figure(4) % position
%         clf
%         subplot(2,1,1), plotHarc(t,j,x(:,1));
%         grid on
%         ylabel('x_1 position')
%         subplot(2,1,2), plotHarc(t,j,x(:,2));
%         grid on
%         ylabel('x_2 velocity')
%
%
%         % plot a phase plane
%         figure(5) % position
%         clf
%         plotHarcColor(x(:,1),j,x(:,2),t);
%         xlabel('x_1')
%         ylabel('x_2')
%         grid on
%
%--------------------------------------------------------------------------
% Matlab M-file Project: HyEQ Toolbox @  Hybrid Systems Laboratory (HSL),
% https://hybrid.soe.ucsc.edu/software
% http://hybridsimulator.wordpress.com/
% Filename: MPCHYEQSOLVER.m
%--------------------------------------------------------------------------
%   See also HYEQSOLVER, PLOTARC, PLOTARC3, PLOTFLOWS, PLOTHARC,
%   PLOTHARCCOLOR, PLOTHARCCOLOR3D, PLOTHYBRIDARC, PLOTJUMPS.
%   Copyright @ Hybrid Systems Laboratory (HSL),
%   Revision: 0.0.0.3 Date: 04/7/2016 11:50:00


if ~exist('rule','var')
    rule = 1;
end

if ~exist('options','var')
    options = odeset();
end

if ~exist('solver','var')
    solver = 'ode45';
    disp('ode45');
end

odeX = str2func(solver);
nargf = nargin(f);
nargg = nargin(g);
nargC = nargin(C);
nargD = nargin(D);

XY = XY0; 

% simulation horizon
tstart = TSPAN(1);
tfinal = TSPAN(end);
jout = JSPAN(1);
j = jout(end);
tStep = (tfinal - tstart)/(max(tfinal,JSPAN(end))*N); 


% simulate
tout = tstart;
[rx,cx] = size(x0);
if rx == 1
    xout = x0;
elseif cx == 1
    xout = x0.';
else
    error('Error, x0 does not have the proper size')
end

% Jump if jump is prioritized:
if rule == 1
    while (j<JSPAN(end))
        % Check if value it is possible to jump current position
        insideD = D(xout(end,:)); 
        if insideD == 1
            [j, tout, jout, xout,XY] = jump(j,tout,jout,xout,N);
        else
            break;
        end
    end
end
fprintf('Completed: %3.0f%%',0);
while (j < JSPAN(end) && tout(end) < TSPAN(end))
    options = odeset(options,'Events',@(t,x) zeroevents(x,t,j,C,D,...
        rule,nargC,nargD));
    % Check if it is possible to flow from current position
    insideC = C(xout(end,:).'); 
    if insideC == 1
        %for i=1:(N)
            [t,x] = odeX(@(t,x) f(x,XY),[tout(end),tfinal],...
            xout(end,:).',options);
            nt = length(t);
            tout = [tout; t];
            xout = [xout; x];
            jout = [jout; j*ones(1,nt)'];
        %end
    end
    
    %Check if it is possible to jump
    insideD = D(xout(end,:).'); 
    if insideD == 0
        break;
    else
        if rule == 1
            while (j<JSPAN(end))
                % Check if it is possible to jump from current position
                insideD = D(xout(end,:));
                if insideD == 1
                    [j, tout, jout, xout,XY] = jump(j,tout,jout,xout,N);
                else
                    break;
                end
            end
        else
            [j, tout, jout, xout,XY] = jump(g,j,tout,jout,xout,N);
        end
    end
    fprintf('\b\b\b\b%3.0f%%',max(100*j/JSPAN(end),100*tout(end)/TSPAN(end)));
end
t = tout;
x = xout;
j = jout;
fprintf('\nDone\n');
end

function [value,isterminal,direction] = zeroevents(x,t,j,C,D,rule,nargC,nargD)
switch rule
    case 1 % -> priority for jumps
        isterminal(1) = 1; % InsideC
        isterminal(2) = 1; % Inside(C \cap D)
        isterminal(3) = 1; % OutsideC
        direction(1) = -1; % InsideC
        direction(2) = -1; % Inside(C \cap D)
        direction(3) =  1; % OutsideC
    case 2 %(default) -> priority for flows
        isterminal(1) = 1; % InsideC
        isterminal(2) = 0; % Inside(C \cap D)
        isterminal(3) = 1; % OutsideC
        direction(1) = -1; % InsideC
        direction(2) = -1; % Inside(C \cap D)
        direction(3) =  1; % OutsideC
end

insideC = C(x); 
insideD = D(x); 
outsideC = -C(x); 


value(1) = 2*insideC;
value(2) = 2-insideC - insideD;
value(3) = 2*outsideC;

end

function [j, tout, jout, xout, optXY] = jump(j,tout,jout,xout,N)
% Jump
j = j+1;
% Save results
%optXYZ is the M.P.C. optimal target at which the quadcopter's trajectory should 
%be currently set. MPC optimization occurs in the g function. 
optXY = g(xout(end,:),N)'; 
%alpha = -1.0e10;
%beta = 1.0e10;  
%xy = xout(end,(1:2)); 
%pxy = xout(end,(4:5)); 
%xVec = [xy; pxy]; 
%[optXY,value] = AlphaBeta(alpha,beta,1,xVec,N); 
%optX = optXY(1); 
%optY = optXY(2); 
disp(optXY); 
tout = [tout; tout(end)];
jout = [jout; j];
gX = xout(end,:); 
%To test M.P.C. optimization, run a simulation, then run another simulation 
%with the "%" removed from line 281. This constructs a comparison between 
%results with the optimization implemented (first simulation's results) 
%against results with no optimization (second). 
%optXY = gX(1:2)'; 
gX(10) = 0; 
xout = [xout; gX]; 
end

    
    
    
