function [recognizedDevices, numUniqueDev] = identifyBeacons(bleData, recognizedDevices, numUniqueDev, similarityThreshold)

for b=1:length(bleData)
   pInfo = extractFields(bleData{b});
   if isempty(pInfo) % this is the case if an empty packet is detected
       continue;
   end
   
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
   elseif ignoreBeacon(pInfo)
       pInfo('value') = numUniqueDev; 
       numUniqueDev = numUniqueDev+1;
       
       pInfo('scanNum') = 1;
       recognizedDevices(MAC) = pInfo;
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
           
end  

end

% function to extract all relevant fields from the BLE record
function [packetInfo] = extractFields(scan)

%extract basic information (MAC, raw packet) from scan data
startMac = strfind(scan,'mac:{') + length('mac:{');
MAC = scan(startMac: startMac+16);
startpacket = strfind(scan,'raw_data:{') + length('raw_data:{');
packet = scan(startpacket: end-1);

if strcmp(packet,'00') %packet is empty for some reason; ignore these
    packetInfo=[];
    return;
end

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
packetInfo('EddyStoneUID') = {}; %Eddystone is a format that may have its own identifiers
packetInfo('EddyStoneURL') = {};
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
    
    %remainder of bytes are the payload for this data unit
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
    packetInfo('M-ID') = m_info(1:4); %pull out the manufacturer id
    packetInfo('FF') = m_info(5:end); %no need to keep manufacturer id here
    if strcmp(m_info(1:4), '4C00')
        if length(m_info)<8
            %disp('bad length subfield');
            
        elseif strcmp(m_info(1:8), '4C000215') %if true, this is iBeacon format
            packetInfo('iBeacon') = m_info(9:end-2);      %extract UUID and major/minor number  
        end
    end
end

if ~isempty(packetInfo('03')) && ~isempty(packetInfo('16'))
    serviceData = packetInfo('16');
    serviceData = serviceData{1};
    if strcmp(packetInfo('03'),'AAFE') %service UUID for eddystone (google)
       index=5;
       type = serviceData(index); %tells what specific format this is
       if strcmp(type, '0') %Eddystone UID format
           packetInfo('EddyStoneUID') = serviceData(index+4:index+35);
       elseif strcmp(type, '1') %Eddystone URL format
           packetInfo('EddyStoneURL') = serviceData(index+4:end);
       end %not accounting for TLM format - too variable
       
    end
    
    if strcmp(packetInfo('03'), serviceData(1:4))
        packetInfo('16') = serviceData(5:end); %16 bit UUID should be present in service data: if so, remove it from the stored info
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

strictFields = [{'02'}, {'03'}, {'04'}, {'05'}, {'06'}, {'07'}, {'08'}, {'09'}, {'M-ID'}, {'EddyStoneUID'}, {'iBeacon'}];
flexibleFields = [{'16'}, {'FF'}, {'EddyStoneURL'}];
    
%Next, check if the set of fields is actually identical 
fields = {};
fieldsNew = {};

%get the set of nonempty fields
keys = device.keys;
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


distances = [];
for i=1:length(fields)
    f=fields{i};
    existingF = device(f);
    newF = newDevice(f);
    
   %numAgree = numAgree + double(strcmp(device(fields{i}),newDevice(fields{i})));
   if (isIn(f,strictFields))
       if ~strcmp(existingF, newF) %if a strict field is different, then we know this is not the same device
           return;            
       end
       
   elseif (isIn(f,flexibleFields)) %compare these using a hamming distance
%        %get the minimum length, compare based off of this
%        disp('compare flexible fields:');
       if iscell(existingF)
            existingF = existingF{1};
       end
       if iscell(newF)
            newF=newF{1};
       end
       
       minLen = length(existingF);
       if length(existingF) > length(newF)
           minLen = length(newF);
       end
       diffLen = abs(length(existingF) - length(newF));
       %calculate different, difference in length is considered
       %error or difference
       distances(end+1) = (sum(existingF(1:minLen) ~= newF(1:minLen))+diffLen)/(minLen + diffLen);
       
   end
   
end

s = 1 - sum(distances);
%or,
%s = 1 - sum(distances)

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

%helper function to see if a string is an element within a cell array
function [bool] = isIn(str, cellArr)
bool=false;
for i=1:length(cellArr)
    if strcmp(str,cellArr{i})
        bool=true;
        return;
    end
end


end

%If this returns true, do not compare this beacon to others - just assume
%that this new MAC is a unique device
function [bool] = ignoreBeacon(pInfo)
bool = true;

%get the set of fields with non-null values for this MACs packet
fields={};
keys = pInfo.keys;
for i=1:length(keys)
    k = keys{i};
    %ignore certain fields, since these should always be non-empty
    if strcmp(k,'MAC') || strcmp(k,'value') || strcmp(k,'scanNum')
        continue
    end
    
    if ~isempty(pInfo(k))
        fields{end+1} = k;
    end
end


%nothing useful in the packet
if isempty(fields)
    return;
%if the device name is the only thing present, ignore as this can be the
%same among many different physical devices
elseif length(fields)==1 && (~isempty(pInfo('09')) || ~isempty(pInfo('08')))
    return;
%if only manufacturer info in Apple format, ignore because too many devices
%have little variation here for unique ID
elseif ~isempty(pInfo('M-ID')) && ~isempty(pInfo('FF')) && length(fields)==2 && strcmp(pInfo('M-ID'),'4C00')
    return;
end

bool = false;
end