%this is for reading the csv file into a cell array
function [csvData] = readActivityCsv() 


csvF = fopen('activityLabels.csv','r');

csvData = cell(0,5);

line = fgetl(csvF);%first line is explaining the format
line = fgetl(csvF);

while (ischar(line))
    
    lineCell = cell(1,5);
    commas = strfind(line, ',');
    lineCell{1} = fixDate(line(1:commas(1)-1));
    lineCell{2} = fixTime(line(commas(1)+1:commas(2)-1));
    lineCell{3} = fixTime(line(commas(2)+1:commas(3)-1));
    lineCell{4} = line(commas(3)+1:commas(4)-1);
    lineCell{5} = line(commas(4)+1:end);
    
    csvData(end+1,:) = lineCell;
    
    line = fgetl(csvF);

end

end


function [fixedDate] = fixDate(date) 

if strcmp(date(2),'-')
    date = ['0',date];
end

if length(date) == 4
    date = [date(1:3), '0', date(4:end)];
end

date(3) = '/';

fixedDate = date;
fixedDate(end-3:end-2)='';

disp(fixedDate)
end

function [fixedTime] = fixTime(time)

if length(time) == 4
   time = ['0',time];
end

fixedTime = [time, ':00'];

end
