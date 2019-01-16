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
%  v5: Use rule-based classification to recognize context

%% Options

tryIdentification = true;
maxNumCompThreads(1); %More than one thread has been found to cause issues during identification

%% Initial variable setup

recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
similarityThreshold = 0.9;
numUniqueDev = 0;
windowSize = 60*1000; % in ms

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
[cleanOMap, cleanDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev, true);

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
originalRecords = createRecords(datapath, cleanDevices, windowSize, cleanNumDev); % use 60 second interval for creating records

%% Parse CSV file containing all labels and their start/end times
csvData = readActivityCsv();
records = originalRecords;
labels = getLabelVec(csvData, records);
records = [records; labels];

nonnullLabelIndex = ~strcmp('null', records(end-1,:));
records = records(:, nonnullLabelIndex);

activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'eating', 'exercising', 'meeting', 'relaxing', 'research', 'schoolwork', 'walking'};
locationLabelNames = {'classroom_etb', 'classroom_wc', 'classroom_zach-1', 'classroom_zach-2', 'gym', 'home', 'lab', 'seminar_room'};

%% Extract features for IMU and heartrate

[accFeatures, gyroFeatures, heartrateFeatures] = foregroundFeatures(records, datapath, windowSize);
imuFeatures = [accFeatures; gyroFeatures];


%% Separate into training and testing datasets
split = 0.75;

%separate based on the number of days in the data
days = unique(records(1,:));
numTrainingDays = round(length(days)*split);
trainingDays = days(1:numTrainingDays);

i=1;
while ismember(records(1,i), testingDays)
    i=i+1;   
end
i=i-1; %correct for additional iteration

trainingRecords = records(:,1:i);
testingRecords = records(:,i+1:end);

%apply the same split to the other features
imuFeaturesTrain = imuFeatures(1:i,:);
imuFeaturesTest = imuFeatures(i+1:end,:);
hrFeaturesTrain = heartrateFeatures(1:i,:);
hrFeaturesTest = heartrateFeatures(i+1:end,:);

%% Build classification rules to represent context for each class
ruleSets = cell(length(activityLabelNames),1);
minSupport = 5; %lower limit to number of examples needed for pattern to be valid
iouThreshold = 0.75;
numBags = 20;
randFeatSplit = 0.6; %percentage of valid features/beacons to consider

% nonnullLabelIndex = ~strcmp('null', records(end-1,:));
% labeledActivityRecords = records(:, nonnullLabelIndex);

for l=1:length(activityLabelNames)

    ruleSets{l,:} = createRules_v4(trainingRecords, activityLabelNames(l), minSupport, iouThreshold, numBags, randFeatSplit);
%     ruleSets(l,:) = {createRules_v3(trainingRecords, activityLabelNames(l), minSupport, iouThreshold)};
%     ruleSets(l,:) = {createRules_v2(records, activityLabelNames(l))};
    
end

%% assign features for context

contextFeaturesTrain = assignContextFeatures(trainingRecords, activityLabelNames, ruleSets);
contextFeaturesTest = assignContextFeatures(testingRecords, activityLabelNames, ruleSets);

%% Prepare for generating and Generate files for Weka

featTrain = removeEmptyInstances([imuFeaturesTrain, contextFeaturesTrain]);
featTest = removeEmptyInstances([imuFeaturesTest, contextFeaturesTest]);

normFeatTrain = normalize(featTrain, 'range');
normFeatTest = normalize(featTest, 'range');

wekaDataBle(normFeatTrain, trainingRecords(end-1,:), activityLabelNames, true); %what about removed instances for the labels???? TODO
wekaDataBle(normFeatTest, testingRecords(end-1,:), activityLabelNames, false);
