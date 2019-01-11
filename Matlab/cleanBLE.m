function [cleanOccurrenceMap, cleanRecognizedDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev, isCheckBadMACs)

%initialize
cleanNumDev = 0;
cleanOccurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
cleanRecognizedDevices = containers.Map;

if ~exist('isCheckBadMACs')
    isCheckBadMACs = false;
end

% set of MACs we know are bad based on prior knowledge
if isCheckBadMACs
    badMACs = findSpecialDevices(recognizedDevices);
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
        %device is good, keep it
        cleanNumDev = copyDevice(key, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices);
    end
        
end


end


function [cleanNumDev] = copyDevice(value, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices)

cleanNumDev = cleanNumDev + 1;

%copy devices to recognized devices map (MAC is key, contains information
%about packet itself
MACs = findMACs(value, recognizedDevices);

if isempty(MACs)
    return;
end

for i=1:length(MACs)
    tmp = recognizedDevices(MACs{i});
    tmp('value') = cleanNumDev; %update value
    cleanRecognizedDevices(MACs{i}) = tmp;
    
end

%copy devices in occurrenceMa
cleanOccurrenceMap(cleanNumDev) = occurrenceMap(value);

end

%apply some prior knowledge to remove certain device
function [MACs] = findSpecialDevices(recognizedDevices)

fprintf('Search for devices we have prior knowledge on such that the device should be removed from data');
[~, values, ~] = searchDeviceMap(recognizedDevices, '09', 'LG SJ4Y(E0)');
MACs = findMACs(values, recognizedDevices);

% for further devices to remove, concatenate onto cell array MACs
%add more cases as they arise
%[~,V,~] = searchDeviceMap(recognizedDevices, searchField, searchValue)
% MACs = [MACs, (findMACs,V)];



[~,values,~] = searchDeviceMap(recognizedDevices, '09', 'Tile');
MACs = [MACs, findMACs(values, recognizedDevices)];

MACs = [MACs, {'00:00:00:00:00:00'}]; %because some devs are idiots and didn't assign real MAC addrress
end

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