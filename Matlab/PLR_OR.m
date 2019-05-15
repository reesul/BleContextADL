function [TP,FP,plr] = PLR_OR( beacons , rec, rec_not ) %Positive Likelihood Ratio
c = max(0.05*(size(rec_not,1)/size(rec,1)),1);
c=0.1;


TP_or = true(size(rec,1), length(beacons));
FP_or = false(size(rec_not,1), length(beacons));

for i=1:length(beacons)
    b_arr = beacons{i};
    TP_or(:,i) = all(rec(:,b_arr),2);
    FP_or(:,i) = all(rec_not(:,b_arr),2);

end
TP = sum(any(TP_or,2))/size(rec,1);
FP = sum(any(FP_or,2))/size(rec_not,1);
plr = TP - c * FP;

end