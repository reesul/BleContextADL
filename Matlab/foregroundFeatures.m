% function [accFeatures, gyroFeatures, heartrateFeatures, rawData] = foregroundFeatures(records, datapath, windowSize)
function [rawData] = foregroundFeatures(records, datapath, windowSize)

accfile = 'accelerometer_data.txt';
gyrofile = 'gyroscope_data.txt';
hrfile = 'ppg_data.txt';
dataDirs = ls(datapath);

accFeatures =[];
gyroFeatures =[]; 
heartrateFeatures =[];

rawData = cell(4,3,0); 

r=1; %counter for the records
while r<=size(records,2)
    %get the date of data to process from the record set; find which
    %directory to look for IMU, HR data-files
    date = records{1,r};
    dashDate = strrep(date, '/', '-');
    for d=1:size(dataDirs,1)
       if strcmp(dashDate, dataDirs(d,:))
          break;  
       end
    end
 
    %get the set of records to use as a starting point for other feature
    %windows
    if d==size(dataDirs,1)
        lastR = size(records,2);
    else
        lastR = r
        while lastR <= size(records,2) && strcmp(records{1,lastR}, date)
           lastR = lastR+1; 
        end
        lastR = lastR-1;
    end
    
    %get features for this day of data, windows aligned to records
    datePath = [datapath,  dataDirs(d,:), '\'];
    rawDaysData = dayOfData(records(:,r:lastR), datePath, windowSize);
%     accFeatures = [accFeatures; aFeat];
%     gyroFeatures = [gyroFeatures; gFeat];
%     heartrateFeatures = [heartrateFeatures; hrFeat];
%     [~, ~, ~] = dayOfData(records(:,r:lastR), datePath, windowSize);
%     records(:,r:lastR)
    
    
    rawData = appendData(rawData, rawDaysData, [r, lastR]);
    
    r=lastR+1; %todo make sure this work with the last date as well
    
end



end

% function [aFeat, gFeat, hrFeat, rawData] = dayOfData(records, basepath, windowSize)
function [rawData] = dayOfData(records, basepath, windowSize)
    accfile = 'accelerometer_data.txt';
    gyrofile = 'gyroscope_data.txt';
    hrfile = 'ppg_data.txt';
    
    recordTimes = cell2mat(records(2,:));
    
    %parse data from files
    [gdata, gtime, gtimeStr] = getRawIMU(strcat(basepath,gyrofile));
%     gFeat = ImuFeatures(gdata, gtime, recordTimes, windowSize);
    [adata, atime, atimeStr] = getRawIMU(strcat(basepath,accfile));
%     aFeat = ImuFeatures(adata, atime, recordTimes, windowSize);
    [hrdata, hrtime, hrtimeStr] = getRawHR(strcat(basepath,hrfile));
%     hrFeat = HRFeatures(hrdata, hrtime, recordTimes, windowSize);
    
    rawData = {gdata, gtime, gtimeStr; adata, atime, atimeStr; hrdata, hrtime, hrtimeStr};
    
end

function [rawData] = appendData(rawData, rawDaysData, recordInd)
%gyro
rawData(1,1,end+1) = rawDaysData(1,1);
rawData(1,2,end) = rawDaysData(1,2);
rawData(1,3,end) = rawDaysData(1,3);
%acc
rawData(2,1,end) = rawDaysData(2,1);
rawData(2,2,end) = rawDaysData(2,2);
rawData(2,3,end) = rawDaysData(2,3);
%hr
rawData(3,1,end) = rawDaysData(3,1);
rawData(3,2,end) = rawDaysData(3,2);
rawData(3,3,end) = rawDaysData(3,3);
%record indexes
rawData{4,1,end} = recordInd(1);
rawData{4,2,end} = recordInd(2);
end