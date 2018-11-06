function [records, countArr, supportArr] = createRecords(datapath,recognizedDevices,windowSize, numDevices)

dataDirs = ls(datapath)
blefile = 'ble_data.txt';

records = cell(3,0); %each record is a column here; first value is timestamp of record start, second is a binary vector corresponsding to beacon presence
countArr = zeros(numDevices);
supportArr = zeros(numDevices);

%% Create records

for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        fprintf("Processing %s\n", dataDirs(d,:)); 
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
        [bleData, timestamps] = formatBleData(blePath);
        newR = createDaysRecords(bleData, timestamps, windowSize, numDevices, recognizedDevices);
        
        records = [records, newR];
        size(records)
        
    end
    
end

%% calculate an array describing the number of times each beacon shared a record with another beacon

recordMtx = records(3,:);
fprintf('record matrix size %d %d', size(recordMtx));
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(records),numDevices]);

%Make diagonal first - how many times records a beacon occurred in
for i=1:numDevices
    countArr(i,i) = sum(recordMtx(:,i));
end

%count how many times two beacons showed up together
for i=1:numDevices
    for j=(i+1):numDevices %support metric is symmetric, only loop over upper-right half of mtx from diagonal
        countArr(i,j) = sum(and(recordMtx(:,i),recordMtx(:,j))); %intersection; count records that both beacons were present in
        supportArr(i,j) = countArr(i,j) / (countArr(i,i) + countArr(j,j) - countArr(i,j)); %support value for record i vs. j; intersect over union 
        
    end
end


end

%% helper functions
function[records] = createDaysRecords(bleData, timestamps, windowSize, numDevices, devices)

    records = cell(3,0);
    blankRecord = false(1,numDevices);
    winStart = 0;
    winEnd = 0;
    date = bleData{1}; %day this data was collected on
    date = date(7:14);

    for i=1:length(bleData) 
        
       t = timestamps(i);
       
       if t>winEnd   %start new window i.e. new record 
           %save old record into 'records', begin a new one
           if i > 1
               %todo add date
               records{1,end+1} = date;
               records{2,end} = winStart;
               records{3,end} = br;
           end
           
           %update variables for new window
           winStart = t;
           winEnd = t + windowSize;
           br = blankRecord;
       end
       
       m = getMacAndTime(bleData{i}); %extract the MAC address
       if devices.isKey(m)
           dev = devices(m);
           v = dev('value');

           br(v+1) = true; %values start at 0, but indexing starts at 1 for arrays, hence +1; 
       end
        
        
    end

end

function [MAC,time,date] = getMacAndTime(bleScan)
MAC = bleScan(31:47);
time = bleScan(7:23);
%time = fulldate2num(time); % This is necessary?
time = date2num(time);
date = bleScan(7:14);

end