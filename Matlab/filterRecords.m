%% filter records using threshold, then remove any non-unique records from the set
% for no thresholding of records, no second argument
% To use a numeric threshold on the CV values, use 'numeric threshold'
% option valued by numeric value
% To use a percentage threshold (records are already sorted), just use that
% desired percentage as the second value

function [goodRecords] = filterRecords(records, varargin)

if isempty(varargin)
    threshold=-1;
elseif length(varargin)==1
    threshold=str2double(varargin{1});
    usePercent = true;
elseif strcmp(varargin{1}, 'numeric threshold')
    usePercent = false;
    threshold = varargin{2};
end
    
% sort records based on CV value
[~,sortInd] = sort([records{4,:}]);
records = records(:,sortInd);
    
if threshold ~= -1
    if usePercent
       records = records(:,1:uint32(length(records)*threshold));
    else    
        %thresholdIndexes = find(records{4,:} < threshold);
        %records = records(thresholdIndexes); 
        records = records(:,cell2mat(records(4,:)) < threshold); 
    end 
end

% remove repeat records
recordMtx = records(3,:);
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(records{3,1}),length(records)]);
recordMtx = recordMtx'; %transpose so a single record is a row; (index as i,:) for whole record i

[~,goodIndexes,~] = unique(recordMtx,'rows');

goodRecords = records(:,goodIndexes);
%uniqueRecords



end
