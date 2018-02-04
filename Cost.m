function C = Cost(xyTrajec,pPredict)
    C = 1/(norm(xyTrajec(1:2)-pPredict(1:2)));
end