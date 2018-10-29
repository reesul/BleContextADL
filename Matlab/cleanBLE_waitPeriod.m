function [cleanOccurrenceMap, cleanRecognizedDevices, cleanNumDev] = cleanBLE(occurrenceMap, recognizedDevices, numUniqueDev)

%initialize
cleanNumDev = 0;
cleanOccurrenceMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
cleanRecognizedDevices = containers.Map;

waitPeriod = 60 * 60 * 1000; %For beacons seen only on one day, discard it that device is only seen in a **one hour** period (todo: find optimal waitPeriod)
%waitPeriod selected such that randomized MACs will change within period

% set of MACs we know are bad based on prior knowledge
badMACs = findSpecialDevices(recognizedDevices);

k = occurrenceMap.keys();
for i=1:length(k)
    key = k{i};
    %get array describing the time in which a beacon was detected
    occurrenceSet = occurrenceMap(key);
    
    %if we have one occurrence or all occurrences on same day, compare
    %first and last scan times to the wait period
    badTiming = (size(occurrenceSet,1)==1 || occurrenceSet(1,1) == occurrenceSet(end,1)) ... %occurrences all on one day
        && (occurrenceSet(end,3) - occurrenceSet(1,2) < waitPeriod); %AND all scans within a $(waitPeriod) period of time
    
    if badTiming
        sprintf('device %d is no good, do not keep it', key)
    elseif checkForBadMAC(badMACs, key, recognizedDevices)
        sprintf('device %d should specificially not be in the data, do not keep it', key);
    else
        %device is good, keep it
        cleanNumDev = copyDevice(key, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices);
    end
        
    
    
end



end


function [cleanNumDev] = copyDevice(value, occurrenceMap, recognizedDevices, cleanNumDev, cleanOccurrenceMap, cleanRecognizedDevices)

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

%copy devices in occurrenceMap
cleanOccurrenceMap(cleanNumDev) = occurrenceMap(value);
cleanNumDev = cleanNumDev + 1;


end

%apply some prior knowledge to remove certain device
function [MACs] = findSpecialDevices(recognizedDevices)

% remove cell phone from data - this field (device complete name) was found
%   from viewing data; could not be found through device's OS
[~, values, ~] = searchDeviceMap(recognizedDevices, '09', 'LG SJ4Y(E0)');
MACs = findMACs(values, recognizedDevices);

% for further devices to remove, concatenate onto cell array MACs
%add more cases as they arise
%[~,V,~] = searchDeviceMap(recognizedDevices, searchField, searchValue)
% MACs = [MACs, (findMACs,V)];


%handle Ofos - commented out because identification method fixed issues
%[~,values,~] = searchDeviceMap(recognizedDevices, '09', 'ofo')
%MACs = [MACs, findMACs(values, recognizedDevices)];


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