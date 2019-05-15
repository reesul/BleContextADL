function [features, timeInfo] = processHR(records, rawSensorData, windowSize)

features = [];
timeInfo = {};
for i=1:size(rawSensorData,3)
    
   dayOfRawData = rawSensorData(:,:,i);
   r = dayOfRawData{4,1};
   lastR = dayOfRawData{4,2};
   
   %only process a single day's worth of data at a time, and concatenate to
   %what was already processed
   [hrfeat, windowStartTime, windowEndTime, recordTimeStr] = dayOfData(dayOfRawData, records(:,r:lastR), windowSize);
   features = [features; hrfeat];
   timeInfo = [timeInfo; [recordTimeStr, windowStartTime, windowEndTime] ];
   
end


end


function [hrfeat, windowStartTime, windowEndTime, recordTimeStr] = dayOfData(dayOfRawData, records, windowSize);
  
hrdata = dayOfRawData{3,1};
hrtime = dayOfRawData{3,2};
% hrtimeStr = dayOfRawData{3,3};

%use record times to get windows of gdata, adata
recordTimes = cell2mat(records(2,:));
numWindows = length(recordTimes);

hrfeat = zeros(numWindows, length(hrFeatureWindow([])));

[windowStartInd, windowEndInd] = windowIndices(recordTimes, hrtime, windowSize);

    windowStartTime = cell(length(recordTimes), 1);
    windowEndTime = cell(length(recordTimes), 1);
    recordTimeStr = cell(length(recordTimes), 1);

    for w=1:numWindows
        recordTimeStr{w} = num2date(recordTimes(w));

        if (windowStartInd(w)==-1 || windowEndInd(w)==-1)
            hrfeat(w,:) = NaN;
            windowStartTime{w} = num2date(0);
            windowEndTime{w} = num2date(0);
%             features = [features; f];
            continue;
        end

        % get a window of data
        window = hrdata(windowStartInd(w):windowEndInd(w),:);
        
        windowStartTime{w} = num2date(hrtime(windowStartInd(w)));
        windowEndTime{w} = num2date(hrtime(windowEndInd(w)));
        
        hrfeat(w,:) = hrFeatureWindow(window);
            
    end
    
    
end

