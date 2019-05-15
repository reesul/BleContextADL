%return a logical vector indicating which records have the desired label.
function [labels] = binaryLabels(targetLabel, labelOriginal)

labels = strcmp(targetLabel, labelOriginal);
    
end