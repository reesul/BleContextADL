
function [feat] = ImuFeatExtract(data, time, winTimeStr)
% Extract features from one type of IMU data (accelerometer OR gyroscope)
% provide the data, the times associated with each sample, and the string 
% representation of the start times of each window


% also operate on the magnitude of the 3 axes
magData = sqrt(data(:,1).^2+ data(:,2).^2+ data(:,3).^2);
data = [data, magData];

num_windows = length(winTimeStr)-2;

% intialize output matrices
% feat is features
feat = zeros(num_windows, 4*10); %num axes * num features

%% Get windows of data to extract features from
window_index = zeros(1,length(winTimeStr));
for i=1:length(window_index)
    time_val = date2num(winTimeStr{i});
%     This time may be exactly in the data, so do a search and use the
%     closest index
    window_index(i) = binsearch(time_val, time);
    
end
    
%% Extract features
for w=1:num_windows
%     create individual (sliding, 50% overlap) window matrix, each 10 minutes long 
%     (or 2*window time)
    window_time = time(window_index(w):window_index(w+2));
    window = data(window_index(w):window_index(w+2),:);
    
    
%     get features, listed:
%     mean, std, rms, zero cross, variance, integration, skewness, 
%     3 first order of fft (3 features)
%     features created for every axis
    avg = mean(window,1);
    st_dev = std(window,1);
    root_mean = rms(window,1);
    mean_cross_rate = MCR(window);
    variance = var(window);
    integral = trapz(window_time, window,1);
    skew = skewness(window);
    ff = fft(window);
    ff = ff(1:3,:);
    ff = ff(:)';
    
    
%     put into the feature vector
    feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance, ...
        integral, skew, ff];
    
    
end

end