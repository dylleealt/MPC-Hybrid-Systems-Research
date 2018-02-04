function S = CostSum(xyTrajec,pPredict,N)
    S = 0; 
    for j = 1:N
        S = S + Cost(xyTrajec(j,:),pPredict(j,:)); 
    end
end