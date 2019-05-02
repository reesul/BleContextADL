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
%       testing version: perform augmentations on dataset to test different
%           scenarios that may occur in realistic datasets (but not the one
%           first developed for this study).
%  v6: Subject specific data processing; subject id set in the first couple
%       lines

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
subject=3
if subject==1
datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\20_day_set\'
elseif subject==2
datapath= 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Nan\'
elseif subject == 3
datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Ali\'
end

dataDirs = ls(datapath)
blefile = 'ble_data.txt';


% for d=1:size(dataDirs,1)
for d=1:length(dataDirs) %build only on training set
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
[originalRecords, allRecords] = createRecords(datapath, cleanDevices, windowSize, cleanNumDev); % use 60 second interval for creating records

save('records.mat',  'recognizedDevices', 'numUniqueDev', 'occurrenceMap', 'cleanOMap', 'cleanDevices', 'cleanNumDev', 'originalRecords', 'windowSize');

%% Parse CSV file containing all labels and their start/end times
csvPath=''
if subject==1
    csvPath = 'activityLabels_tuned.csv';
elseif subject ==2
    csvPath='activityLabels_Nandita.csv';
elseif subject==3
csvPath = 'activityLabels_Ali_tuned.csv';
end
csvData = readActivityCsv(csvPath);
records = originalRecords;
allLabels = getLabelVec(csvData, records);
records = [records; allLabels];

nonnullLabelIndex = ~strcmp('null', records(end-1,:));
records = records(:, nonnullLabelIndex);

% activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'eating', 'exercising', 'meeting', 'relaxing', 'research', 'schoolwork', 'walking'};
if subject==1
    activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'research', 'schoolwork', 'walking'};
    locationLabelNames = {'classroom_etb', 'classroom_wc', 'classroom_zach-1', 'classroom_zach-2', 'gym', 'home', 'lab', 'seminar_room'};
elseif subject ==2
%     activityLabelNames = {'class', 'cleaning', 'cooking', 'eating', 'exercising', 'getting_ready', 'meeting', 'phone call', 'relaxing', 'research', 'schoolwork', 'social event', 'walking'};
    activityLabelNames = {'class', 'eating', 'exercising', 'getting_ready', 'meeting', 'phone call', 'relaxing', 'research', 'schoolwork', 'social event', 'walking'};
locationLabelNames = {'ETB1', 'ETB2', 'home', 'lab', 'office_grad', 'seminar_room', 'social event', 'store', 'ZACH1', 'ZACH2'};
elseif subject==3
%     activityLabelNames = {'class', 'cleaning', 'cooking', 'driving', 'eating', 'meeting', 'relaxing', 'research', 'schoolwork', 'shopping', 'walking'};
    activityLabelNames = {'class', 'cleaning', 'driving', 'eating', 'meeting', 'relaxing', 'research', 'shopping', 'walking'};
    locationLabelNames = {'ETB1', 'ETB2', 'ETB2_meeting', 'ETB3', 'ETB4', 'home', 'office_grad', 'seminar_room', 'STAT', 'store', 'ZACH1'};
end


%% Extract features for IMU and heartrate

%function below is improperly named; simply pulls raw data from the files
rawSensorData = foregroundFeatures(records, datapath, windowSize); %only want the raw data from this, calculate features separately on next line

[imuFeatures, imuTimes] = processIMU(records, rawSensorData, windowSize, {});
[hrFeatures, hrTimes] = processHR(records, rawSensorData, windowSize);
%% Extract statistical features for BLE
bleFeatures = statisticalBleFeat(records);

%% get rid of instances with missing data; normalize features
% [~, nonEmptyRecordInd] = removeEmptyInstances([imuFeatures, heartrateFeatures]);
nonEmptyRecordInd = removeEmptyInstances(imuFeatures);
% nonEmptyRecordInd = logical(nonEmptyRecordInd);

finalRecords = records(:, nonEmptyRecordInd);
ogFinalRecords = finalRecords;
imuFeatures = imuFeatures(nonEmptyRecordInd, :);
imuTimes = imuTimes(nonEmptyRecordInd, :);
% hrFeatures = hrFeatures(nonEmptyRecordInd, :);
bleFeatures = bleFeatures(nonEmptyRecordInd, :);

%normalize the imu features
imuFeatures = normalize(imuFeatures, 'range');
% hrFeatures = normalize(hrFeatures, 'range');
bleFeatures = normalize(bleFeatures, 'range');

%% Separate into training and testing datasets
finalRecords = ogFinalRecords;
if subject==1
    split = 0.75;
    days = unique(finalRecords(1,:));
    numTrainingDays = round(length(days)*split);
    numTrainingDays = numTrainingDays - 1; %correct for the extra data I added
    
    %separate based on the number of days in the data
    days = unique(finalRecords(1,:));
    numTrainingDays = round(length(days)*split);
    trainingDays = days(1:numTrainingDays);

    endTrainIndex=1;
    while ismember(finalRecords(1,endTrainIndex), trainingDays)
        endTrainIndex=endTrainIndex+1;   
    end
    endTrainIndex=endTrainIndex-1; %correct for additional iteration
    
    trainingInds = [1:endTrainInd];
    testingInds = [endTrainInd+1:size(records,2)];
    
else
   [trainingInds, testingInds] = distributeLabels(finalRecords, activityLabelNames); 
end


trainingRecords = finalRecords(:,trainingInds);
testingRecords = finalRecords(:,testingInds);
finalRecords = finalRecords(:, (trainingInds | testingInds));

%apply the same split to the other features
imuFeaturesTrain = imuFeatures(trainingInds,:);
imuFeaturesTest = imuFeatures(testingInds,:);
% hrFeaturesTrain = hrFeatures(trainingInds,:);
% hrFeaturesTest = hrFeatures(testingInds,:);
bleFeaturesTrain = bleFeatures(trainingInds,:);
bleFeaturesTest = bleFeatures(testingInds,:);


%% Augment set of records to test different behaviors of chosen methods

use1 = true;
use2 = true;
use3 = true;
% [augRecords, augTrainRecords, augTestRecords] = augmentRecords_v2(finalRecords, trainingRecords, testingRecords, use1, use2, use3, subject);
[augTrainRecords, augTestRecords] = augmentRecords_v3(trainingRecords, testingRecords, use1, use2, use3, subject);

useAugmented = true;
if useAugmented
%     finalRecords = augRecords;
    trainingRecords = augTrainRecords;
    testingRecords = augTestRecords;
end

%% HAC methods of pattern extraction
IOUthreshold = 0.65;
Patterns_Single = clusterRecordsFunc_v3(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, 0.75, true);
% Patterns_HAC = clusterRecordsFunc(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, false);
Patterns_HAC = clusterRecordsFunc_v2(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, false);
Patterns_AHAC = clusterRecordsFunc_v3(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, IOUthreshold, false);
%% Calculate Bayesian probabilities and resulting 3-d matrix to represent (2-D for each record) the probability of P(activity | pattern)
patternMethod = 0; %0 is single-beacon pattern, 2 is AHAC (our method), and 2 is HAC

if patternMethod == 0
    ruleSets = Patterns_Single;
elseif patternMethod == 1
    ruleSets = Patterns_AHAC;
elseif patternMethod == 2
    ruleSets = Patterns_HAC;
end
[patternPr, allPatterns, ~, gini] = patternBayes(ruleSets, trainingRecords, activityLabelNames);        
% [patternPr, allPatterns] = patternBayes(ruleSets, trainingRecords, activityLabelNames);
% [patternPr, allPatterns] = patternBayes(Patterns_HAC, trainingRecords, activityLabelNames);
cTrainingRaw = cell(size(trainingRecords,2),4);
trainingRecordMtx = recordMatrix(trainingRecords);

for i=1:size(trainingRecordMtx,1)
    
%     [cTrainingRaw{i,1}, cTrainingRaw{i,2}] = testRecord(recordMtx(i,:), allPatterns, patternPr);
    [cTrainingRaw{i,1}, cTrainingRaw{i,3}] = testRecord(trainingRecordMtx(i,:), allPatterns, patternPr);

    cTrainingRaw(i,2) = trainingRecords(end-1,i);
    cTrainingRaw{i,4} = [trainingRecords{1,i}, '  ', num2date(trainingRecords{2,i})];
    
end

appliedPatterns = cTrainingRaw(:,3);

%% separate data into subsets based on which activities share context

 %minimum number of instances for a subset to be valid, otherwise consider
 %it an outlier, and that it has no context
sizeThreshold = 50;
naive = true; %if true, no ACP
useLocation = false; 
exactTrainingSet = false;
epsilon = 0.25; %parameter to reduce sensitivity to beacons that are very prevalent; achieve finer context separation

if naive
    [trainingSubsets, sharedContextLabels] = naivePartitionData(activityLabelNames, trainingRecords, sizeThreshold, ruleSets);
    [testingSubsets] = naivePartitionTestData(testingRecords, ruleSets, sharedContextLabels, activityLabelNames);
elseif useLocation
    [trainingSubsets, sharedContextLabels] = locationalPartition(trainingRecords);
    [testingSubsets] = locationalTestPartition(testingRecords, sharedContextLabels);
else
    [trainingSubsets, sharedContextLabels] = partitionData(activityLabelNames, cTrainingRaw, sizeThreshold, epsilon);
    [testingSubsets] = partitionTestData(testingRecords, allPatterns, patternPr, sharedContextLabels, activityLabelNames, epsilon);
end

classifierIndSets = cell(size(sharedContextLabels, 1), 2);
classifierFeatureSets = cell(size(sharedContextLabels, 1), 2);
classifierLabels = cell(size(sharedContextLabels, 1), 2);

for i=1:size(classifierIndSets,1)
    
    labels = sharedContextLabels{i};
    if isempty(labels)
        labels = 'null';
    end
    
    % training set first
    if exactTrainingSet
        trInd = trainingSubsets{i,2};
        classifierIndSets{i,1} = trainingSubsets{i,2};
        classifierFeatureSets{i,1} = [imuFeaturesTrain(trInd,:), bleFeaturesTrain(trInd,:)];
    %     classifierFeatureSets{i,1} = [imuFeaturesTrain(trInd,:), hrFeatures(trInd,:), bleFeaturesTrain(trInd,:), contextFeaturesTrain(trInd,:)];
        classifierLabels{i,1} = trainingRecords(end-1, trInd)';
    else    
        ind = false(size(trainingRecords,2),1);
        %first do training data
        for j=1:size(trainingRecords,2)
            if useLocation
                recordLabel = trainingRecords(end-1,j);
                if ismember(recordLabel,trainingSubsets{i,3})
                    ind(j)=true;
                end
            else
                recordLabel = trainingRecords(end-1,j);
                if ismember(recordLabel, labels)
                    ind(j) = true;
                end
            end

        end

        if isempty(labels) || any(strcmp(labels, 'null')) 
            ind = true(size(trainingRecords,2),1);
        end

        classifierIndSets{i,1} = ind;

        classifierFeatureSets{i,1} = [imuFeaturesTrain(ind,:), bleFeaturesTrain(ind,:)];
        classifierLabels{i,1} = trainingRecords(end-1,ind)';
    end
    
        % testing set 
    tstInd = testingSubsets{i};
    classifierIndSets{i,2} = tstInd;
    

    classifierFeatureSets{i,2} = [imuFeaturesTest(tstInd,:), bleFeaturesTest(tstInd,:)];
    
    classifierLabels{i,2} = testingRecords(end-1, tstInd)';

end
    
 

%% Generate files for Weka

% featTrain = removeEmptyInstances([imuFeaturesTrain, contextFeaturesTrain]);
% featTest = removeEmptyInstances([imuFeaturesTest, contextFeaturesTest]);
% featTrain = [imuFeaturesTrain, contextFeaturesTrain];
% featTest = [imuFeaturesTest, contextFeaturesTest];
contextSeparate = false;
pre = '';
if subject==1
    pre='Reese\';
elseif subject==2
    pre='Nandita\';
elseif subject ==3
    pre='Ali\';
end

if contextSeparate
    for i=1:size(classifierFeatureSets,1)
        filename = [pre, 'Single+Basic_aug\'];
        labels = sharedContextLabels{i};

        if isempty(labels)
            s = 'null-context';
        else
            s=labels{1};
            for j=2:length(labels)
                s = [s, '-', labels{j}];
            end
        end
        filename = [filename, s];

        wekaDataBle(filename, classifierFeatureSets{i,1}, classifierLabels{i,1}, activityLabelNames, true); %what about removed instances for the labels???? TODO
        wekaDataBle(filename, classifierFeatureSets{i,2}, classifierLabels{i,2}, activityLabelNames, false);
    end

else
    featTrain = [imuFeaturesTrain, recordMatrix(trainingRecords), bleFeaturesTrain];%beacons as features
    featTest = [imuFeaturesTest,  recordMatrix(testingRecords), bleFeaturesTest];
%     featTrain = [bleFeaturesTrain, recordMatrix(trainingRecords)];%only ble and imu as features
%     featTest = [bleFeaturesTest, recordMatrix(testingRecords)];
%     featTrain = [imuFeaturesTrain, bleFeaturesTrain];%beacons as features
%     featTest = [imuFeaturesTest,  bleFeaturesTest];

    filename = [pre,'singleClassifierAll'];

    wekaDataBle(filename, featTrain, trainingRecords(end-1,:), activityLabelNames, true); %what about removed instances for the labels???? TODO
    wekaDataBle(filename, featTest, testingRecords(end-1,:), activityLabelNames, false);
    
end


