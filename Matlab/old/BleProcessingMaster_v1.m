%% extract data from file
datapath = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\BLE_project_data\Reese\08-27-18\'
blefile = 'ble_data.txt';
[bleData,~] = formatBleData(strcat(datapath, blefile));

%% extract data from unrolled set of scans and attempt to uniquely identify
extractedInfo = {}; %cell array containing map object for each ***needed??***
similarityThreshold = 0.75;

%[MAC_packetMap, packet_MACMap, collisionMap, fullInfoMap, values] = unknownBLE_UUID(bleData);

% %Try to evaulate using these functions
%PackInfo = extractFields(bleData{1,1});
%dispMap(PackInfo)

recognizedDevices = containers.Map;
numUniqueDev = 0;
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
toc


%% function to extract all relevant fields from the BLE record
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
end

end

%Display the properties of device
function [] = dispMap(device)

k = device.keys;
for i=1:length(k)
    f = device(k{i});
    if isempty(f)
        fprintf('%s : NULL\n', k{i});
    else
        fprintf('%s : %s\n', k{i}, string(f));
    end
end
end

%
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
%TODO calculate Hamming distances
numAgree = 0;
total = length(fields);
for i=1:length(fields)
   numAgree = numAgree + double(strcmp(device(fields{i}),newDevice(fields{i})));
end

%ratio of agreement between devices
s = numAgree/total;

end

function [simVal, MAC] = findMatchBLE(pInfo, pastDevMap)

similarity=[];
MAClist = {};
keys = pastDevMap.keys;

for i = 1:length(keys)
    deviceData = pastDevMap(keys{i});
    
    s = bleSimilarity(deviceData, pInfo);
    
    if s>0
        similarity(end+1) = s;
        MAClist(end+1) = keys(i);
    end
    
end

%get back the device that is most similar (highest value) to the new input
%[similarity, sortedInd] = sort(similarity,'descend');
%MAClist = MAClist(sortedInd);

if isempty(MAClist)
    simVal = -1;
    MAC={};
    return;
end

[simVal, index] = max(similarity);
MAC = MAClist{index};

end