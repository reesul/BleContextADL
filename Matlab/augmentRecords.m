%% augment the set of BLE records to demonstrate where HAC patterns and probability estimation is superior to other implementations
% the use 'n' arguments are just for which scenario to apply 
function [trainRecords, testRecords] = augmentRecords(trainRecords, testRecords, use1, use2, use3)

%% 1) Add personal device. Do this for records across many activities (but not necessarily 100% of instances). Should be done for testing and training data
if use1
    augmentPercentage = 0.85;
    %get the subset of beacons to add a 'personal device' to 
    addBeaconInd = randperm(size(trainRecords,2), round(size(trainRecords,2)*augmentPercentage));
    
    %must add index either way to each record
    for i=1:size(trainRecords,2)
        %if we previously chose this index to add personal device to,
        %indicate that beacon was present in the scan(i.e. '1'). Must add
        %to the record vector regardless to maintain constant size
        if ismember(i, addBeaconInd)
            trainRecords{3,i} = [trainRecords{3,i}, 1];
        else
            trainRecords{3,i} = [trainRecords{3,i}, 0];
            
        end
    end
    
    %randomly find the instances to add a beacon to
    addBeaconInd = randperm(size(testRecords,2), round(size(testRecords,2)*augmentPercentage));
    
    for i=1:size(testRecords,2)
        %if we previously chose this index to add personal device to,
        %indicate that beacon was present in the scan(i.e. '1')
        if ismember(i, addBeaconInd)
            testRecords{3,i} = [testRecords{3,i}, 1];
        else
            testRecords{3,i} = [testRecords{3,i}, 0];
            
        end
    end
    
end
%% 2) Add several beacons that are explicitly shared between multiple locations (I have location labels to aid us here) or activities. Do this for several beacons on different subsets of activities (possible to have overlap)
if use2

    l1 = {'lab', 'classroom_zach-1', 'seminar_room', 'classroom_etb-1'};
    l2 = {'classroom_wc', 'gym'};
    l3 = {'classroom_zach-2', 'classroom_etb-2'};
    l4 = {'office_grad', 'office_jafari', 'lab', 'seminar_room'};
    l5 = {'classroom_etb-1', 'classroom_zach-1', 'gym'};
    l6 = {'classroom_etb-2', 'home'};
    locationPr = [0.5, 0.1, 0.2, 0.1, 0.2, 0.6];
    locations = {l1, l2, l3, l4, l5, l6};
    
    %do for training set first
    for k=1:length(locations)
        loc = locations{k};
        for i=1:size(trainRecords,2)
            % for a record, add a beacon if probability exceeds the one set
            % for this location, and the actual context label is within the
            % location set. Must add to record vector either way to
            % mainintain constant size
            if rand()>locationPr(k) && ismember(string(trainRecords{end,i}),loc)
                trainRecords{3,i} = [trainRecords{3,i}, 1];
             else
                trainRecords{3,i} = [trainRecords{3,i}, 0];
            end
        end
    end
    
    %do for testing set in the same way
    for k=1:length(locations)
        loc = locations{k};
        for i=1:size(testRecords,2)
            if rand()>locationPr(k) && ismember(string(testRecords{end,i}),loc) % change rand>0.5 to change probability of adding the new beacon
                testRecords{3,i} = [testRecords{3,i}, 1];
             else
                testRecords{3,i} = [testRecords{3,i}, 0];
            end
        end
    end
    
end
%% 3) Modify test set such that highly consistent in the beacons (for the training set) in a particular context are removed (from the testing set)
if use3

locations = unique(trainRecords(end,:));
highCoverageBeacons = cell(length(locations),1);
% for a = 1:length(activities)
for a = 1:length(locations)

%     ind = strcmp(trainRecords(end-1,:), activities{a});
    ind = strcmp(trainRecords(end,:), locations{a});
    if sum(ind)==0
        continue;
    end
    rMtx = recordMatrix(trainRecords(:,ind)); %get record matrix for these locations (contexts)
    coverage= sum(rMtx,1);
    [sortedCoverage,sortInd] = sort(coverage, 'descend');
%     highCoverageBeacons{a,:} = sortInd(1:3)
    highC = sortedCoverage > size(rMtx,1)*0.65; %find beacons present for at least 65% of instances for that set
    highCoverageBeacons{a} = sortInd(highC);
    
end
    
for i=1:size(testRecords,2)
%     j = strcmp(activities, testRecords(end-1,i));
    j = strcmp(locations, testRecords(end,i));
    if ~any(j)
        continue; 
    end
    
    beac = highCoverageBeacons{j};
    rec = testRecords{3,i};
    
    if rand() > 0.25
        %with 25% chance, augment this record
        for k=1:length(beac)
            % with 50% chance, remove this beacon
            if rec(beac(k)) && rand()>0.5
                rec(beac(k)) = 0;
            end
        end
    end
    
    testRecords{3,i} = rec;
    
end
end
end