function [feat] = ImuFeatures(data, time, recordTimes, windowSize)
% Extract features from one type of IMU data (accelerometer OR gyroscope)
% provide the data, the times associated with each sample, and the string 
% representation of the start times of each window


% also operate on the magnitude of the 3 axes
magData = sqrt(data(:,1).^2+ data(:,2).^2+ data(:,3).^2);
data = [data, magData];

numWindows = length(recordTimes);
endTimes = recordTimes + windowSize;

% intialize output matrices
% feat is features
feat = zeros(numWindows, 4*9); %num axes * num features + misc

%% Get indices for windows of data to extract features from
[windowStartInd, windowEndInd] = windowIndices(recordTimes, time, windowSize);

    
%% Extract features
for w=1:numWindows
    if windowStartInd(w)==-1 || windowEndInd(w)==-1
        feat(w,:) = -inf*ones(size(feat(w,:)));
        continue;
    end

%     window_time = time(windowStartInd(w):windowEndInd(w));
    window = data(windowStartInd(w):windowEndInd(w),:);
    feat(w,:) = imuFeatureWindow(window)

    
end

end