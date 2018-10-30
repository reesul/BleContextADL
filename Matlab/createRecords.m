function [records, countArr] = createRecords(datapath,recognizedDevices,windowSize, numDevices)

dataDirs = ls(datapath)
blefile = 'ble_data.txt';

records = cell(2,0); %each record is a column here; first value is timestamp of record start, second is a binary vector corresponsding to beacon presence
countArr = zeros(numDevices);

%%Create records

for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
    
        [bleData, timestamps] = formatBleData(blePath);
        newR = createDaysRecords(bleData, timestamps, windowSize, numDevices, recognizedDevices);
        
        records = [records, newR];
        
        
        
    end
    
end

%% calculate an array describing the number of times each beacon shared a record with another beacon


records = records'; %this is because dynamic allocation is most efficient along last dimension - however, preferred format is in which one row 

end

%% helper functions
function[records] = createDaysRecords(bleData, timestamps, windowSize, numDevices, devices)

    records = cell(2,0);
    blankRecord = false(1,numDevices);
    winStart = 0;
    winEnd = 0;

    for i=1:length(bleData) 
        
       t = timestamps(i);
       
       if t>winEnd   %start new window i.e. new record 
           %save old record into 'records', begin a new one
           if i > 1
               records{1,end+1} = winStart;
               records{2,end} = br;
           end
           
           winStart = t;
           winEnd = t + windowSize;
           br = blankRecord;
       end
       
       m = getMacAndTime(bleData{i}); %extract the MAC address
       if devices.isKey(m)
           dev = devices(m);
           v = dev('value');

           br(v+1) = true; %indexing starts at 0 for values hence +1; 
       end
        
        
    end

end

function [MAC,time] = getMacAndTime(bleScan)
MAC = bleScan(31:47);
time = bleScan(7:23);
time = fulldate2num(time);

end