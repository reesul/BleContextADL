%% Finds the window indices for the timestampes provided. These timestamps MUST all be sequential.
% If this is failing, look at your data files to make sure there is no carryover 
%   from another day(e.g. few minutes of data collected before midnight saved into the wrong folder) 
function [startInd, endInd] = windowIndices(recordTimes, times, windowSize)

%% initalize variables
numWindows = length(recordTimes);
startInd = zeros(1,numWindows);
endInd = zeros(1,numWindows);
timeInd = 1; %index counting where we are within the times-series data from the sensor
w=1; %window counter
endTimes = recordTimes + windowSize;
emptyWindows = [];

%% get the first window separately
% dataStartWindowDone = true;
while true
    
%     if timeInd > length(times) || w > length(recordTimes) %for debugging
%        timeInd, recordTimes 
%     end
    
    if (times(timeInd) < recordTimes(w))
%          disp('data starts before first record; move on');
         break;
        
    elseif (times(1) > recordTimes(w) && times(1) < endTimes(w))
        while ~( (times(timeInd) <= endTimes(w)) && times(timeInd+1) > endTimes(w) ) %keep iterating until consecutive timestamps are found before and after expected end
            timeInd = timeInd+1;  
        end
        startInd(w) = 1;
        endInd(w) = timeInd;
        timeInd = timeInd+1;
        w = w+1;
%         disp('data starts in middle of the window');
        break;
        
    else
        % This will be hit continuously if there is data from a previous
        % day carried over into current day's file
%         disp('record has no data to associate with it!'); 
        startInd(w) = -1; endInd(w) = -1; %may need to fix this!
        emptyWindows = [emptyWindows, w];
        w=w+1;
        continue;
    end
   
end    
    
%% get the remaining windows

for w=w:numWindows
    % get the start index for this window first
%    disp(w);
   while ~( (times(timeInd) < recordTimes(w)) && times(timeInd+1) >= recordTimes(w) ) %iterate until timestamps found for just before and just after expected window end
            timeInd = timeInd+1;
            if (times(timeInd) > endTimes(w))
%                disp('overshot; no acc data in this window')
               startInd(w) = -1; endInd(w) = -1; emptyWindows = [emptyWindows, w];
               break;
            end
   end
   
   %In some case, above while loop may exit but there is still an overshoot
   %occurring

    
   if (startInd(w)==-1) %ignore subsequent operations for this w if no data i this window
       continue;
   end
   
   timeInd = timeInd+1;
   startInd(w) = timeInd;
   
   if (times(timeInd) > endTimes(w))
%        disp('overshot; no acc data in this window')
       startInd(w) = -1; endInd(w) = -1; emptyWindows = [emptyWindows, w];
       continue;
   end
   
%    if times(end) < endTimes(w)
%       disp('last data point is within this window')
%    end
   
   % then get the end index for this window
    while ~( (times(timeInd) <= endTimes(w)) && times(timeInd+1) > endTimes(w) )
        timeInd = timeInd+1;
    end
    %end at the datapoint just before this
    endInd(w)  = timeInd;
    timeInd = timeInd+1;
    
    if (times(startInd(w)) < recordTimes(w) || times(endInd(w)) > endTimes(w))
%        disp('samples exist outside of window!')
       disp(w);
    end
       
end    
    
% %% get last window    
% startInd
% endInd
% disp('last window')
end