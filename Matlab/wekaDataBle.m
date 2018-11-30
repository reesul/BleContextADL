function [] = wekaDataBle(records, labelName, rawLabels)

%remove the records that have null activity labels
nonNullRecordsInd = ~strcmp(rawLabels(1,:), 'null');
records = records(:,nonNullRecords);

recordMtx = records(3,:);
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(records{3,1}),size(records,2)]);
featureSet = recordMtx'; %transpose so a single record is a row; (index as i,:) for whole record i

numRecords = size(featureSet, 1);
numFeatures = size(featureSet,2);

wekaDataOut = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\Processing\Classification\';
arffFileName = [wekaDataOut,'bleFeat_', labelName, '.arff'];
%if .arff file is already there, just delete it so it doesn't show in files
if (fopen(arffFileName, 'r') ~= -1)
    fclose('all');
    delete(arffFileName);
    disp('Deleted existing arff file');
end

files = dir(wekaDataOut);

labelSet = binaryLabels(labelName, rawLabels(1,:)); %use 2 for rawLabels to use location labels rather than activity


fArff = fopen(arffFileName, 'w');

%first write the header of the .arff file, like relation and feature
%names

%names of the features
features = cell(1, numFeatures);
% features = {'mean', 'std', 'rms', 'mcr', 'var', 'int', 'skew', 'fft1', 'fft2', 'fft3'};

for i = 1:numFeatures
   
    features{i} = ['c', num2str(i)];
    
end

fprintf(fArff, '@relation context\n\n');

for i=1:numFeatures
    %instead of numeric, may be appropriate to just specify as {0,1} to use
    %nominal values
    fprintf(fArff, ['@attribute ', features{i}, ' numeric\n']); 
end



%class labels
fprintf(fArff, '@attribute activity {0,1}\n\n');


%now write the data section of the file

fprintf(fArff, '@data\n');

for i=1:numRecords
    for j=1:numFeatures
        s = sprintf('%f',featureSet(i,j));
        fprintf(fArff, [s, ',']);
        
    end
    fprintf(fArff, [int2str(labelSet(i)), '\n']);
end


fclose(fArff);


end