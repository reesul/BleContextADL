function feat = knownBeaconFeat(bleData, bleTime, winTime)
%extract features regarding known beacon devices
%pressence of a bluetooth device is binary, so a binary feature vector is used here
%bleData is the string of text corresponding to a single scan of a BLE
%device
%bleTime are the times of each scan (also present in bleData) held as
%integers
%winTime is the time marking the start of each window


%% Get data pertaining to the beacons we have prior knowledge on
[knownID, knownBleData, indices, numDevices] = knownBeacons(bleData);
knownTime = bleTime(indices);

%features are binary, with one feature for each known device (denotes
%presence of device during a window
feat = zeros(length(winTime)-2,numDevices);

%% Set up windows of BLE data
%To extract features, we need windows of data to process on. These windows
%should start with the indicies of arg 'winTime'

window_index = zeros(1,length(winTime));
window_index(1) = 1;

for i=2:length(window_index)
    time_val = date2num(winTime{i});
%     This time may not be exactly in the data, so do a search and use the
%     closest index
%     This window index should be the last instance of a particular time
    window_index(i) = searchBleTime(time_val, knownTime, window_index(i-1));
    
end

%%  Feature Extraction
%break up the data into a series of windows (50% overlap) to extract
%feature(s) from
%consider window to start 1 past the window_index, and go up to the 2nd
%subsequent window_index.. this should get ONLY the data that is supposed
%to be considered between the predefined window times (winTime)

%get first window separately
window = knownID(1:window_index(2));
feat(1,:) = getBleFeatKnown(window, numDevices);
for w=2:(length(window_index)-2)
    if(window_index(w)==window_index(w+2) ) %if true, then there are no known device scans within this window
        feat(w,:)=zeros(1,numDevices); %no known devices, so feature is all 0's
        continue;
        
    end
        
    %extract features from window
    window = knownID(window_index(w)+1:window_index(w+2),:);
    
    feat(w,:) = getBleFeatKnown(window,numDevices);
    

end


end