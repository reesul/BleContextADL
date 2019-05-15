function [TP,FP,plr] = PLR( beacons , rec, rec_not ) %Positive Likelihood Ratio
% c = max(0.05*(size(rec_not,1)/size(rec,1)),1);
c=0.1; %use static value for now

TP = sum(all(rec(:,beacons),2))/size(rec,1);

FP = sum(all(rec_not(:,beacons),2))/size(rec_not,1);

plr = TP - c* FP; %positive liklihood ratio 
end