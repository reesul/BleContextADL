function [features, timeInfo, dataWindows] = processIMU(records, rawSensorData, windowSize, activitiesToShow)

features = [];
dataWindows = cell(0,1);
timeInfo = {};
for i=1:size(rawSensorData,3)
   
    i
    
    
   dayOfRawData = rawSensorData(:,:,i);
   r = dayOfRawData{4,1};
   lastR = dayOfRawData{4,2};
   
   [afeat, gfeat, awindowStartTime, gwindowStartTime, awindowEndTime, gwindowEndTime, recordTimeStr, awindows, gwindows] = dayOfData(dayOfRawData, records(:,r:lastR), windowSize, activitiesToShow);
   features = [features; [afeat, gfeat]];
   timeInfo = [timeInfo; [recordTimeStr, awindowStartTime, gwindowStartTime, awindowEndTime, gwindowEndTime] ];
   dataWindows = [dataWindows; [awindows, gwindows]];
   
end


end



function [afeat, gfeat, awindowStartTime, gwindowStartTime, awindowEndTime, gwindowEndTime, recordTimeStr, aWindows, gWindows] = dayOfData(sensorData, records, windowSize, activitiesToShow)

    gdata = sensorData{1,1};
    gtime = sensorData{1,2};
    gtimeStr = sensorData{1,3};
    adata = sensorData{2,1};
    atime = sensorData{2,2};
    atimeStr = sensorData{2,3};
    
    %include magnitude of the signals
    gmagData = sqrt(gdata(:,1).^2+ gdata(:,2).^2+ gdata(:,3).^2);
    gdata = [gdata, gmagData];
    amagData = sqrt(adata(:,1).^2+ adata(:,2).^2+ adata(:,3).^2);
    adata = [adata, amagData];
    
    %use record times to get windows of gdata, adata
    recordTimes = cell2mat(records(2,:));
    numWindows = length(recordTimes);
    aWindows = cell(length(recordTimes),1);
    gWindows = cell(length(recordTimes),1);
    
    afeat = zeros(numWindows, length(imuFeatureWindow([], true)));
    gfeat = zeros(numWindows, length(imuFeatureWindow([], false)));
    
    [gwindowStartInd, gwindowEndInd] = windowIndices(recordTimes, gtime, windowSize);
    [awindowStartInd, awindowEndInd] = windowIndices(recordTimes, atime, windowSize);
    
%     gwindowStartTime = gtime(gwindowStartInd);
%     gwindowEndTime = gtime(gwindowEndInd);
%     awindowStartTime = atime(awindowStartInd);
%     awindowEndTime = atime(awindowEndInd);
    gwindowStartTime = cell(length(recordTimes),1);
    gwindowEndTime = cell(length(recordTimes), 1);
    awindowStartTime = cell(length(recordTimes), 1);
    awindowEndTime = cell(length(recordTimes), 1);
    recordTimeStr = cell(length(recordTimes), 1);
    
    for w=1:numWindows
        recordTimeStr{w} = num2date(recordTimes(w));

        if (gwindowStartInd(w)==-1 || gwindowEndInd(w)==-1) || (awindowStartInd(w)==-1 || awindowEndInd(w)==-1)
            gfeat(w,:) = imuFeatureWindow([], false);
            afeat(w,:) = imuFeatureWindow([], true);
            gwindowStartTime{w} = num2date(0);
            gwindowEndTime{w} = num2date(0);
            awindowStartTime{w} = num2date(0);
            awindowEndTime{w} = num2date(0);
            aWindows{w} = [];
            gWindows{w} = [];
%             features = [features; f];
            continue;
        end

        % get a window of data
        gwindow = gdata(gwindowStartInd(w):gwindowEndInd(w),:);
        awindow = adata(awindowStartInd(w):awindowEndInd(w),:);
        
        gwindowStartTime{w} = num2date(gtime(gwindowStartInd(w)));
        gwindowEndTime{w} = num2date(gtime(gwindowEndInd(w)));
        awindowStartTime{w} = num2date(atime(awindowStartInd(w)));
        awindowEndTime{w} = num2date(atime(awindowEndInd(w)));
        
        gfeat(w,:) = imuFeatureWindow(gwindow, false);
        afeat(w,:) = imuFeatureWindow(awindow, true);
        
        aWindows{w} = awindow;
        gWindows{w} = gwindow;
        
        if any(strcmp(activitiesToShow, records(end-1,w)))
            plotIMU(gwindow, awindow, records(end-1,w), recordTimes(w));
            pause;
        end
    
    end
    
    
end

% plot a single window of data
function [] = plotIMU(gdata, adata, label, recordTime)
    
    metadata = [label{1}, ' @ ', num2date(recordTime)];
    disp(metadata)
    Fs = 20; %sampling frequency

    [apsd, afreq] = getPSD(adata);
    [gpsd, gfreq] = getPSD(gdata);
    apsd = apsd(1:length(afreq),:);
    gpsd = gpsd(1:length(gfreq),:);

    figure(1)
    subplot(4,2,1)
    plot(adata(:,1));
    title('ACC X');
    xlabel('time')
    subplot(4,2,2)
    plot(adata(:,2));
    title('ACC Y');
    xlabel('time')
    subplot(4,2,5)
    plot(adata(:,3));
    title('ACC Z');
    xlabel('time')
    subplot(4,2,6)
    plot(adata(:,4));
    title('Magnitude of ACC');
    xlabel('time')

    subplot(4,2,3)
    plot(gdata(:,1));
    title('GYRO X');
    xlabel('time')
    subplot(4,2,4)
    plot(gdata(:,2));
    xlabel('time')
    subplot(4,2,7)
    plot(gdata(:,3));
    title('GYRO Z');
    xlabel('time')
    subplot(4,2,8)
    plot(gdata(:,4));
    title('Magnitude of GYRO');
    xlabel('time')
    
    figure(2)
    
    subplot(4,2,1)
    plot(afreq, apsd(:,1));
    title('ACC X');
    xlabel('frequency')
    subplot(4,2,2)
    plot(afreq, apsd(:,2));
    title('ACC Y');
    xlabel('frequency')
    subplot(4,2,5)
    plot(afreq, apsd(:,3));
    title('ACC Z');
    xlabel('frequency')
    subplot(4,2,6)
    plot(afreq, apsd(:,4));
    title('Magnitude of ACC');
    xlabel('frequency')

    subplot(4,2,3)
    plot(gfreq, gpsd(:,1));
    title('GYRO X');
    xlabel('frequency')
    subplot(4,2,4)
    plot(gfreq, gpsd(:,2));
    title('GYRO Y');
    xlabel('frequency')
    subplot(4,2,7)
    plot(gfreq, gpsd(:,3));
    title('GYRO Z');
    xlabel('frequency')
    subplot(4,2,8)
    plot(gfreq, gpsd(:,4));
    title('Magnitude of GYRO');
    xlabel('frequency')


    
end

function [psd, freq] = getPSD(window)

    ignoreInd = 20;

    Fs = 20; %sampled at about 20 hz
    N=2000; %
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(ignoreInd+1:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd); %this will be N/2
    
    freq = Fs/N*ignoreInd : Fs/N : Fs/(2*2); %only show up to 5Hz, because 5-10 has virtually no information
    
    

end
