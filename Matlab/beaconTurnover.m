%% Turnover measure of how the set of beacons in the user's range changes between windows of time
function [turnover] = beaconTurnover(MACs, pastMACs)
    
    MACs = unique(MACs);
    pastMACs = unique(pastMACs);
    
    numInCommon = length(intersect(MACs, pastMACs));
    turnover = numInCommon / (length(MACs) + length(pastMACs) - numInCommon);
    
%     sumXor=sum(bitxor(oldR,newR));
%     sumOr = sum(bitor(oldR,newR));
%     
%     turnover = sumXor/sumOr;
%     if isnan(turnover) 
%         turnover=1;
%     end
   
end