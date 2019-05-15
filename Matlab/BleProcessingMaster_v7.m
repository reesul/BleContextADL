%% 
% Script for trying to process All BLE devices
%
%  v1-4 deprecated and removed entirely. 
%  v5: Use rule-based classification to recognize context. ACP and AHAC
%           method created at this point.
%       _testing version: perform augmentations on dataset to test different
%           scenarios that may occur in realistic datasets (but not the one
%           first developed for this study).
%  v6: Subject specific data processing; subject id set in the first couple
%       lines
%  v7: Added comments, improved generalization

%% Options

tryIdentification = false;
maxNumCompThreads(1); %More than one thread has been found to cause issues during identification

%% Initial variable setup

recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
numUniqueDev = 0;
windowSize = 60*1000; % in ms

%% extract data from file and perform identfication to resolve random MACs
datapath = '';

if isempty(datapath)
    disp('Assign a datapath for the files obtained from the watch!\n');
    disp('This should contain many folders of format "MM-DD-YY"');
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
        

        [recognizedDevices, numUniqueDev] = identifyMacOnly(bleData, recognizedDevices, numUniqueDev);

            
        occurrenceMap = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d);
        
    end
    
end

%% Filter MACs of beacons down to those that only occur on a single day data
[cleanOMap, cleanDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev, true);

%% Generate records based on filtered set of beacons
[originalRecords, allRecords] = createRecords(datapath, cleanDevices, windowSize, cleanNumDev); % use 60 second interval for creating records

save('records.mat',  'recognizedDevices', 'numUniqueDev', 'occurrenceMap', 'cleanOMap', 'cleanDevices', 'cleanNumDev', 'originalRecords', 'windowSize');

%% Parse CSV file containing all labels and their start/end times, assign labels to records
csvPath='';

if isempty(csvPath)
    disp('Assign a path to the CSV file containing labels! There are examples under the Labels\ folder');
end

% pulls data from the csv file for intervals of time in which a label is
% valid
csvData = readActivityCsv(csvPath);
records = originalRecords;
%assigns a label using the timestamp marking the beginning of a record
allLabels = getLabelVec(csvData, records);
records = [records; allLabels];
%Remove the records that do not have a label
nonnullLabelIndex = ~strcmp('null', records(end-1,:));
records = records(:, nonnullLabelIndex);

%THESE WILL CHANGE DEPENDING ON THE SUBJECT. This does not use ALL labels
%in the CSV file because some may not be appropriate. This is the easiest
%way to specify them as opposed to paring down the labels CSV
activityLabelNames = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'research', 'schoolwork', 'walking'};
locationLabelNames = {'classroom_etb', 'classroom_wc', 'classroom_zach-1', 'classroom_zach-2', 'gym', 'home', 'lab', 'seminar_room'};



%% Extract features for IMU and heartrate

%function below is improperly named; simply pulls raw data from the files.
%rawSensorData will be a very large variable. clear it as soon as possible
rawSensorData = extractSensorData(records, datapath); %only want the raw data from this, calculate features separately on next line

% calculates features; helpful to do separatelyif the features are still
% being decided on. Also includes the starting timestamps of each feature
% vector to ensure it aligns with the records
[imuFeatures, imuTimes] = processIMU(records, rawSensorData, windowSize, {});
[hrFeatures, hrTimes] = processHR(records, rawSensorData, windowSize);
%% Extract statistical features for BLE
bleFeatures = statisticalBleFeat(records);

%% get rid of instances with missing data; normalize features
nonEmptyRecordInd = removeEmptyInstances(imuFeatures); %find instances where imu data was not present

%apply the same changes to the features
finalRecords = records(:, nonEmptyRecordInd);
imuFeatures = imuFeatures(nonEmptyRecordInd, :);
imuTimes = imuTimes(nonEmptyRecordInd, :);
% hrFeatures = hrFeatures(nonEmptyRecordInd, :); %HR features unused
bleFeatures = bleFeatures(nonEmptyRecordInd, :);

%normalize the imu features
imuFeatures = normalize(imuFeatures, 'range');
% hrFeatures = normalize(hrFeatures, 'range');
bleFeatures = normalize(bleFeatures, 'range');

%% Separate into training and testing datasets

%makes an approxmiate 75% split for each activity. Will ensure that the
%last instance in the training set is on a different day or 30 minutes away
%from the first instance in the testing set (for each ADL)
[trainingInds, testingInds] = distributeLabels(finalRecords, activityLabelNames); 

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
%Records should have an activity labels and context label. For scenario 2,
%there should be changes made to match 
[augTrainRecords, augTestRecords] = augmentRecords(trainingRecords, testingRecords, use1, use2, use3, subject);

useAugmented = false;
if useAugmented
%     finalRecords = augRecords;
    trainingRecords = augTrainRecords;
    testingRecords = augTestRecords;
end

%% Methods of pattern extraction
IOUthreshold = 0.75;
%version 2 use hierarchical clustering; version 3 uses our method of
%accumulative HAC
Patterns_Single = clusterRecordsFunc_v3(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, 1, true);
Patterns_HAC = clusterRecordsFunc_v2(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, false);
Patterns_AHAC = clusterRecordsFunc_v3(trainingRecords(end-1,:)', recordMatrix(trainingRecords), activityLabelNames, IOUthreshold, false);

%%
% Next sections will be used to apply different methods developed here.
% i.e., different pattern extraction approaches, the probabilistic ACP
% approach (or basic pattern usage), etc. Most further work would probably
% be following this comment. 

%% Calculate Bayesian probabilities and resulting 3-d matrix to represent (2-D for each record) the probability of P(activity | pattern)
patternMethod = 2; %0 is single-beacon pattern, 1 is HAC, and 2 is AHAC (the method we develop

if patternMethod == 0
    ruleSets = Patterns_Single;
elseif patternMethod == 1
    ruleSets = Patterns_HAC;
elseif patternMethod == 2
    ruleSets = Patterns_AHAC;
end
% create the activity-context probabilities
[patternPr, allPatterns, ~] = patternBayes(ruleSets, trainingRecords, activityLabelNames);    
contextTraining = cell(size(trainingRecords,2),4);
trainingRecordMtx = recordMatrix(trainingRecords);

% retrieve context information about each BLE record
for i=1:size(trainingRecordMtx,1)
    
    %return the probability matrix whose columsn correspond to the
    %satisfied patterns. Those patterns are  the second variable returned
    [contextTraining{i,1}, contextTraining{i,3}] = testRecord(trainingRecordMtx(i,:), allPatterns, patternPr);

    contextTraining(i,2) = trainingRecords(end-1,i);%label
    contextTraining{i,4} = [trainingRecords{1,i}, '  ', num2date(trainingRecords{2,i})]; %timestamp
    
end
% set of patterns that apply to this record
appliedPatterns = contextTraining(:,3);

%% separate data into subsets based on which activities share context. Sets aside indices for training and testing 

sizeThreshold = round(0.01*size(trainingRecords,2));%minimum number of instances for a subset to be valid, otherwise consider it an outlier, and that it has no context
naive = 0; %if true, no ACP; do Basic Pattern Usage
useLocation = 0; % use context labels for separation; gives a sort of upper bound
exactTrainingSet = false; %training instances are those which apply to that context; otherwise, use all training instances for the relevent activities
epsilon = 0.25; %parameter to reduce sensitivity to beacons that are very prevalent; achieve finer context separation

%the two below lines will return several variables. 
%trainingSubsets is the exact records that apply to a particular context
%   (described by the sharedContextLabels). sharedContextLabels is the first
%   column of this. The second is the instances that apply, and the third is
%   the actual labels that were found while finding each trainingSubset
%testingSubsets is just the indices of instances corresponding to those
%   sharedContextLabels
if naive %basic pattern usage
    [trainingSubsets, sharedContextLabels] = naivePartitionData(activityLabelNames, trainingRecords, sizeThreshold, ruleSets);
    [testingSubsets] = naivePartitionTestData(testingRecords, ruleSets, sharedContextLabels, activityLabelNames);
elseif useLocation %context labels decide context model
    [trainingSubsets, sharedContextLabels] = locationalPartition(trainingRecords);
    [testingSubsets] = locationalTestPartition(testingRecords, sharedContextLabels);
else %use ACP
    [trainingSubsets, sharedContextLabels] = partitionData(activityLabelNames, contextTraining, sizeThreshold, epsilon);
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
    
    % Get the training set first; will do the testing set after. This part
    % is longer than testing because there are multiple options to consider
    if exactTrainingSet
        %If using this, only train on the instances that apply to a context
        trInd = trainingSubsets{i,2};
        classifierIndSets{i,1} = trainingSubsets{i,2};
        classifierFeatureSets{i,1} = [imuFeaturesTrain(trInd,:), bleFeaturesTrain(trInd,:)];
    %     classifierFeatureSets{i,1} = [imuFeaturesTrain(trInd,:), hrFeatures(trInd,:), bleFeaturesTrain(trInd,:), contextFeaturesTrain(trInd,:)];
        classifierLabels{i,1} = trainingRecords(end-1, trInd)';
    else    
        %If using this, train on all instances whose labels belong to a shared context set
        ind = false(size(trainingRecords,2),1);
        
        for j=1:size(trainingRecords,2)
            if useLocation
                % if using location, only add an instance to that
                % location's training set if the label has been seen there
                % while partitioning
                recordLabel = trainingRecords(end-1,j);
                if ismember(recordLabel,trainingSubsets{i,3})
                    ind(j)=true;
                end
            else
                % add a record to that training set if it has a label
                % included in the shared context set
                recordLabel = trainingRecords(end-1,j);
                if ismember(recordLabel, labels)
                    ind(j) = true;
                end
            end

        end
        
        %Handle the null classifier here
        if useLocation
            if isempty(labels)
                ind=true(size(trainingRecords,2),1); %train on all records
            end
        else
            if isempty(labels) || any(strcmp(labels, 'null')) 
                ind = true(size(trainingRecords,2),1); %train on all instances
            end
        end

        % assign features for the future classifiers; save labels for naming the file 
        classifierIndSets{i,1} = ind;
        classifierFeatureSets{i,1} = [imuFeaturesTrain(ind,:), bleFeaturesTrain(ind,:)]; %only using IMU features and ble statistical features
        classifierLabels{i,1} = trainingRecords(end-1,ind)';
    end
    
    % Now do the testing set... simple, because the partitioning function
    % found the appropriate testing instances already
    tstInd = testingSubsets{i};
    classifierIndSets{i,2} = tstInd;
    

    classifierFeatureSets{i,2} = [imuFeaturesTest(tstInd,:), bleFeaturesTest(tstInd,:)];
    
    classifierLabels{i,2} = testingRecords(end-1, tstInd)';

end

%% Generate files for Weka (a machine learning prototyping software)

contextSeparate = 0; %use a single classifier, or use the sharedContextSets found in the previous section

if contextSeparate
    for i=1:size(classifierFeatureSets,1)
        filename = 'HAC+ACP_aug\'; %folder to contain the WEKA files; NAME APPROPRIATELY
        labels = sharedContextLabels{i};

        %generate the filename based on the labels used within this shared
        %context set. null-context is the default.
        if isempty(labels)
            s = 'null-context';
        else
            s=labels{1};
            for j=2:length(labels)
                s = [s, '-', labels{j}];
            end
        end
        filename = [filename, s];

        % save the files for training and testing. The last input variable
        % will append either '_training' or '_testing' to the file name
        wekaDataBle(filename, classifierFeatureSets{i,1}, classifierLabels{i,1}, activityLabelNames, true); %what about removed instances for the labels???? TODO
        wekaDataBle(filename, classifierFeatureSets{i,2}, classifierLabels{i,2}, activityLabelNames, false);
    end

else
    %choose a pair of lines for assigning features that is appropriate. 
    
%     featTrain = [imuFeaturesTrain, recordMatrix(trainingRecords), bleFeaturesTrain]; %beacons as features
%     featTest = [imuFeaturesTest,  recordMatrix(testingRecords), bleFeaturesTest];

%     featTrain = [bleFeaturesTrain, recordMatrix(trainingRecords)]; %only ble  features
%     featTest = [bleFeaturesTest, recordMatrix(testingRecords)];

    featTrain = [imuFeaturesTrain, bleFeaturesTrain]; %ble & imu
    featTest = [imuFeaturesTest,  bleFeaturesTest];

    filename = [pre,'singleClassifier_IMU_BStats']; %% NAME APPROPRIATELY

    wekaDataBle(filename, featTrain, trainingRecords(end-1,:), activityLabelNames, true); 
    wekaDataBle(filename, featTest, testingRecords(end-1,:), activityLabelNames, false);
    
end


