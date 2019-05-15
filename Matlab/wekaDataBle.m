%% Writes files for Weka (machine learning prototyping platform) using the set of features and their corresponding labels. 
% if isTrain is true, then '_training' is appended to the filename. Else,
%   '_testing' is appended. Feature names do not need to be specified; these
%   will just be called f# where # is the number of the feature. 
% wekaDataOut is the folder the file is saved to. Be sure to change this!
function [] = wekaDataBle(filename, features, labels, labelNames, isTrain)

wekaDataOut = 'C:\Users\reesul\Documents\Activity_Recognition\Nearables\Processing\Classification\'; % CHANGE THIS

for i=1:length(labels)
    labels(i) = strrep(labels(i), ' ', '_');
end
for i=1:length(labelNames)
     labelNames(i) = strrep(labelNames(i), ' ', '_');
end

numRecords = size(features, 1);
numFeatures = size(features,2);



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