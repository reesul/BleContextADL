%v1: first attempt; poor results
%v2: single-beacon rules
%v3: merging single-beacon rules and minimum support
%v4: bagging and random feature selection

function [ruleSet] = createRules_v4(records, classLabel, minSupport, iouThresh, numBags, randFeatureSplit)

%% get the set of records that are for this class only
binLabels = binaryLabels(classLabel, records(end-1,:));
binLabelsInd = find(binLabels);

originalRecords = records;
originalSupportMtx = recordMatrix(records);

records = records(:,binLabels);

%% basic matrix to use for count and support values
supportMtx = recordMatrix(records);

%tracks the value we give each beacon within a record; will change after
%each rule is created to prevent the same rule from being created
%repeatedly
% supportMtx = [[recordMtx, (1:size(recordMtx,1))'] ; [1:size(recordMtx,2),0]];


%% bagging and random feature selection to get more generalized set of patterns

ruleSets = cell(numBags, 1);
baggedRecordMtxes = zeros([numBags, size(supportMtx)]);
randFeatureSets = cell(numBags,1);

if numBags == 1
    ruleSets{1} = generateRules(supportMtx, binLabelsInd, iouThresh, minSupport, 1, true);
else
    for i=1:numBags
        [ruleSets{i}, baggedRecordMtxes(i,:,:), randFeatureSets{i}] = generateRules(supportMtx, binLabelsInd, iouThresh, minSupport, randFeatureSplit, false);
    end
end
    
%% combine the rulesets from individual bags 
finalRuleSet = cell(0,4);

for i=1:numBags %iterate over all bags
    rules = ruleSets{i,:};
    for j=1:size(rules,1)
        
        r = rules{j,1}; %array describing the pattern used for this rule
%         e = rules{j,2} %set of examples covered by this rule
        e = find(all(originalSupportMtx(:,r),2) & binLabels'); %find all of the examples for this rule
        
%         relR = rules{j,3} %used for debugging; relative to the set 
%         relE = rules{j,4} %same useage as relR
        
        %check if rule exists within the finalRuleSet
        index = -1;
        for k = 1:size(finalRuleSet,1)
           fr = finalRuleSet{k,1};
           if isequal(fr, r)
               index=k;
               break;
           end
        end
        
        if index==-1 %rule was not found in final set, so add it
            finalRuleSet{end+1,1} = r;
            finalRuleSet{end,2} = e;
            finalRuleSet{end,3} = 1; %this represents how many bags the pattern has been found in
        else %rule was found in set; update examples (col 2)
            finalRuleSet{index,3} = finalRuleSet{index,3}+1;
%             u = union(e, finalRuleSet{index,2});
%             finalRuleSet{index,2} = u
        end

    end
end


%% calculate a relative frequency for each pattern (necessary?)
if numBags > 1
    for i=1:size(finalRuleSet,1)
        rule = finalRuleSet{i,1};
        finalRuleSet{i,4} = 0;
        for j=1:numBags
            randFeatures = randFeatureSets{j};
            if all(ismember(rule, randFeatures))
                finalRuleSet{i,4} = finalRuleSet{i,4}+1;
            end
        end
        %replace count with a ratio
        if finalRuleSet{i,4}==0
            disp('pattern impossible to find??');
        end

        finalRuleSet{i,3} = finalRuleSet{i,3} / finalRuleSet{i,4};

    end
end

% fprintf('Created %d pattern(s) for %s', size(finalRuleSet,1), classLabel{1});
% if ~all(coveredRecords)
%     fprintf('; %0.1f percent of instances uncovered\n', 100*(length(coveredRecords)-sum(coveredRecords))/length(coveredRecords));
% else
%     fprintf('\n');
% end

ruleSet = finalRuleSet(:, 1:3); %remove unnecessary columns

end

function [ruleSet, supportMtx, randFeatures] = generateRules(recordMtx, originalLabelsInd, iouThresh, minSupport, randomFeaturePercentage, noBagging)
%% make a bag from the data set, and create a set of rules

if noBagging
    baggedSet = 1:size(recordMtx,1); 
else    
    baggedSet = randi(size(recordMtx,1),size(recordMtx,1),1);
end
    
    
supportMtx = recordMtx(baggedSet,:);
summedSM = sum(supportMtx);

numFeatures = length(find(summedSM));
numRandFeatures = round(numFeatures * randomFeaturePercentage);
%sorted to maintain sort on the following linear
randFeatures = sort(randperm(numFeatures, numRandFeatures), 'ascend'); 

[~,I] = sort(summedSM, 'descend');
sortedSupport = supportMtx(:,I(randFeatures));
summedSortedSupport = summedSM(I(randFeatures));

%rfsSupportMtx = sortedSupport(:,randFeatures)
%keep track of which examples (records) have been covered by some rule
coveredRecordsBase = zeros(1,size(supportMtx,1));
coveredRecords = coveredRecordsBase;

ruleSet = cell(0,4);
discardedRules = cell(0,4);
index = 1;
%continue creating rules until they exist such that all examples are
%covered by some rule
while ~all(coveredRecords) && summedSortedSupport(index)>=minSupport*size(supportMtx,1)
% while ~all(coveredRecords) && summedSortedSupport(index)/size(supportMtx,1)>=minSupport %minSupport is percentage
    
    examples = find(sortedSupport(:,index)); %set of examples this pattern applies to
    absExamples = originalLabelsInd(baggedSet(examples)); %get the actual set of examples that were used
    absExamples = unique(absExamples); %duplicates may be awkward later; this also sorts
    
    IOU = zeros(size(ruleSet,1),1); %size of intersect over size of union
    IOUdiscard = zeros(size(discardedRules,1),1);
    
    %look for commonality between new rule and existing set of rules
    for j=1:size(ruleSet,1)
       compareExamples = ruleSet{j,4};
       common = intersect(examples, compareExamples); 
%        if numel(common)/size(supportMtx,1) >= minSupport %here, minSupport is percentage
       if length(common) >= minSupport 
           IOU(j) = length(common) / (length(examples) + length(compareExamples) - length(common));
       else
           IOU(j) = 0;
       end
    end
    
    %look for commonality between new rule and existing set of DISCARDED
    %rules
    for j=1:size(discardedRules,1)
       compareExamples = discardedRules{j,4};
       common = intersect(examples, compareExamples); 
       if length(common) >= minSupport
           IOUdiscard(j) = length(common) / (length(examples) + length(compareExamples) - length(common));
       else
           IOUdiscard(j) = 0;
       end
    end
    if length(IOUdiscard)==0 %case in which no rules have been merged yet; otherwise variable is empty but still needs a value for later conditions
        IOUdiscard=0;
    end
    
    
    % Try to merge rules - this can be done if we had an intersect over
    % union higher than the provided threshold
    if max([max(IOU), max(IOUdiscard)]) > iouThresh
        if max(IOU) >= max(IOUdiscard)
            %this new pattern would be a good addition to an existing
            %one; need to set aside the base of the rules for potential
            %reuse
           [~,oldRuleInd] = max(IOU);
           %save old rule and new (unmerged) rule
           discardedRules(end+1,:) = ruleSet(oldRuleInd,:);
           discardedRules{end+1,1} = I(randFeatures(index));
           discardedRules{end, 2} = absExamples;
           discardedRules{end, 3} = index;
           discardedRules{end, 4} = examples;

           %then we need to join the rule at ind with the current one
           %(index); replace the old rule with the extended one
           ruleSet{oldRuleInd,1} = [ruleSet{oldRuleInd,1}, I(randFeatures(index))];
           ruleSet{oldRuleInd,3} = [ruleSet{oldRuleInd,3}, index];
           ruleSet{oldRuleInd,2} = intersect(ruleSet{oldRuleInd,2}, absExamples);
           ruleSet{oldRuleInd,4} = intersect(ruleSet{oldRuleInd,4}, examples);

           %fix 'coveredRecords'
           coveredRecords = fixCoveredRecords(ruleSet, coveredRecordsBase);
           
        else
            %a discarded rule should be combined with this one
            [~,oldRuleInd] = max(IOUdiscard);
           %save new (unmerged) rule
           discardedRules{end+1,1} = I(randFeatures(index));
           discardedRules{end, 2} = absExamples;
           discardedRules{end, 3} = index;
           discardedRules{end, 4} = examples;

           %then we need to join the previous rule at ind with the current one (index)
           ruleSet{end+1,1} = [discardedRules{oldRuleInd,1}, I(randFeatures(index))];
           ruleSet{end,3} = [discardedRules{oldRuleInd,3}, index];
           ruleSet{end,2} = intersect(discardedRules{oldRuleInd,2}, absExamples);
           ruleSet{end,4} = intersect(discardedRules{oldRuleInd,4}, examples);

           %fix 'coveredRecords'
           coveredRecords = fixCoveredRecords(ruleSet, coveredRecordsBase);
        end
    
    %if there are examples that were previously not covered by a rule,
    %then this is a useful rule
    elseif ~all(coveredRecords(examples))
        ruleSet{end+1,1} = I(randFeatures(index));
        ruleSet{end, 2} = absExamples;
        ruleSet{end, 3} = index;
        ruleSet{end, 4} = examples;
        coveredRecords(examples) = 1;
%     else
%         disp('not a good rule') %debugging statement
    end
    
    %check this rule to make sure that it does satisfy itself
    if sum(all(sortedSupport(:,[ruleSet{end,3}]),2)) < minSupport
       disp('rule does not actually satisfy basic conditions?!?');
    end
        
    
    index = index+1;
    if index==length(summedSortedSupport)
        break;
    end
        
end

randFeatures = sort(I(randFeatures)); %map this back to the original identifiers for beacons

end

function [coveredRecords] = fixCoveredRecords(ruleSet, coveredRecordsBase)
coveredRecords = coveredRecordsBase;
for i=1:size(ruleSet,1)
    
   examples = ruleSet{i,4};
   coveredRecords(examples) = 1;
    
end

end