%% This script's purpose is to take BLE data of many devices and attempt to resolve randomized MAC addresses based on packet contents
% This takes significant time to run, so the results are saved to
% 'identification.mat', as this script is best run on a super-computing
% server

recognizedDevices = containers.Map;
occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
similarityThreshold = 0.75;
numUniqueDev = 0;

datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\'
dataDirs = ls(datapath)
blefile = 'ble_data.txt';


for d=1:4
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
