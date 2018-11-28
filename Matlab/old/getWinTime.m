function [winTime, winIndex] = getWinTime(aTime, aTimeStr, gTime, gTimeStr, windowLength)
%Function to get the start time (date) of each window to use for IMU data
%Ideal to use the same window times for both modalities, so use the window
%times that results in a longer (length) feature set i.e. more windows
%window length is in ms. 
%
%IMU data is the most comprehensive/consistent, so these window times can
%be applied to all modalities so that windows are synchronized
%
%input time data for acc and gyro data, as well as length of desired
%windows in milliseconds

%initialize windows for setting up windows
t_w_s = 1; %time window start variable
t_w_e = 2; %time window end
window_size = windowLength; 
window_index = [1];

%% Window start times based on accelerometer timing
for t=1:length(aTime)
    %if timing passes 5 minute window, then we have end of that window,
    %move to next one
    if (aTime(t) - aTime(t_w_s) >= window_size)
        window_index=[window_index, t-1];
%         if(t-t_w_s > max_window_length)
%             max_window_length = t-t_w_s;
%         end
        t_w_s = t;
    end
    
end

numWindowsA = length(window_index)-2;
window_indexA = window_index;

%% Window start times based on accelerometer timing
%reset variables
t_w_s = 1; %time window start
t_w_e = 2; %time window end
window_size = windowLength;
window_index = [1];
for t=1:length(gTime)
    %if timing passes 5 minute window, then we have end of that window,
    %move to next one
    if (gTime(t) - gTime(t_w_s) >= window_size)
        window_index=[window_index, t-1];
%         if(t-t_w_s > max_window_length)
%             max_window_length = t-t_w_s;
%         end
        t_w_s = t;
    end
    
end

numWindowsG = length(window_index)-2;
window_indexG = window_index;

%% Choose which set of windows to use (ACC or GYRO)
%if we have more potential windows from ACC, use ACC's window times
if (numWindowsA >= numWindowsG)
    winTime = aTimeStr(window_indexA);
    winIndex = window_indexA;
else
    winTime = gTimeStr(window_indexG);
    winIndex = window_indexG;
    
end
    
    