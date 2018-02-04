function optTrajectory = MPC(X0,N,T)
%pPredict = N x 8 sized matrix comprised of predicted states for the
%projectile--each of which constructed using the function fP, which
%calculates a derivative vector p' for projectile state p. 
pPredict = zeros(N+1,6); 
pX0 = X0(4:9); 
pPredict(1,:) = pX0; 
for j = 1:N
    [t,x] = ode23s(@(t,x) fP(x),[(j-1)*T,j*T],pPredict(j,:).');
     pPredict(j+1,:) = x(end,:); 
end

%xy = (K x N x 2)-sized matrix comprised of linear trajectories (each of which 
%containing N (x,y) points) that discretize the circle C of radius N*T*vMax
%centered about the origin (x0,y0). The constant K determines the degree to
%which C is discretized, and thus determines the number of such linear
%trajectories that are constructed and considered in the optimization
%process. 

K = 100; 
xyz = TrajectoryMaker(X0,N,K,T); 
minCost = 1.0e+20; 
for i = 1:K 
    xyzi = squeeze(xyz(i,:,:));
    pPredicti = pPredict((2:N+1),:); 
    XCost = CostSum(xyzi,pPredicti,N); 
    if(XCost < minCost)
        minIndex = i; 
        minCost = XCost; 
    end
end
optTrajectory = double(squeeze(xyz(minIndex,N,(1:2))));
end