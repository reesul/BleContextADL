function [ruleSet] = createRules_v3(records, classLabel, minSupport, iouThresh)

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
summedSortedSupport = summedSM(I);

%this counts how many times a records' beacons have been used within a rule
% countMtx = ones(size(recordMtx));

%keep track of which examples (records) have been covered by some rule
coveredRecordsBase = zeros(1,size(supportMtx,1));
coveredRecords = coveredRecordsBase;

%% create rules

ruleSet = cell(0,4);
discardedRules = cell(0,4);
index = 1;
%continue creating rules until they exist such that all examples are
%covered by some rule
while ~all(coveredRecords) && summedSortedSupport(index)>=minSupport

    examples = find(sortedSupport(:,index));
    absExamples = binLabelsInd(examples);
    IOU = zeros(size(ruleSet,1),1); %size of intersect over size of union
    IOUdiscard = zeros(size(discardedRules,1),1);
    
    %look for commonality between new rule and existing set of rules
    for j=1:size(ruleSet,1)
       compareExamples = ruleSet{j,4};
       common = intersect(examples, compareExamples); 
       if numel(common) >= minSupport
           IOU(j) = numel(common) / (numel(examples) + numel(compareExamples) - numel(common));
       else
           IOU(j) = 0;
       end
    end
    
    %look for commonality between new rule and existing set of DISCARDED
    %rules
    for j=1:size(discardedRules,1)
       compareExamples = discardedRules{j,4};
       common = intersect(examples, compareExamples); 
       if numel(common) >= minSupport
           IOUdiscard(j) = numel(common) / (numel(examples) + numel(compareExamples) - numel(common));
       else
           IOUdiscard(j) = 0;
       end
    end
    if length(IOUdiscard)==0 %case in which no rules have been merged yet; otherwise variable is empty
        IOUdiscard=0;
    end
    
    
    % Try to merge rules - this can be done if we had an intersect over
    % union higher than the provided threshold
    if max(max(IOU), max(IOUdiscard)) > iouThresh
        if max(IOU) >= max(IOUdiscard)
            %our this new pattern would be a good addition to an existing
            %one; need to set aside the base of the rules for potential
            %reuse
           [~,oldRuleInd] = max(IOU);
           %save old rule and new (unmerged) rule
           discardedRules(end+1,:) = ruleSet(oldRuleInd,:);
           discardedRules{end+1,1} = I(index);
           discardedRules{end, 2} = absExamples;
           discardedRules{end, 3} = index;
           discardedRules{end, 4} = examples;

           %then we need to join the rule at ind with the current one
           %(index); replace the old rule with the extended one
           ruleSet{oldRuleInd,1} = [ruleSet{oldRuleInd,1}, I(index)];
           ruleSet{oldRuleInd,3} = [ruleSet{oldRuleInd,3}, index];
           ruleSet{oldRuleInd,2} = intersect(ruleSet{oldRuleInd,2}, absExamples);
           ruleSet{oldRuleInd,4} = intersect(ruleSet{oldRuleInd,4}, examples);

           %fix 'coveredRecords'
           coveredRecords = fixCoveredRecords(ruleSet, coveredRecordsBase);
           
        else
            %a discarded rule should be combined with this one
            [~,oldRuleInd] = max(IOUdiscard);
           %save new (unmerged) rule
           discardedRules{end+1,1} = I(index);
           discardedRules{end, 2} = absExamples;
           discardedRules{end, 3} = index;
           discardedRules{end, 4} = examples;

           %then we need to join the previous rule at ind with the current one (index)
           ruleSet{end+1,1} = [discardedRules{oldRuleInd,1}, I(index)];
           ruleSet{end,3} = [discardedRules{oldRuleInd,3}, index];
           ruleSet{end,2} = intersect(discardedRules{oldRuleInd,2}, absExamples);
           ruleSet{end,4} = intersect(discardedRules{oldRuleInd,4}, examples);

           %fix 'coveredRecords'
           coveredRecords = fixCoveredRecords(ruleSet, coveredRecordsBase);
        end
    
    %if there are examples that were previously not covered by a rule,
    %then this is a useful rule
    elseif ~all(coveredRecords(examples))
        ruleSet{end+1,1} = I(index);
        ruleSet{end, 2} = absExamples;
        ruleSet{end, 3} = index;
        ruleSet{end, 4} = examples;
        coveredRecords(examples) = 1;
%     else
%         disp('not a good rule') %debugging statement
    end
        
    
    index = index+1;
        
end
fprintf('Created %d pattern(s) for %s', size(ruleSet,1), classLabel{1});
if ~all(coveredRecords)
    fprintf('; %0.1f percent of instances uncovered\n', 100*(length(coveredRecords)-sum(coveredRecords))/length(coveredRecords));
else
    fprintf('\n');
end

ruleSet = ruleSet(:, 1:2) %don't need the last column

end

function [coveredRecords] = fixCoveredRecords(ruleSet, coveredRecordsBase)
coveredRecords = coveredRecordsBase;
for i=1:size(ruleSet,1)
    
   examples = ruleSet{i,4};
   coveredRecords(examples) = 1;
    
end

end
