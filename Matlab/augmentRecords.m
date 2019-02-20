%% augment the set of BLE records to demonstrate where HAC patterns and probability estimation is superior to other implementations
% the use 'n' arguments are just for which scenario to apply 
function [allRecords, trainRecords, testRecords] = augmentRecords(allRecords, trainRecords, testRecords, use1, use2, use3)

%% 1) Add personal device. Do this for records across many activities (but not necessarily 100% of instances). Should be done for testing and training data
if use1
    augmentPercentage = 0.85;
    %get the subset of beacons to add a 'personal device' to 
    addBeaconInd = randperm(size(allRecords,2), round(size(allRecords,2)*augmentPercentage));
    
    %must add index either way to each record
    for i=1:size(allRecords,2)
        %if we previously chose this index to add personal device to,
        %indicate that beacon was present in the scan(i.e. '1')
        if ismember(i, addBeaconInd)
            allRecords{3,i} = [allRecords{3,i}, 1];
        else
            allRecords{3,i} = [allRecords{3,i}, 0];
            
        end
    end
    
% make sure test and train sets reflect the changes here
trainRecords = allRecords(:,1:size(trainRecords,2));
testRecords = allRecords(:,end-size(testRecords,2):end);
end
%% 2) Add several beacons that are explicitly shared between multiple locations (I have location labels to aid us here) or activities. Do this for several beacons on different subsets of activities (possible to have overlap)
if use2
    
    
    
% make sure test and train sets reflect the changes from here
trainRecords = allRecords(:,1:size(trainRecords,2));
testRecords = allRecords(:,end-size(testRecords,2):end);
end
%% 3) Modify test set such that beacons from a totally different context show up where they haven't before (e.g. a friend coming by work, seeing a colleague around town, etc.) i.e. unexpected behavior in test set
if use3
    
    
    
%make changes to test set, then be sure those are copied into the entire record set (for sake of completion)   
 allRecords(:,end-size(testRecords,2):end) = testRecords;
end
