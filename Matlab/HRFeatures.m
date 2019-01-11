function [feat] = HRFeatures(data, time, recordTimes, windowSize)
%Extract features from HR
%provide the data, the times associated with each sample, and the string 
%representation of the start times of each window

numWindows = length(recordTimes);
endTimes = recordTimes + windowSize;
   
%feat is features
feat = zeros(numWindows, 5);

%% Get indices for windows of data to extract features from
[windowStartInd, windowEndInd] = windowIndices(recordTimes, time, windowSize);
    
%% Extract features
for w=1:numWindows
    if windowStartInd(w)==-1 || windowEndInd(w)==-1
        feat(w,:) = -inf*ones(size(feat(w,:)));
        continue;
    end

    window_time = time(windowStartInd(w):windowEndInd(w));
    window = data(windowStartInd(w):windowEndInd(w),:);
    
    
    %get features, listed:
    %mean, std, rms, mean cross rate, variance, integration, skewness, 
    %features created for every axis
    avg = mean(window,1);
    st_dev = std(window,1);
    root_mean = rms(window,1);
    mean_cross_rate = MCR(window);
    variance = var(window);
%     integral = trapz(window_time, window,1);
%     skew = skewness(window);
    
    
    %put into the feature vector
%     feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance, ...
%         integral, skew];
     feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance];
    
end

end