%% This script's purpose is to take BLE data of many devices and attempt to resolve randomized MAC addresses based on packet contents
% This takes significant time to run, so the results are saved to
% 'identification.mat', as this script is best run on a super-computing
% server

%%Need to continue where HPRC left off..

% recognizedDevices = containers.Map;
% occurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
% numUniqueDev = 0;

similarityThreshold = 0.75;

load('identification.mat')
dd=d;


datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\'
dataDirs = ls(datapath)
blefile = 'ble_data.txt';

dataDirs = ['08-28-18';  '08-30-18';  '09-03-18';  '09-07-18';	'09-11-18';  '09-13-18';  '09-15-18'; '09-17-18'; ...
     '08-29-18';  '08-31-18';  '09-04-18';  '09-10-18';	'09-12-18';  '09-14-18';  '09-16-18']



for d=dd:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile)
    
    
        [bleData,~] = formatBleData(blePath);
        [recognizedDevices, numUniqueDev] = identifyBeacons(bleData, recognizedDevices, numUniqueDev, similarityThreshold);
        occurrenceMap = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d);
        d
        
        save('identificationCont.mat', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap', 'd');
    end
    
end

save('identificationCont.mat', 'recognizedDevices', 'numUniqueDev', 'occurrenceMap');
