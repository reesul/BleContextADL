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
testRecords = allRecords(:,end-size(testRecords,2)+1:end);
end
%% 2) Add several beacons that are explicitly shared between multiple locations (I have location labels to aid us here) or activities. Do this for several beacons on different subsets of activities (possible to have overlap)
if use2
    %define some locations to share a beacon across
    l1 = {'lab', 'classroom_zach-1', 'seminar_room', 'classroom_etb-1'};
    l2 = {'classroom_wc', 'gym'};
    l3 = {'classroom_zach-2', 'classroom_etb-2'};
    l4 = {'office_grad', 'office_jafari', 'lab', 'seminar_room'};
%     l5 = {'seminar_room', 'office_jafari'};
    l6 = {'classroom_etb-1', 'classroom_zach-1', 'gym'};
    l7 = {'classroom_etb-2', 'home'};
    locationPr = [0.5, 0.1, 0.2, 0.1, 0.2, 0.6];
    locations = {l1, l2, l3, l4, l6, l7};
%     location = {'lab','classroom_wc','classroom_zach-1','classroom_zach-2','seminar_room'}; % modify to change the shared beacons
    for k=1:length(locations)
        loc = locations{k};
        for i=1:size(allRecords,2)
            if rand()>locationPr(k) && ismember(string(allRecords{end,i}),loc) % change rand>0.5 to change probability of adding the new beacon
                allRecords{3,i} = [allRecords{3,i}, 1];
             else
                allRecords{3,i} = [allRecords{3,i}, 0];
            end
        end
    end
    
% make sure test and train sets reflect the changes from here
trainRecords = allRecords(:,1:size(trainRecords,2));
testRecords = allRecords(:,end-size(testRecords,2)+1:end);
end
%% 3) Modify test set such that beacons from a totally different context show up where they haven't before (e.g. a friend coming by work, seeing a colleague around town, etc.) i.e. unexpected behavior in test set
if use3
    
%find 3 beacons with most coverage for each activity
activities = unique(allRecords(end-1,:));
locations = unique(allRecords(end,:));
% highCoverageBeacons = cell(length(activities),1);
highCoverageBeacons = cell(length(locations),1);
% for a = 1:length(activities)
for a = 1:length(locations)

%     ind = strcmp(trainRecords(end-1,:), activities{a});
    ind = strcmp(trainRecords(end,:), locations{a});
    if sum(ind)==0
        continue;
    end
    rMtx = recordMatrix(trainRecords(:,ind));
    coverage= sum(rMtx,1);
    [sortedCoverage,sortInd] = sort(coverage, 'descend');
%     highCoverageBeacons{a,:} = sortInd(1:3)
    highC = sortedCoverage > size(rMtx,1)*0.65;
    highCoverageBeacons{a} = sortInd(highC);
    
end
    
for i=1:size(testRecords,2)
%     j = strcmp(activities, testRecords(end-1,i));
    j = strcmp(locations, testRecords(end,i));
    beac = highCoverageBeacons{j};
    rec = testRecords{3,i};
    
    if rand() > 0.25
        for k=1:length(beac)
            if rec(beac(k)) && rand()>0.5
                rec(beac(k)) = 0;
            end
        end
    end
    
    testRecords{3,i} = rec;
    
end
    
    
% 
% for i=1:size(testRecords,2)
%     if rand()<0.2
%         check=0;
%         j = 1;
%         perm = randperm(size(testRecords{3,1},2));
%         while check==0 && j < size(testRecords{3},2)
%             p = perm(j);
%             if testRecords{3,i}(p) == 0 && rand()>0.5
%                 testRecords{3,i}(p) = 1;
%                 check=1;
%             end
%             j = j + 1;
%         end
%     end
% end
    
%make changes to test set, then be sure those are copied into the entire record set (for sake of completion)   
 allRecords(:,end-size(testRecords,2)+1:end) = testRecords;
end
end