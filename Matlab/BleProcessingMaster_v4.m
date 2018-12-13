%% 
% Script for trying to process All BLE devices
%
%  v1: Pull data from file, use similarity metric to try resolving changed
%  MAC addresses, build dictionary based on MACs that can resolve to device
%  ID
%
%  v2: Batch several days' worth of data together 
%       Generate 'occurrence' intervals in which the beacon was seen
%       contiguously 
%
%  v3: Build adjacency/similarity matrix out of BLE, cluster data
%
%  v4: Build binary classifiers using clustering and decision tree for each
%       class

%% Options

tryIdentification = true;


%% Initial variable setup
recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
similarityThreshold = 0.9;
numUniqueDev = 0;

%% extract data from file and perform identfication to resolve random MACs

datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\20_day_set\'
dataDirs = ls(datapath)
blefile = 'ble_data.txt';


for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
        %reformat data into usable form; assumes a specific format
        [bleData,~] = formatBleData(blePath);
        
        if tryIdentification %attempt to resolve changing MAC addresses
            [recognizedDevices, numUniqueDev] = identifyBeacons(bleData, recognizedDevices, numUniqueDev, similarityThreshold);
        else
            [recognizedDevices, numUniqueDev] = identifyMacOnly(bleData, recognizedDevices, numUniqueDev, similarityThreshold);
        end
            
        occurrenceMap = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d);
        
        %save state due to the time complexity of this process
        save('identificationProgress.mat', 'd', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap');
    end
    
end


% macSet = cell(size(occurrenceMap));
% k=occurrenceMap.keys();
% for i=1:length(k)
%     kk = k{i};
%     macSet{i} = findMACs(kk, recognizedDevices);
% end
% 
% %sort this for diagnostic purposes
% [~,I] = sort(cellfun(@length,macSet))
% macSet=macSet(I);
% clear I

%% save state - this section takes a very long time to process
save('identification.mat', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap');

delete identificationProgress.mat
%% Clean data
[cleanOMap, cleanDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev);

% log data for viewing
if isfile('occurrences.log')
    delete 'occurrences.log'
end
diary('occurrences.log');
for i=1:cleanNumDev
    if cleanOMap.isKey(i)
        disp('looking at device:')
        disp(i)
        disp(cleanOMap(i))
    end
end
diary off

%% Generate records based on set of good beacons
records = createRecords(datapath, cleanDevices, 60*1000, cleanNumDev); % use 60 second interval for creating records

%% Parse CSV file containing all labels and their start/end times
csvData = readActivityCsv();
labels = getLabelVec(csvData, records);
labeledRecords = [records; labels];

nonnullLabelIndex = ~strcmp('null', labeledRecords(end-1,:));
labeledRecords = labeledRecords(:, nonnullLabelIndex);

activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'eating', 'exercising', 'meeting', 'relaxing', 'research', 'schoolwork', 'walking'};
locationLabelNames = {'classroom_etb', 'classroom_wc', 'classroom_zach-1', 'classroom_zach-2', 'gym', 'home', 'lab', 'seminar_room'};

%% Cluster and Classify binary activity classes
results = cell(length(activityLabelNames), 7);

nonnullLabelIndex = ~strcmp('null', labeledRecords(end-1,:));
labeledActivityRecords = labeledRecords(:, nonnullLabelIndex);

for i=1:length(activityLabelNames)
    
    [tree, clusters, weights, f1, f1Last, testSet] = clusterAndClassify(labeledActivityRecords, activityLabelNames{i}, csvData);
    results(i,:) = {activityLabelNames{i}, tree, clusters, weights, f1, f1Last, testSet};
    
end

%% Cluster and Classify binary location classes
results = cell(length(locationLabelNames), 7);

nonnullLabelIndex = ~strcmp('null', labeledRecords(end,:));
labeledLocationRecords = labeledRecords(:, nonnullLabelIndex);

for i=1:length(locationLabelNames)
    
    [tree, clusters, weights, f1, f1Last, testSet] = clusterAndClassifyLocation(labeledLocationRecords, locationLabelNames{i}, csvData);
    results(i,:) = {locationLabelNames{i}, tree, clusters, weights, f1, f1Last, testSet};
    
end