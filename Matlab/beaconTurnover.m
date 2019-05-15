%% Turnover measure of how the set of beacons in the user's range changes between windows of time. Calculated with intersect over union
function [turnoverUnfiltered, turnoverFiltered] = beaconTurnover(MACs, pastMACs, oldR, newR)
    
    % first get unfiltered turnover
    MACs = unique(MACs);
    pastMACs = unique(pastMACs);
    
    %calcualte intersection 
    numInCommon = length(intersect(MACs, pastMACs));
    % intersect over union
    turnoverUnfiltered = numInCommon / (length(MACs) + length(pastMACs) - numInCommon);
    
    % get filtered turnover. Simpler with the actual records than
    % unfiltered
    sumAnd=sum(bitand(oldR,newR)); %intersect
    sumOr = sum(bitor(oldR,newR)); %union
    
    turnoverFiltered = sumAnd/sumOr;
    if isnan(turnoverFiltered)  %correct error of subsequently empty records
        turnoverFiltered=0;
    end
   
end