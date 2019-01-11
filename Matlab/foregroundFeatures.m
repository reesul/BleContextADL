function [accFeatures, gyroFeatures, heartrateFeatures] = foregroundFeatures(records, datapath, windowSize)

accfile = 'accelerometer_data.txt';
gyrofile = 'gyroscope_data.txt';
hrfile = 'ppg_data.txt';
dataDirs = ls(datapath);

accFeatures =[];
gyroFeatures =[]; 
heartrateFeatures =[];

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
        lastR = r;
        while strcmp(records{1,lastR}, date)
           lastR = lastR+1; 
        end
        lastR = lastR-1;
    end
    
    %get features for this day of data, windows aligned to records
    datePath = [datapath,  dataDirs(d,:), '\'];
    [aFeat, gFeat, hrFeat] = dayOfData(records(:,r:lastR), datePath, windowSize);
    accFeatures = [accFeatures; aFeat];
    gyroFeatures = [gyroFeatures; gFeat];
    heartrateFeatures = [heartrateFeatures; hrFeat];
%     [~, ~, ~] = dayOfData(records(:,r:lastR), datePath, windowSize);
    records(:,r:lastR)
    r=lastR+1; %todo make sure this work with the last date as well
    
end



end

function [aFeat, gFeat, hrFeat] = dayOfData(records, basepath, windowSize)
    accfile = 'accelerometer_data.txt';
    gyrofile = 'gyroscope_data.txt';
    hrfile = 'ppg_data.txt';
    
    recordTimes = cell2mat(records(2,:));
    
    %parse data from files
    [gdata, gtime, gtimeStr] = getRawIMU(strcat(basepath,gyrofile));
    [adata, atime, atimeStr] = getRawIMU(strcat(basepath,accfile));
    [hrdata, hrtime, hrtimeStr] = getRawHR(strcat(basepath,hrfile));
    
    
    
    aFeat = ImuFeatures(adata, atime, recordTimes, windowSize);
    gFeat = ImuFeatures(gdata, gtime, recordTimes, windowSize);
    hrFeat = HRFeatures(hrdata, hrtime, recordTimes, windowSize);
    
end