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

%% Initial variable setup
recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
similarityThreshold = 0.75;
numUniqueDev = 0;

%% extract data from file

datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\'
dataDirs = ls(datapath)
blefile = 'ble_data.txt';


for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
    
        [bleData,~] = formatBleData(blePath);
        [recognizedDevices, numUniqueDev] = identifyBeacons(bleData, recognizedDevices, numUniqueDev, similarityThreshold);
        occurrenceMap = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d);
    end
    
end

save('identification.mat', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap');

%% Clean data
[cleanOMap, cleanDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev);


%% log data for viewing
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

%% Generate similarity matrix
S = similarityBLE(cleanOMap);
[normS, posS] = normalizeSimilarity(S);

%%Do clustering
[x,Tclusters,OGclusters]=bleAPCluster(normS, 'damp', 0.5, 'clusterSize', 1, 'scalingFactor', 1);
