function [records, countArr] = createRecords(dataPath,recognizedDevices,windowSize, numDevices)

datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\'
dataDirs = ls(datapath)
blefile = 'ble_data.txt';

record = cell(2,0); %each record is a column here; first value is timestamp of record start, second is a binary vector corresponsding to beacon presence
countArr = zeros(numDevices);

for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
    
        [bleData, timestamps] = formatBleData(blePath);
        newR = createDaysRecords(bleData, timestamps, windowSize, numDevices);
        
        records = [records, newR];
        
        
        
    end
    
end


records = records'; %this is because dynamic allocation is most efficient along last dimension - however, preferred format is in which one row 

end


function[records] = createDaysRecords(bleData, timestamps, windowSize, numDevices)

    records = cell(2,0);
    blankRecord = zeros(1,numDevices);

    startTime = date2num(

end