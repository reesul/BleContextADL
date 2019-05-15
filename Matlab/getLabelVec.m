%% get the entire vector of labels based on all records
function [labelVec] = getLabelVec(csvData, records)

labelVec = cell(2,size(records,2));

for i=1:size(records,2)
    
    [al ll] = getLabel(csvData, records{1,i}, records{2,i});
    labelVec(:,i) = {al, ll};


end