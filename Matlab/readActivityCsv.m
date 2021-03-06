%% For reading the csv file into a cell array
function [csvData] = readActivityCsv(path) 

csvF = fopen(path,'r');

csvData = cell(0,5);

line = fgetl(csvF);%first line is explaining the format
line = fgetl(csvF);%so ignore that first line

while (ischar(line))
    
    lineCell = cell(1,5);
    commas = strfind(line, ',');
    lineCell{1} = fixDate(line(1:commas(1)-1)); %date
    lineCell{2} = fixTime(line(commas(1)+1:commas(2)-1)); %start time
    lineCell{3} = fixTime(line(commas(2)+1:commas(3)-1)); %end time
    lineCell{4} = line(commas(3)+1:commas(4)-1); %activity label
    lineCell{5} = line(commas(4)+1:end); %context label
    
    csvData(end+1,:) = lineCell;
    
    line = fgetl(csvF); %next line

end

fclose(csvF);

end

%fix the date since it does not include as many zeros as the formatting
%from Android
function [fixedDate] = fixDate(date) 

date(end-3:end-2)='';

if strcmp(date(2),'/')
    date = ['0',date];
end

if strcmp(date(5),'/')
    date = [date(1:3), '0', date(4:end)];
end

% date(3) = '/';

fixedDate = date;
% fixedDate(end-3:end-2)='';

disp(fixedDate)
end

%fix the timestamp in case something was left off by excel formatting
%(usually an extra zero)
function [fixedTime] = fixTime(time)

if length(time) == 4
   time = ['0',time];
end

fixedTime = [time, ':00'];

end
