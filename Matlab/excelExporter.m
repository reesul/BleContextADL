function excelExporter(csvDir, matDir, alpha, beta, threshold, saveDir)

if nargin == 5   % if the number of inputs equals 4 (didn't specify saveDir)
  saveDir = pwd; % then make this pwd; returns the path to the current folder.
end

disp('loading files');

% csvData = ReadActivityCSV(csvDir);
csvData = readActivityCsv();
mat = load(matDir);

ap = mat.apResults{alpha, beta};
apGoodRecordSet = ap{1, 1};
apRecordRepresentatives = ap{1, 2};
goodRecordSet = mat.goodRecordSet;
recordSet = mat.recordSet;
[clusterSize, ~] = size(apGoodRecordSet);
clusterNumber = [1:clusterSize]';

saveExportLabelMap(apGoodRecordSet, goodRecordSet, clusterSize, csvData, saveDir);

saveExportLabelMatch(apGoodRecordSet, goodRecordSet, clusterSize, csvData, saveDir);


end

function saveExportLabelMap(apGoodRecordSet, goodRecordSet, clusterSize, csvData, saveDir)
disp('Saving exportLabelMap');
labels = cellstr(csvData(:, 5));
uniqueLabels = unique(labels);
[sz, ~] = size(uniqueLabels);

T = table(uniqueLabels);

for rr = 1:clusterSize
    gRecIdx = apGoodRecordSet{rr};
    
    col = [];
    for ii = gRecIdx
        logDate = goodRecordSet{1, ii};
        timeNum = goodRecordSet{2, ii};
        
        [~, locGR] = getLabel(csvData, logDate, timeNum);
        
        TF = strcmp('null', locGR);
        if ~TF
            idx = find(strcmp(uniqueLabels, locGR));
            col = [col; idx];
        end
    end
    colData = zeros(sz, 1);
    for jjj = 1:sz
        if any(col == jjj)
            colData(jjj) = 1;
        end
    end
    T2 = table(colData);
    T2.Properties.VariableNames = {sprintf('C%d', rr)};
    T = [T T2];
end

savePath = getFullPath(saveDir, 'exportLabelMap.xlsx');
writetable(T, savePath);

end

function saveExportLabelMatch(apGoodRecordSet, goodRecordSet, clusterSize, csvData, saveDir)
disp('Saving exportLabelMatch');

Time = {};
goodRecIdx = {};
LabelFromGoodRec = {};
Activities = {};

for rr = 1:clusterSize
    gRecIdx = apGoodRecordSet{rr};
    timeStamps = '';
    locDataFromGoodRec = '';
    actString = '';
    for ii = gRecIdx
        logDate = goodRecordSet{1, ii};
        timeNum = goodRecordSet{2, ii};
        logTime = num2date(timeNum);
        
        [act, locGR] = getLabel(csvData, logDate, timeNum);
        locDataFromGoodRec = sprintf('%s, %s (%d)', locDataFromGoodRec, locGR, ii);
        actString = sprintf('%s, %s (%d)', actString, act, ii);
        tail = sprintf('%s-%s', logDate, logTime);
        timeStamps = sprintf('%s, %s', timeStamps, tail);
    end
    timeStamps = timeStamps(3:end);
    locDataFromGoodRec = locDataFromGoodRec(3:end);
    actString = actString(3:end);
    strIdx = sprintf('%d, ', gRecIdx);
    strIdx = strIdx(1:end - 2);
    
    Time{end + 1} = timeStamps;
    goodRecIdx{end + 1} = strIdx;
    LabelFromGoodRec{end + 1} = locDataFromGoodRec;
    Activities{end + 1} = actString;
end

clusterNumber = [1:clusterSize]';
Time = Time';
goodRecIdx = goodRecIdx';
LabelFromGoodRec = LabelFromGoodRec';
Activities = Activities';

T = table(clusterNumber, Time, goodRecIdx, LabelFromGoodRec, Activities);
savePath = getFullPath(saveDir, 'exportLabelMatch.xlsx');
writetable(T, savePath);
end


function [savePath] = getFullPath(saveDir, filename)
savePath = sprintf('%s\\%s', saveDir, filename);
end

%this is for reading the csv file into a cell array
function [csvData] = ReadActivityCSV(csvDir)
csvF = fopen(csvDir,'r');

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

% disp(fixedDate)
end

function [fixedTime] = fixTime(time)

if length(time) == 4
   time = ['0',time];
end

fixedTime = [time, ':00'];

end
