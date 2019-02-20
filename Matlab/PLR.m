function [TP,FP,plr] = PLR( beacons , rec, rec_not ) %Positive Likelihood Ratio
c = max(0.05*(size(rec_not,1)/size(rec,1)),1);
c=0.1;
n_beacons = length(beacons);
TP_count = 0;
for i = 1:size(rec,1)
   % display('First for');
    check = 0;
    for j = 1:n_beacons
        if rec(i,beacons(j))==0
            check=1;
        end
    end
    if check==0
        TP_count = TP_count + 1;
    end
end
TP = TP_count/size(rec,1);

FP_count = 0;
for i = 1:size(rec_not,1)
    %display('Second for');
    check = 0;
    for j = 1:n_beacons
        if rec_not(i,beacons(j))==0
            check=1;
        end
    end
    if check==0
        FP_count = FP_count + 1;
    end
end
FP = FP_count/size(rec_not,1);
plr = TP - c* FP;
end