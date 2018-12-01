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
%  v3: Build adjacency/similarity matrix out of BLE

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

boxplot(cell2mat(records(4,:)));
fprintf('Refer to the plot to select a good threshold value for CV of each record;\n lower values are better!\n\n');
pause;

%% Use a threshold here to create a smaller set of 'good' records for
% clustering
threshold = -1; %threshold for CV values of each record
goodRecords = filterRecords(records, 'numeric threshold', threshold);
%% Generate similarity matrix and preference values

% Will need to attempt a grid search on the alpha and beta values
alpha=1; beta=1;
S_AP = similarityRecords(goodRecords, alpha, beta);
%[normS, posS] = normalizeSimilarity(S);

% Generate preference values to alter clsuter distribution; default is
% median of dataset as suggested by Affinity Propagation authors
% P = generatePreferences(S, other_stuff); %TODO

%% Do clustering and evaluate vs. data 
% see function details to provide additional arguments
[apOutput,~,clusters] = bleAPCluster(S_AP, length(S_AP), 'damp', 0.9);


%% Combine records for clusters into a single "record" (bit-vector) describing the cluster
% clusterReps are the set of binary vectors that represent which beacons
% are in each cluster; clusterRecords is the set of full records (timestamp
% included) for each cluster. Indexing is analagous between the two
[clusterReps, clusterRecords] = organizeClusters(clusters, goodRecords);

