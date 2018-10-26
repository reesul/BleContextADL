function [gfeat, afeat, hrfeat, timefeat, blefeat] = ProcessData(datapath)
%% 
% Function is top level for doing all feature extraction on a day's worth
% of data.
%   'datapath' variable should be absolute path to the directory containing
%   a day's worth of data, and assumes the path ends with the appropriate
%   slash ('\' for windows, '/' for Linux)

%% File name information. CHANGE BASE PATH TO REFLECT DATA TO BE PROCESSED
scripts = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\Processing';
cd(scripts);
%datapath = 'C:\Users\reesul\Documents\Nearables\server\Data\Apr 11, 2018\04-09-18\';
accfile = 'accelerometer_data.txt';
gyrofile = 'gyroscope_data.txt';
hrfile = 'ppg_data.txt';
blefile = 'ble_data.txt';

%% get raw data from files
[gdata, gtime, gtimeStr] = getRawIMU(strcat(datapath,gyrofile));
[adata, atime, atimeStr] = getRawIMU(strcat(datapath,accfile));
[hrdata, hrtime, hrtimeStr] = getRawHR(strcat(datapath,hrfile));
[bleData, bleTime] = formatBleData(strcat(datapath, blefile));

%% feature window
windowSize = 5*60*1000; %window size in milliseconds
[winTime, winIndex] = getWinTime(atime, atimeStr, gtime, gtimeStr, windowSize);

%% extract statistical/straightforward features

[gfeat] = ImuFeatExtract(gdata, gtime, winTime);
[afeat] = ImuFeatExtract(adata, atime, winTime);
[hrfeat] = HRFeatExtract(hrdata, hrtime, winTime);
[timefeat] = timeFeatExtract(winTime);

%% extract ble features
 [blefeat] = knownBeaconFeat(bleData, bleTime, winTime);

%% Write a CSV file containing all features and the window times..
%   assign labels to data in CSV file, and probably delete window times
%   column.
outputFile = strsplit(datapath,'\');
outputFile = string(outputFile(end-1));
outputFile = strcat(outputFile,'.csv');
outputFile = strcat(strcat(datapath,'..\Processed\'), outputFile);

writeFeatCSV_v2([afeat, gfeat, hrfeat, timefeat, blefeat], winTime, outputFile);

end