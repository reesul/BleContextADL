function [features] = visualizeIMU(records, rawSensorData, windowSize, activitiesToShow)

features = [];
for i=1:size(rawSensorData,3)
    
   dayOfRawData = rawSensorData(:,:,i);
   r = dayOfRawData{4,1};
   lastR = dayOfRawData{4,2};
   
   features = [features; dayOfData(dayOfRawData, records(:,r:lastR), windowSize, activitiesToShow)];
   
    
end
% r=1; %counter for the records
% while r<=size(records,2)
%     %get the date of data to process from the record set; find which
%     %directory to look for IMU, HR data-files
%     date = records{1,r};
%     dashDate = strrep(date, '/', '-');
%     for d=1:size(dataDirs,1)
%        if strcmp(dashDate, dataDirs(d,:))
%           break;  
%        end
%     end
%  
%     %get the set of records to use as a starting point for other feature
%     %windows
%     if d==size(dataDirs,1)
%         lastR = size(records,2);
%     else
%         lastR = r;
%         while strcmp(records{1,lastR}, date)
%            lastR = lastR+1; 
%         end
%         lastR = lastR-1; %correct for overstepping
%     end
%     
%     %get features for this day of data, windows aligned to records
%     datePath = [datapath,  dataDirs(d,:), '\'];
%     dayOfData(datePath, records(:,r:lastR), windowSize, activitiesToShow);
%     
%     
% %     [~, ~, ~] = dayOfData(records(:,r:lastR), datePath, windowSize);
% %     records(:,r:lastR)
%     r=lastR+1; %todo make sure this work with the last date as well
%     
% end


end

% function [gdata, gtime, adata, atime] = dayOfData(path, records, windowSize, activitiesToShow)
% 
%     accfile = 'accelerometer_data.txt';
%     gyrofile = 'gyroscope_data.txt';    
%     
%     %parse data from files
%     [gdata, gtime, ~] = getRawIMU(strcat(path,gyrofile));
%     [adata, atime, ~] = getRawIMU(strcat(path,accfile));
%     
%     %include magnitude of the signals
%     gmagData = sqrt(gdata(:,1).^2+ gdata(:,2).^2+ gdata(:,3).^2);
%     gdata = [gdata, gmagData];
%     amagData = sqrt(adata(:,1).^2+ adata(:,2).^2+ adata(:,3).^2);
%     adata = [adata, amagData];
%     
%     %use record times to get windows of gdata, adata
%     recordTimes = cell2mat(records(2,:));
%     numWindows = length(recordTimes);
%     
%     [gwindowStartInd, gwindowEndInd] = windowIndices(recordTimes, gtime, windowSize);
%     [awindowStartInd, awindowEndInd] = windowIndices(recordTimes, atime, windowSize);
%     
%     for w=1:numWindows
%         
%         if any(strcmp(activitiesToShow, records(end-1,w)))
%             
%         
%             if gwindowStartInd(w)==-1 || gwindowEndInd(w)==-1
%                 continue;
%             elseif awindowStartInd(w)==-1 || awindowEndInd(w)==-1
%                 continue;
%             end
% 
%             gwindow = gdata(gwindowStartInd(w):gwindowEndInd(w),:);
%             awindow = adata(awindowStartInd(w):awindowEndInd(w),:);
% 
%             plotIMU(gwindow, awindow, records(end-1,w), recordTimes(w));
%         end
%     
%     end
%     
%     
% end

function [afeat, gfeat, gdata, gtime, adata, atime] = dayOfData(sensorData, records, windowSize, activitiesToShow)

    gdata = sensorData{1,1};
    gtime = sensorData{1,2};
    adata = sensorData{2,1};
    atime = sensorData{2,2};
    
    %include magnitude of the signals
    gmagData = sqrt(gdata(:,1).^2+ gdata(:,2).^2+ gdata(:,3).^2);
    gdata = [gdata, gmagData];
    amagData = sqrt(adata(:,1).^2+ adata(:,2).^2+ adata(:,3).^2);
    adata = [adata, amagData];
    
    %use record times to get windows of gdata, adata
    recordTimes = cell2mat(records(2,:));
    numWindows = length(recordTimes);
    
    afeat = zeros(numWindows, length(imuFeatureWindow([], true)));
    gfeat = zeros(numWindows, length(imuFeatureWindow([], false)));
    
    [gwindowStartInd, gwindowEndInd] = windowIndices(recordTimes, gtime, windowSize);
    [awindowStartInd, awindowEndInd] = windowIndices(recordTimes, atime, windowSize);
    
    for w=1:numWindows

        if (gwindowStartInd(w)==-1 || gwindowEndInd(w)==-1) || (awindowStartInd(w)==-1 || awindowEndInd(w)==-1)
            gfeat(w,:) = imuFeatureWindow([], false);
            afeat(w,:) = imuFeatureWindow([], true);
%             features = [features; f];
            continue;
        end

        gwindow = gdata(gwindowStartInd(w):gwindowEndInd(w),:);
        awindow = adata(awindowStartInd(w):awindowEndInd(w),:);
        
        gfeat(w,:) = imuFeatureWindow(gwindow, false);
        afeat(w,:) = imuFeatureWindow(awindow, true);
        
        if any(strcmp(activitiesToShow, records(end-1,w)))
            plotIMU(gwindow, awindow, records(end-1,w), recordTimes(w));
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


    pause;
end

function [psd, freq] = getPSD(window)

    ignoreInd = 20;

    Fs = 10; %sampled at about 20 hz
    N=2000; %
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(ignoreInd+1:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd); %this will be N/2
    
    freq = Fs/N*ignoreInd : Fs/N : Fs/2;
    
    

end
