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
    l5 = {'seminar_room', 'office_jafari'};
    l6 = {'classroom_etb-1', 'classroom_zach-1', 'gym'};
    l7 = {'classroom_etb-1', 'home'};
    locations = {l1, l2, l3, l4, l5, l6, l7};
%     location = {'lab','classroom_wc','classroom_zach-1','classroom_zach-2','seminar_room'}; % modify to change the shared beacons
    for k=1:length(locations)
        loc = locations{k};
        for i=1:size(allRecords,2)
            if rand()>0.5 && ismember(string(allRecords{end,i}),loc) % change rand>0.5 to change probability of adding the new beacon
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
    
    
% % add some beacons to share across a few locations
% l1 = {'lab','office_grad', 'seminar_room', 'office_jafari'};
% l2 = {'lab', 'classroom_zach-1', 'seminar_room', 'classroom_etb-1'};
% l3 = {'classroom_etb-2', 'classroom_zach-2'};
% locations = {l1, l2, l3};
% %     location = {'lab','classroom_wc','classroom_zach-1','classroom_zach-2','seminar_room'}; % modify to change the shared beacons
% for k=1:length(locations)
%     loc = locations{k};
%     for i=1:size(trainRecords,2)
%         if rand()>0.5 && ismember(string(trainRecords{end,i}),loc) % change rand>0.5 to change probability of adding the new beacon
%             trainRecords{3,i} = [trainRecords{3,i}, 1];
%          else
%             trainRecords{3,i} = [trainRecords{3,i}, 0];
%         end
%     end
% end
% 
% % make sure size of test records reflects changes above
% for i=1:size(testRecords,2)
%     testRecords{3,i} = [testRecords{3,i}, zeros(1, length(locations))];
% end
%         
% % add those same beacons randomly to a few different locations     
% lt1 = 'gym';
% lt2 = 'home';
% lt3 = 'lab';
% testLocations = {lt1, lt2, lt3};
% for k=1:length(testLocations)
%     loc = testLocations{k};
%     %add these records in blocks to simulate actually seeing a person ,
%     %rather than having those beacons randomly interspersed 
%     block = false; blockSizeMax = 5; blockSize = 0; numBlocks =0; maxBlocks = 4; 
%     for i=2:size(testRecords,2)
%         if block && strcmp(testRecords(end,i), testRecords(end,i-1))
%             testRecords{3,i}(end-k+1) = 1;
%             blockSize = blockSize+1;
%             if blockSize >= blockSizeMax
%                 block=false;
%             end
%         elseif rand()>0.85 && strcmp(loc, testRecords{end,i})
%             numBlocks = numBlocks+1;
%             if numBlocks>maxBlocks
%                 break;
%             end
%             testRecords{3,i}(end-length(testLocations)+k) = 1;
%             blockSize = 1;
%             block = true;
%             
%         end
%     end
% end
for i=1:size(testRecords,2)
    if rand()<0.2
        check=0;
        j = 1;
        perm = randperm(size(testRecords{3,1},2));
        while check==0 && j < size(testRecords{3},2)
            p = perm(j);
            if testRecords{3,i}(p) == 0 && rand()>0.5
                testRecords{3,i}(p) = 1;
                check=1;
            end
            j = j + 1;
        end
    end
end
    
%make changes to test set, then be sure those are copied into the entire record set (for sake of completion)   
 allRecords(:,end-size(testRecords,2)+1:end) = testRecords;
end
end