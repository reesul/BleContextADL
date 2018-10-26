function [feat] = timeFeatExtract(winTime, varargin)
%generates a small set of features based on the start time of each window
%optional second argument to explictily set size of a time interval (default
%is 30 minutes)

interval_size = 30; %interval in minutes

%if second arg provided, set interval size to this
if nargin>1
    interval_size = varargin{1};
    
end

feat = zeros(length(winTime)-2,2);

for i=1:(length(winTime)-2) %length-2 because last two window times are in the middle of a window, but are not used to start a window
    time = winTime{i};
%    first feature is time of day (using a 30 minute interval,  
%    so 00:00 - 00:30 is 0, 00:30 - 1:00 is 1, etc.
    t = date2num(time); %date2num converts time of day to ms
    t = t/(1000*60); %conversion to minutes
    feat(i,1) = floor(t/interval_size);
    
    
%     second feature is day of the week (sunday is 1, monday 2, ...
%     saturday 7
    date = time(1:8);
    feat(i,2) = weekday(datenum(date, 'mm/dd/yy'));
    
end




end