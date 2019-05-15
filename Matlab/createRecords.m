%% This file creates binary vectors to represent records for all BLE data in the files under the provided datapath. 
%This should be the same datapath provided when parsing all MACs. Records
%  are of length 'windowSize' milliseconds. The returned 'records' is a cell
%  array, where each record has a date, timestamp (ms since 00:00), record
%  vector, and two values for turnover, and one for the number of distinct
%  MACs scanned during that time. 
%'records' only contains records with at least one present MAC from the
%  filtered set (so vectors are always unempty). 
%'allRecords' does not have this condition; empty vectors may exist
function [records, allRecords] = createRecords(datapath,recognizedDevices,windowSize, numDevices)

dataDirs = ls(datapath)
blefile = 'ble_data.txt';

records = cell(6,0); %each record is a column here; first value is timestamp of record start, second is a binary vector corresponsding to beacon presence
countArr = zeros(numDevices);
supportArr = zeros(numDevices);

%% Create records

for d=1:size(dataDirs,1)
    if contains(dataDirs(d,:),'-')
        fprintf("Processing data for date %s\n", dataDirs(d,:)); 
        blePath = strcat(datapath,strtrim(dataDirs(d,:)));
        blePath = strcat(blePath,'\');
        blePath = strcat(blePath,blefile);
    
        [bleData, timestamps] = formatBleData(blePath); %reformats data into sequential scans
        newR = createDaysRecords(bleData, timestamps, windowSize, numDevices, recognizedDevices); %creates the set of records for this day
        
        records = [records, newR]; %concatenates new records onto existing ones
        
    end
    
end

%% Remove empty records from the data
recordMtx = recordMatrix(records);


nonNullSet = false(1,size(records,2)); %need to remove empty records
for i=1:size(records,2)
    %get distribution of support values
    r = recordMtx(i,:);
    
    numBeacons = sum(r);
    if numBeacons==0
        continue;
    end
    
    nonNullSet(i) = true;

end


allRecords = records;
records = records(:,nonNullSet);


end

%% helper functions
function[records] = createDaysRecords(bleData, timestamps, windowSize, numDevices, devices)

records = cell(5,0);
blankRecord = false(1,numDevices); %placeholder
winStart = 0;
winEnd = 0;
date = bleData{1}; %day this data was collected on
date = date(7:14);
windowMACs = {};
pastWindowMACs = {};

for i=1:length(bleData) 

   t = timestamps(i);

   if t>winEnd   %start new window i.e. new record 
       
       %save old record into 'records', begin a new one 
       if i > 1 %don't do this for the first scan; just let a new record be created
           
           %extend the size of records, add the date, timestamp of start,
           %and binary record itself
           records{1,end+1} = date; 
           records{2,end} = winStart;
           records{3,end} = br;

           %5th value is beacon turnover, which is 0 for the first
           %record of the day (size==1), or if the time difference
           %between window is larger than the window size 
           if ( size(records,2)==1 || (winStart-records{2,end-1} > 2*windowSize) ) 
               records{4,end} = 0;
               records{5,end} = 0;
               
           else
               % calculate turnover for filtered (br) and unfiltered (MACs) beacons
                [records{5,end}, records{4,end}] = beaconTurnover(windowMACs, pastWindowMACs, records{3,end-1},br);
           end
           records{6,end} = length(windowMACs); % save number of unfiltered MACs
           
           pastWindowMACs = windowMACs;
           windowMACs = {};
           
           %fourth element of records cell must be computed after some
           %additional processing

       end

       %update variables for new window
       winStart = t;
       winEnd = t + windowSize;
       br = blankRecord;
   end

   m = getMacAndTime(bleData{i}); %extract the MAC address for this scan
   
   if ~any(ismember(m, windowMACs)) %if MAC isn't already saved, do so
       windowMACs = [windowMACs, m];
   end
      
   if devices.isKey(m) % if this MAC is part of the filtered set, indicate in the record (br) that is is present (true or =1)
       dev = devices(m);
       v = dev('value');

       br(v) = true; 
   end

end

end

%takes the BLE scan, and retrieves the MAC, date, and timestamp from the
%expected format. This format should be unchanged if data comes from the
%data collection Android app
function [MAC,time,date] = getMacAndTime(bleScan)
MAC = bleScan(31:47);
time = bleScan(7:23);

time = date2num(time); %convert time into milliseconds since midnight
date = bleScan(7:14);

end