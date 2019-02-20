function [TP,FP,plr] = PLR_OR( beacons , rec, rec_not ) %Positive Likelihood Ratio
c = max(0.05*(size(rec_not,1)/size(rec,1)),1);
c=0.1;
TP_count = 0;
for i = 1:size(rec,1)
    flag=0;
   % display('First for');
   for k = 1:length(beacons)
    check = 0;
    for j = 1:length(beacons{k})
        if rec(i,beacons{k}(j))==0
            check=1;
        end
    end
    if check==0
        flag=1;
    end
   end
    if flag==1
        TP_count = TP_count + 1;
    end
end
TP = TP_count/size(rec,1);

FP_count = 0;
for i = 1:size(rec_not,1)
    flag=0;
   % display('First for');
   for k = 1:length(beacons)
    check = 0;
    for j = 1:length(beacons{k})
        if rec_not(i,beacons{k}(j))==0
            check=1;
        end
    end
    if check==0
        flag=1;
    end
   end
    if flag==1
        FP_count = FP_count + 1;
    end
end
FP = FP_count/size(rec_not,1);
plr = TP - c * FP;
end