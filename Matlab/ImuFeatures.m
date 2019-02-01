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
    
%     get features, listed:
%     mean, std, rms, zero cross, variance, integration, skewness, 
%     3 first order of fft (3 features)
%     features created for every axis
    avg = mean(window,1);
    st_dev = std(window,1);
    root_mean = rms(window,1);
    mean_cross_rate = MCR(window);
    variance = var(window);
    
    Fs = 20; %sampled at about 20 hz
    N=2000; %
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(2:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd); %this will be N/2
    
    %Take bins for 0-1 Hz (ignoring DC component, so 0+), 1-2, 2-5, and 5-10 
    bin_0_1 = mean(psd(1:round(pLen/10),:),1);
    bin_1_2 = mean(psd(round(pLen/10)+1:round(pLen/5),:),1);
    bin_2_5 = mean(psd(round(pLen/5)+1:round(pLen/2),:),1);
    bin_5_10 = mean(psd(round(pLen/2)+1:end,:),1);
    
%     integral = trapz(window_time, window,1);
%     skew = skewness(window);
%     ff = fft(window);
%     ff = ff(1:3,:);
%     ff = ff(:)';
    
    
%     put into the feature vector
%     feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance, ...
%         integral, skew, ff];
     feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance, bin_0_1, bin_1_2, bin_2_5, bin_5_10];
    
end

end