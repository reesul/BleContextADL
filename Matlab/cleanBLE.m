%% Filter the set of MACs found after retrieving from files. Rule is simple: if the beacon only occurred on a single day, then do not worry about it in the future
function [cleanOccurrenceMap, cleanRecognizedDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev, isCheckBadMACs)

%initialization
cleanNumDev = 0;
cleanOccurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
cleanRecognizedDevices = containers.Map;

if ~exist('isCheckBadMACs', 'var')
    isCheckBadMACs = false; %if not specified, don't look for special devices
end

% set of MACs we know are bad based on prior knowledge
if isCheckBadMACs
    badMACs = findSpecialDevices(recognizedDevices); %tries to remove devices we know to be bad
else
    badMACs = {};
end
    
k = occurrenceMap.keys();
for i=1:length(k)
    
    key = k{i};
    occurrenceSet = occurrenceMap(key);
    %remove if only seen for one occurrence or only seen on one day
    if size(occurrenceSet,1)==1 || occurrenceSet(1,1) == occurrenceSet(end,1)
        fprintf('device %d is no good, do not keep it\n', key)
    elseif checkForBadMAC(badMACs, key, recognizedDevices)
        fprintf('device %d should specifically not be in the data, do not keep it\n', key);
    else
        %device is good, keep it; copy its information into the filtered
        %set
        cleanNumDev = copyDevice(key, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices);
    end
        
end


end

%% Copy information from this device into the Map holding the filtered device's information. 
function [cleanNumDev] = copyDevice(value, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices)

cleanNumDev = cleanNumDev + 1;

%copy devices to recognized devices map (MAC is key, contains information
%about packet itself
MACs = findMACs(value, recognizedDevices);

if isempty(MACs)
    return;
end

for i=1:length(MACs)
    tmp = recognizedDevices(MACs{i}); %retrive information about device
    tmp('value') = cleanNumDev; %update value
    cleanRecognizedDevices(MACs{i}) = tmp; %store into new map
    
end

%copy devices in occurrenceMap to the cleaned one. This is a structure; it
%will change without being returned. 
cleanOccurrenceMap(cleanNumDev) = occurrenceMap(value);

end

%apply some prior knowledge to remove certain device. Generally not
%recommended to use
function [MACs] = findSpecialDevices(recognizedDevices)
MACs = [];
fprintf('Search for devices we have prior knowledge on such that the device should be removed from data');

%This searches for particular values in the device maps. This is very slow.
% For instnace, the one below searches for a device name 'LG SJ4Y(E0)', one
% subject's cell phone. 
% [~, values, ~] = searchDeviceMap(recognizedDevices, '09', 'LG SJ4Y(E0)');
% MACs = findMACs(values, recognizedDevices);

% for further devices to remove, concatenate onto cell array MACs
%add more cases as they arise
%[~,V,~] = searchDeviceMap(recognizedDevices, searchField, searchValue)
% MACs = [MACs, (findMACs,V)];


% [~,values,~] = searchDeviceMap(recognizedDevices, '09', 'Tile');
% MACs = [MACs, findMACs(values, recognizedDevices)];

%because some devs are idiots and didn't assign a real MAC address. Not even sure how those devices would function properly
MACs = [MACs, {'00:00:00:00:00:00'}]; end

% tries to find a value in the set of devices that have MAC's we know to be
% bad. 
function [b] = checkForBadMAC(badMACs, value, recognizedDevices)
%get macs assocaited with value
b=0;
MACs = findMACs(value, recognizedDevices);

for i=1:length(MACs)
    for j=1:length(badMACs)
        if strcmp(MACs{i}, badMACs{j})
            b=1;
            disp('Removing:');
            disp(MACs{i})
            return
        end
        
    end
end
%if mac bad, return 1; 2d loop to check between MACs and badMACs

end