%% Turnover measure of how the set of beacons in the user's range changes between windows of time
% turnover 1 is on the entire set beacons, turnover2 is on the filtered set
function [turnover1, turnover2] = beaconTurnover(MACs, pastMACs, oldR, newR)
    
    MACs = unique(MACs);
    pastMACs = unique(pastMACs);
    
    numInCommon = length(intersect(MACs, pastMACs));
    turnover1 = numInCommon / (length(MACs) + length(pastMACs) - numInCommon);
    
    sumAnd=sum(bitand(oldR,newR));
    sumOr = sum(bitor(oldR,newR));
    
    turnover2 = sumAnd/sumOr;
    if isnan(turnover2) 
        turnover2=0;
    end
   
end