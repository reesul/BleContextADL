function [feat] = HRFeatExtract(data, time, winTimeStr)
%Extract features from HR
%provide the data, the times associated with each sample, and the string 
%representation of the start times of each window

num_windows = length(winTimeStr)-2;
   
%feat is features
feat = zeros(num_windows, 7);

%% Get windows of data to extract features from
window_index = zeros(1,length(winTimeStr));
for i=1:length(window_index)
    time_val = date2num(winTimeStr{i});
    %This time may be exactly in the data, so do a search and use the
    %closest index
    window_index(i) = binsearch(time_val, time);
    
end
    
for w=1:num_windows
    %create individual (sliding, 50% overlap) window matrix
    window_time = time(window_index(w):window_index(w+2));
    window = data(window_index(w):window_index(w+2),:);
    
    
    %get features, listed:
    %mean, std, rms, mean cross rate, variance, integration, skewness, 
    %features created for every axis
    avg = mean(window,1);
    st_dev = std(window,1);
    root_mean = rms(window,1);
    mean_cross_rate = MCR(window);
    variance = var(window);
    integral = trapz(window_time, window,1);
    skew = skewness(window);
    
    
    %put into the feature vector
    feat(w,:) = [avg, st_dev, root_mean, mean_cross_rate, variance, ...
        integral, skew];
    
    
end

end