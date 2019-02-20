function [allRecords, trainRecords, testRecords] = augmentRecords(allRecords, trainRecords, testRecords, use1, use2, use3)

%% 1) Add personal device. Do this for records across many activities (but not necessarily 100% of instances). Should be done for testing and training data
if use1
    augmentPercentage = 0.85
    addBeaconInd = randperm(size(allRecords,2), size(allRecords,2)*augmentPercentage);
    
    for i=1:length(addBeaconInd)
    
    
    end
    
    
end
%% 2) Add several beacons that are explicitly shared between multiple locations (I have location labels to aid us here) or activities. Do this for several beacons on different subsets of activities (possible to have overlap)


%% 3) Modify test set such that beacons from a totally different context show up where they haven't before (e.g. a friend coming by work, seeing a colleague around town, etc.) i.e. unexpected behavior in test set

