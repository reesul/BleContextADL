function [activityLabel, locationLabel] = getLabel(csvData, date, timestamp)

activityLabel = 'null';
locationLabel = 'null';

%get the relevant days of data
cellInd = strcmp(csvData(:,1), date);
daysCells = csvData(cellInd,:);

%find out which cell is actually correct
for i = 1:length(daysCells)
    startTime = date2num([daysCells{i,1}, ' ', daysCells{i,2}]);
    stopTime = date2num([daysCells{i,1}, ' ', daysCells{i,3}]);
    
    if (timestamp > startTime) && (timestamp < stopTime)
        activityLabel = daysCells{i,4};
        locationLabel = daysCells{i,5};
    end
    

end


disp('getLabels done');
end