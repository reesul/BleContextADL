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
        [recognizedDevices, numUniqueDev] = mapDaysData(bleData, recognizedDevices, numUniqueDev, similarityThreshold);
        occurrenceMap = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d);
    end
    
end

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
%% local functions

% update the map for a set of a data
function [recognizedDevices, numUniqueDev] = mapDaysData(bleData, recognizedDevices, numUniqueDev, similarityThreshold)

for b=1:length(bleData)
   pInfo = extractFields(bleData{b});
   MAC = pInfo('MAC');
   
   %if true, MAC has been seen before
   if recognizedDevices.isKey(MAC)
       recDev = recognizedDevices(MAC);
       pInfo('value') = recDev('value');
       
       %modify device's dictionary/map
       recDev('scanNum') = recDev('scanNum') + 1;
       
%      dispMap(recDev);
%      dispMap(recognizedDevices(MAC));
      
    %MAC has not been seen before; create new device entry, but it could be
    % an instance of a past device (i.e. MAC changes)
   else
       %try to calculate some similarity between pInfo and all devices seen
       %previously; highest value and corresponding MAC are returned
       [similarity, existingMac] = findMatchBLE(pInfo, recognizedDevices);
       %threshold the similarity
       if similarity >= similarityThreshold
           pastDevice = recognizedDevices(existingMac); %assume this is the same device but with a new MAC
           pInfo('value') = pastDevice('value'); %device will resolve to same value number (ID) as other MAC does
           
       else %if no device is similar enough, append an entirely new one to the map
           pInfo('value') = numUniqueDev; 
           numUniqueDev = numUniqueDev+1;
       end
       
       pInfo('scanNum') = 1;
       recognizedDevices(MAC) = pInfo;
   end
           
   continue; %dummy, just use for breakpoint
end  

end

% function to extract all relevant fields from the BLE record
function [packetInfo] = extractFields(scan)

%extract basic information (MAC, raw packet) from scan data
startMac = strfind(scan,'mac:{') + length('mac:{');
MAC = scan(startMac: startMac+16);
startpacket = strfind(scan,'raw_data:{') + length('raw_data:{');
packet = scan(startpacket: end-1);

%generalized format
packetInfo = containers.Map;
packetInfo('MAC') = MAC;
packetInfo('02') = {};  %16 bit UUID
packetInfo('03') = {};  %16 bit UUID
packetInfo('04') = {};  %32 bit UUID
packetInfo('05') = {}; %32 bit UUID
packetInfo('06') = {}; %128 bit UUID
packetInfo('07') = {}; %128 bit UUID
packetInfo('08') = {};  %shorted local name
packetInfo('09') = {};  %complete local name
packetInfo('16') = {};  %service data, first two bytes are service UUID
packetInfo('FF') = {};  %manufacturer specific data, first two bytes are company ID
packetInfo('M-ID') = {};%manufacturer's id
packetInfo('value') = -1;   %act as an index for the device; independent of MAC
packetInfo('scanNum') = 0;  %number of times this device has been scanned
packetInfo('EddyStone') = {}; %Eddystone is a format that may have its own identifiers
packetInfo('iBeacon') = {}; %Similar to Eddystone

%parse advertisement packet
index=1;
while index <= length(packet)
    len=packet(index:index+1);
    len=hex2dec(len) * 2; %because we have hex digits, but length is in bytes

    if len==0
        break;
    end
    
    %next two bytes describe the packet
    type = packet(index+2:index+3);
    
    %remainder of bites are the payload for this data unit
    %   starts 2 bytes after index (1 for length, 1 for type)
    %   second bound has index+2 to account for first byte not being
    %   included in overall length
    payload = packet(index+4:(index+2)+(len-1));

    %save type and data into info
    if packetInfo.isKey(type)
        packetInfo(type) = {payload};
    end
    index = index+(len+2); % update index to move onto the next data unit in the packet
end

%get manufacturer ID if present
if ~isempty(packetInfo('FF'))
    m_info = packetInfo('FF');
    m_info = m_info{1};
    packetInfo('M-ID') = m_info(1:4);
    if strcmp(m_info(1:4), '4C00')
        if length(m_info)<8
            %disp('bad length subfield');
            
        elseif strcmp(m_info(1:8), '4C000215') %if true, this is iBeacon format
            packetInfo('iBeacon') = m_info(9:end-2);        
        end
    end
end

if ~isempty(packetInfo('03'))
    if strcmp(packetInfo('03'),'AAFE')
       eddyStoneInfo = cell(1,2);
       eddyPacket = packetInfo('16');
       eddyPacket = eddyPacket{1};
       
       index=5;
       type = eddyPacket(index);
       if strcmp(type, '0') %Eddystone UID format
           eddyStoneInfo{1} = eddyPacket(index+4:index+35);
       elseif strcmp(type, '1') %Eddystone URL format
           eddyStoneInfo{2} = eddyPacket(index+4:end);
       end %not accounting for TLM format - too variable
       
       packetInfo('EddyStone') = eddyStoneInfo;
    end
    
end

end

%Display the properties of device
function [] = dispMap(device)

k = device.keys;
for i=1:length(k)
    f = device(k{i});
    
    if strcmp(k{i},'EddyStone')
        for j=1:2
            if isempty(f(j))
                fprintf('%s(%d) : NULL\n', k{i},j);
            else
                fprintf('%s(%d) : %s\n', k{i}, j, string(f{j}));
            end
        end
        continue;
    end    
    if isempty(f)
        fprintf('%s : NULL\n', k{i});
    else
        fprintf('%s : %s\n', k{i}, string(f));
    end

            
end
end

%Create a value to reprsent the similarity between two devices based off of
%the subfields contained within the advertisement packet
% The return value is normalized to [0,1]; however, 
%  A negative value means the two are assumed to be different physical
% devices with relatively high certainty
function [s] = bleSimilarity(device, newDevice)
s = -1;

%compute number of non empty fields
    % if they match, then this device is a candidate, otherwise ignore
if length(device.keys) ~= length(newDevice.keys)
    return;
end   
    
%Next, check if the set of fields is identical 
fields = {};
fieldsNew = {};

keys = device.keys;
%get the set of nonempty fields
for i=1:length(keys)
    k = keys{i};
    %ignore certain fields, since these should always be non-empty
    if strcmp(k,'MAC') || strcmp(k,'value') || strcmp(k,'scanNum')
        continue
    end
    
    if ~isempty(device(k))
        fields{end+1} = k;
    end
    if ~isempty(newDevice(k))
        fieldsNew{end+1} = k;
    end    
end

%ignore this device (return) if non-equal number of fields
if length(fields) ~= length(fieldsNew)
    return;    
end

%all nonempty fields should be the same between the two devices; if not,
%assume this is not a related device, and return.
for i=1:length(fields)
    if ~strcmp(fields{i},fieldsNew{i})
        return;
    end
end

%compare the values of each field; generate similarity off of this
%TODO calculate Hamming distances?
numAgree = 0;
total = length(fields);

if ~isempty(newDevice('EddyStone')) & ~isempty(device('EddyStone'))
    % compare things in Eddystone packet
    % use separate function
    s = eddystoneSimilarity(device, newDevice);
elseif ~isempty(newDevice('iBeacon')) & ~isempty(device('iBeacon'))
    %compare things in iBeacon packet
    s = iBeaconSimilarity(device, newDevice);
else %normal packet, compare each field value
    numAgree = 0;
    total = length(fields);
    for i=1:length(fields)
       numAgree = numAgree + double(strcmp(device(fields{i}),newDevice(fields{i})));
    end
    s = numAgree/total;
end

% %ratio of agreement between devices
% s = numAgree/total;

end

%Attempts to find a previously processed device that matches well against
%the input device's BLE scan results. 
%   TODO: optimize
function [simVal, MAC] = findMatchBLE(pInfo, pastDevMap)

% similarity=[];
% MAClist = {};
keys = pastDevMap.keys;
MAC={};
simVal=-1;

for i = 1:length(keys)
    deviceData = pastDevMap(keys{i});
    
    s = bleSimilarity(deviceData, pInfo);
    
    if s==1
        simVal = s;
        MAC = keys{i};
        return;
%     elseif s>0
%         similarity(end+1) = s;
%         MAClist(end+1) = keys(i);
    elseif s > simVal
        simVal = s;
        MAC = keys{i};
    end
    
end

%get back the device that is most similar (highest value) to the new input
%[similarity, sortedInd] = sort(similarity,'descend');
%MAClist = MAClist(sortedInd);

% if isempty(MAClist)
%     simVal = -1;
%     MAC={};
%     return;
% end
% 
% [simVal, index] = max(similarity);
% MAC = MAClist{index};

end

function [s] = eddystoneSimilarity(device, newDevice)
x = strcmp(device('EddyStone'), newDevice('EddyStone'));
s=double(any(x));

end

function [s] = iBeaconSimilarity(device, newDevice)
s = double(strcmp(device('iBeacon'), newDevice('iBeacon')));

end