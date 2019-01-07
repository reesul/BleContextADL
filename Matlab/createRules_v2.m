function [ruleSet] = createRules_v2(records, classLabel)

%% get the set of records that are for this class only
binLabels = binaryLabels(classLabel, records(end-1,:));
binLabelsInd = find(binLabels);
records = records(:,binLabels);

%% basic matrix to use for count and support values
supportMtx = records(3,:);
supportMtx = cell2mat(supportMtx);
supportMtx = reshape(supportMtx,[length(records{3,1}),size(records,2)]);
supportMtx = double(supportMtx');

%tracks the value we give each beacon within a record; will change after
%each rule is created to prevent the same rule from being created
%repeatedly
% supportMtx = [[recordMtx, (1:size(recordMtx,1))'] ; [1:size(recordMtx,2),0]];

summedSM = sum(supportMtx);
[~,I] = sort(summedSM, 'descend');
sortedSupport = supportMtx(:,I);

%this counts how many times a records' beacons have been used within a rule
% countMtx = ones(size(recordMtx));

%keep track of which examples (records) have been covered by some rule
coveredRecordsBase = zeros(1,size(supportMtx,1));
coveredRecords = coveredRecordsBase;

%% create rules

ruleSet = cell(0,2);
index = 1;
%continue creating rules until they exist such that all examples are
%covered by some rule
while ~all(coveredRecords)

    examples = find(sortedSupport(:,index));
    absExamples = binLabelsInd(examples);
%     countMtx = updateCounts(countMtx, rule, examples);
%     supportMtx = updateSupports(supportMtx, countMtx, recordMtx, examples, rule);
    
    %if there are examples that were previously not covered by a rule,
    %then this is a useful rule
    if ~all(coveredRecords(examples))
        ruleSet{end+1,1} = I(index);
        ruleSet{end, 2} = absExamples;
        coveredRecords(examples) = 1;
%     else
%         disp('not a good rule') %debugging statement
    end
        
    
    index = index+1;
        
end



end

