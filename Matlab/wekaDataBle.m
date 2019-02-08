function [] = wekaDataBle(filename, features, labels, labelNames, isTrain)

%remove the records that have null activity labels
% nonNullRecordsInd = ~strcmp(rawLabels(1,:), 'null');
% records = records(:,nonNullRecords);

% recordMtx = records(3,:);
% recordMtx = cell2mat(recordMtx);
% recordMtx = reshape(recordMtx,[length(records{3,1}),size(records,2)]);
% featureSet = recordMtx'; %transpose so a single record is a row; (index as i,:) for whole record i

numRecords = size(features, 1);
numFeatures = size(features,2);

wekaDataOut = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\Processing\Classification\';

if isTrain
    s = [filename, '_training'];
else
    s = [filename, '_testing'];
end

arffFileName = [wekaDataOut, s, '.arff'];
%if .arff file is already there, just delete it so it doesn't show in files
if (fopen(arffFileName, 'r') ~= -1)
    fclose('all');
    delete(arffFileName);
    disp('Deleted existing arff file');
end

% labelSet = binaryLabels(labelName, rawLabels(1,:)); %use 2 for rawLabels to use location labels rather than activity


fArff = fopen(arffFileName, 'w');

%first write the header of the .arff file, like relation and feature
%names

%names of the features
% features = cell(1, numFeatures);
% % features = {'mean', 'std', 'rms', 'mcr', 'var', 'int', 'skew', 'fft1', 'fft2', 'fft3'};
% 
% for i = 1:numFeatures
%    
%     features{i} = ['f', num2str(i)];
%     
% end

fprintf(fArff, '@relation context\n\n');

for i=1:numFeatures
    %instead of numeric, may be appropriate to just specify as {0,1} to use
    %nominal values
    strI = sprintf('%d', i);
    fprintf(fArff, ['@attribute f', strI, ' numeric\n']); 
end



%class labels
fprintf(fArff, '@attribute activity {');

for i=1:length(labelNames)-1
   fprintf(fArff, '%s,', labelNames{i}); 
end
fprintf(fArff, '%s}\n\n', labelNames{end});

%now write the data section of the file

fprintf(fArff, '@data\n');

for i=1:numRecords
    for j=1:numFeatures
%         s = sprintf('%f',featureSet(i,j));
        if isnan(features(i,j))
            fprintf(fArff, '?,');
        else
            fprintf(fArff, '%f,', features(i,j));
        end
        
    end
    fprintf(fArff, '%s\n', labels{i});
end


fclose(fArff);


end