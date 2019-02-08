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

tryIdentification = false;
maxNumCompThreads(1); %More than one thread has been found to cause issues during identification

%% Initial variable setup

recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
similarityThreshold = 0.95;
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
save('identification.mat', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap', 'windowSize');

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

save('records.mat',  'recognizedDevices', 'numUniqueDev', 'occurrenceMap', 'cleanOMap', 'cleanDevices', 'cleanNumDev', 'originalRecords', 'windowSize');

%% Parse CSV file containing all labels and their start/end times
csvData = readActivityCsv();
records = originalRecords;
labels = getLabelVec(csvData, records);
records = [records; labels];

nonnullLabelIndex = ~strcmp('null', records(end-1,:));
records = records(:, nonnullLabelIndex);

% activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'eating', 'exercising', 'meeting', 'relaxing', 'research', 'schoolwork', 'walking'};
activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'research', 'schoolwork', 'walking'};

locationLabelNames = {'classroom_etb', 'classroom_wc', 'classroom_zach-1', 'classroom_zach-2', 'gym', 'home', 'lab', 'seminar_room'};

%% Extract data and then features for IMU

rawSensorData = foregroundFeatures(records, datapath, windowSize); %only want the raw data from this, calculate features separately on next line

[imuFeatures, imuTimes] = processIMU(records, rawSensorData, windowSize, {});
[hrFeatures, hrTimes] = processHR(records, rawSensorData, windowSize);

%% Extract statistical features for BLE
bleFeatures = statisticalBleFeat(records);

%% get rid of instances with missing data; normalize features
% [~, nonEmptyRecordInd] = removeEmptyInstances([imuFeatures, heartrateFeatures]);
[~, nonEmptyRecordInd] = removeEmptyInstances(imuFeatures);

finalRecords = records(:, nonEmptyRecordInd);
imuFeatures = imuFeatures(nonEmptyRecordInd, :);
imuTimes = imuTimes(nonEmptyRecordInd, :);
hrFeatures = hrFeatures(nonEmptyRecordInd, :);
bleFeatures = bleFeatures(nonEmptyRecordInd, :);

%normalize the imu features
imuFeatures = normalize(imuFeatures, 'range');
hrFeatures = normalize(hrFeatures, 'range');
bleFeatures = normalize(bleFeatures, 'range');


%% Separate into training and testing datasets
split = 0.75;

%separate based on the number of days in the data
days = unique(finalRecords(1,:));
numTrainingDays = round(length(days)*split);
numTrainingDays = numTrainingDays - 1; %correct for the extra data I added
trainingDays = days(1:numTrainingDays);

endTrainIndex=1;
while ismember(finalRecords(1,endTrainIndex), trainingDays)
    endTrainIndex=endTrainIndex+1;   
end
endTrainIndex=endTrainIndex-1; %correct for additional iteration

trainingRecords = finalRecords(:,1:endTrainIndex);
testingRecords = finalRecords(:,endTrainIndex+1:end);

%apply the same split to the other features
imuFeaturesTrain = imuFeatures(1:endTrainIndex,:);
imuFeaturesTest = imuFeatures(endTrainIndex+1:end,:);
hrFeaturesTrain = hrFeatures(1:endTrainIndex,:);
hrFeaturesTest = hrFeatures(1+endTrainIndex:end,:);
bleFeaturesTrain = bleFeatures(1:endTrainIndex,:);
bleFeaturesTest = bleFeatures(endTrainIndex+1:end,:);

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

%% Calculate Bayesian probabilities and resulting 3-d matrix to represent (for each record) the probability of P(activity | pattern)
[patternPr, allPatterns] = patternBayes(ruleSets, trainingRecords, activityLabelNames);
cTrainingRaw = cell(size(trainingRecords,2),4);
trainingRecordMtx = recordMatrix(trainingRecords);

for i=1:size(trainingRecordMtx,1)
    
%     [cTrainingRaw{i,1}, cTrainingRaw{i,2}] = testRecord(recordMtx(i,:), allPatterns, patternPr);
    [cTrainingRaw{i,1}, cTrainingRaw{i,3}] = testRecord(trainingRecordMtx(i,:), allPatterns, patternPr);

    cTrainingRaw(i,2) = trainingRecords(end-1,i);
    cTrainingRaw{i,4} = [trainingRecords{1,i}, '  ', num2date(trainingRecords{2,i})];
    
end

appliedPatterns = cTrainingRaw(:,3);


%% assign features for context using the patterns/rules found in the set of training records

% contextFeaturesTrain = assignContextFeatures(trainingRecords, activityLabelNames, ruleSets);
% contextFeaturesTest = assignContextFeatures(testingRecords, activityLabelNames, ruleSets);

contextFeaturesTrain = assignContextFeatures_v2(trainingRecords, activityLabelNames, allPatterns, patternPr, appliedPatterns);
contextFeaturesTest = assignContextFeatures_v2(testingRecords, activityLabelNames, allPatterns, patternPr, appliedPatterns);

%normalize the context features, then seaprate again
contextFeatures = normalize([contextFeaturesTrain; contextFeaturesTest], 'range');
contextFeaturesTrain = contextFeatures(1:size(contextFeaturesTrain,1),:);
contextFeaturesTest = contextFeatures(size(contextFeaturesTrain,1)+1:end,:);


%% combine and normalize features, and then Generate files for Weka

% featTrain = removeEmptyInstances([imuFeaturesTrain, contextFeaturesTrain]);
% featTest = removeEmptyInstances([imuFeaturesTest, contextFeaturesTest]);% featTrain = [imuFeaturesTrain, contextFeaturesTrain, bleFeaturesTrain];
% featTest = [imuFeaturesTest, contextFeaturesTest, bleFeaturesTest];

featTrain = [imuFeaturesTrain, hrFeaturesTrain, contextFeaturesTrain, bleFeaturesTrain];
featTest = [imuFeaturesTest, hrFeaturesTest, contextFeaturesTest, bleFeaturesTest];

filename = 'addedHR_2-4';

wekaDataBle(filename, featTrain, trainingRecords(end-1,:), activityLabelNames, true); %what about removed instances for the labels???? TODO
wekaDataBle(filename, featTest, testingRecords(end-1,:), activityLabelNames, false);
