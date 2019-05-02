%% augment the set of BLE records to demonstrate where HAC patterns and probability estimation is superior to other implementations
% the use 'n' arguments are just for which scenario to apply 
function [trainRecords, testRecords] = augmentRecords_v3(trainRecords, testRecords, use1, use2, use3, subject)

%% 1) Add personal device. Do this for records across many activities (but not necessarily 100% of instances). Should be done for testing and training data
if use1
    augmentPercentage = 0.85;
    %get the subset of beacons to add a 'personal device' to 
    addBeaconInd = randperm(size(trainRecords,2), round(size(trainRecords,2)*augmentPercentage));
    
    %must add index either way to each record
    for i=1:size(trainRecords,2)
        %if we previously chose this index to add personal device to,
        %indicate that beacon was present in the scan(i.e. '1')
        if ismember(i, addBeaconInd)
            trainRecords{3,i} = [trainRecords{3,i}, 1];
        else
            trainRecords{3,i} = [trainRecords{3,i}, 0];
            
        end
    end
    
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
    
    %define some locations to share a beacon across
    if subject==1
    l1 = {'lab', 'classroom_zach-1', 'seminar_room', 'classroom_etb-1'};
    l2 = {'classroom_wc', 'gym'};
    l3 = {'classroom_zach-2', 'classroom_etb-2'};
    l4 = {'office_grad', 'office_jafari', 'lab', 'seminar_room'};
%     l5 = {'seminar_room', 'office_jafari'};
    l6 = {'classroom_etb-1', 'classroom_zach-1', 'gym'};
    l7 = {'classroom_etb-2', 'home'};
    locationPr = [0.5, 0.1, 0.2, 0.1, 0.2, 0.6];
    locations = {l1, l2, l3, l4, l6, l7};
    
    elseif subject==2 %TODO: change these to fit 2nd subject's data
        l1 = {'lab', 'classroom_zach-1', 'seminar_room', 'classroom_etb-1'};
        l2 = {'classroom_wc', 'gym'};
        l3 = {'classroom_zach-2', 'classroom_etb-2'};
        l4 = {'office_grad', 'office_jafari', 'lab', 'seminar_room'};
    %     l5 = {'seminar_room', 'office_jafari'};
        l6 = {'classroom_etb-1', 'classroom_zach-1', 'gym'};
        l7 = {'classroom_etb-2', 'home'};
        locationPr = [0.5, 0.1, 0.2, 0.1, 0.2, 0.6];
        locations = {l1, l2, l3, l4, l6, l7};
        
    elseif subject==3 %TODO: change to fit 3rd subjects data
        l1 = {'ETB1', 'office_grad', 'seminar_room'};
        l2 = {'ETB2, ETB2_meeting'};
        l3 = {'ETB3, home'};
        l4 = {'home, store'};
        l5 = {'office_grad', 'STAT1'};
        l6 = {'ZACH1', 'ETB3'};
        locationPr = [0.4, 0.7, 0.4, 0.2, 0.3, 0.6];
        locations = {l1, l2, l3, l4, l5, l6};        
    end
    
    
    
%     location = {'lab','classroom_wc','classroom_zach-1','classroom_zach-2','seminar_room'}; % modify to change the shared beacons
    %do for training set first
    for k=1:length(locations)
        loc = locations{k};
        for i=1:size(trainRecords,2)
            if rand()>locationPr(k) && ismember(string(trainRecords{end,i}),loc) % change rand>0.5 to change probability of adding the new beacon
                trainRecords{3,i} = [trainRecords{3,i}, 1];
             else
                trainRecords{3,i} = [trainRecords{3,i}, 0];
            end
        end
    end
    
    %do for testing set
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
%% 3) Modify test set such that beacons from a totally different context show up where they haven't before (e.g. a friend coming by work, seeing a colleague around town, etc.) i.e. unexpected behavior in test set
if use3
    
%find 3 beacons with most coverage for each activity
activities = unique(trainRecords(end-1,:));
locations = unique(trainRecords(end,:));
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
end
end