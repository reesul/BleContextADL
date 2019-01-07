function [occurrenceMap] = occurrenceIntervals(bleData, recognizedDevices, occurrenceMap, d)
windowSize = 1000*60*3; %3 minutes

winStart = bleTime(bleData{1});
winStop = winStart+windowSize;

queueLength = 4;
queue = cell(1,queueLength); %give devices ~15 minutes grace period between occurrences
currentDevices = {}; % set of device IDs seen w/i this window

b=0;
while b< length(bleData) 
    b=b+1;
% for b=1:length(bleData)
    scan = bleData{b};
    time = bleTime(scan);
    
    %if this has already passed the window's end, move back, change window
    %bounds, and shift the queue back
    % Also, current BLE scan is outside previous window; go back and
    % consider it in new window
    if time > winStop
        b=b-1;
        winStart = time;
        winStop = winStart + windowSize;
        for j=size(queue,2):-1:2 %push queue back
            queue{j} = queue{j-1};
        end
        queue{1} = currentDevices;
        currentDevices = {};
        
        continue;
    end
    
    MAC = getMac(scan);
    if recognizedDevices.isKey(MAC)
        device = recognizedDevices(MAC);
    else %somehow a device we weren't expecting got in... ignore it completely
        continue;
    end
    
    value = device('value');
    
    if occurrenceMap.isKey(value)
        occurrenceArr = occurrenceMap(value);
        
        %if we have seen the device recently, consider this to be part of
        %the same occurrence, and extend the time
        if checkQueue(value, queue, currentDevices)
            if (occurrenceArr(end,3) + (length(queue)+1)*windowSize) >= time %check for gaps in the data
            occurrenceArr(end, 3) = time;
            currentDevices{end+1} = value; %** TODO change to one-hot encoding
            
            else
                occurrenceArr(end+1,1) = d;
                occurrenceArr(end,2) = time;
                occurrenceArr(end,3) = time;
                currentDevices{end+1} = value;
            end
        else %haven't seen the device recently, so create new occurrence
            occurrenceArr(end+1,1) = d;
            occurrenceArr(end,2) = time;
            occurrenceArr(end,3) = time;
            currentDevices{end+1} = value;
        end
        
        occurrenceMap(value) = occurrenceArr;
    else
        %add a new device onto the occurrence
        currentDevices{end+1} = value;
        occurrenceMap(value) = [d, time, time];
        %update end value of 
    end
    
end

end

function [rawTime] = bleTime(bleScan)
%bleScan should be a singular scan of a device; data should have already
%been retrieved and unrolled from file
timestamp = bleScan(7:23); %time of the timestamp
rawTime = date2num(timestamp); %converts to a decimal number (in ms); does not account for date(!)

end

function[MAC] = getMac(bleScan)
MAC = bleScan(31:47);
end

% check if we have recently seen the device in question i.e. is it in the queue    
function [isInQueue] = checkQueue(deviceValue, queue, currentDevices)
isInQueue = false;

if deviceValue==7
    x=1; %debug statement, remove later
end

for i=1:length(currentDevices)
    if deviceValue == currentDevices{i}
        isInQueue = true;
        return;
    end
end

for i=1:length(queue)
    q = queue{i};
    for j=1:length(q)
        if deviceValue == q{j}
            isInQueue = true;
            return;
           
        end
    end
    
end

end
