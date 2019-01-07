function [ruleSet] = createRules(records, classLabel)

%% get the set of records that are for this class only
binLabels = binaryLabels(classLabel, records(end-1,:));

records = records(:,binLabels);

%% basic matrix to use for count and support values
recordMtx = recordMatrix(records);

%tracks the value we give each beacon within a record; will change after
%each rule is created to prevent the same rule from being created
%repeatedly
supportMtx = [[recordMtx, (1:size(recordMtx,1))'] ; [1:size(recordMtx,2),0]];

%this counts how many times a records' beacons have been used within a rule
countMtx = ones(size(recordMtx));

%keep track of which examples (records) have been covered by some rule
coveredRecords = zeros(1,size(recordMtx,1));
%% create rules

ruleSet = cell(0,2);
discardedRules = 0;
%continue creating rules until they exist such that all examples are
%covered by some rule
while ~all(coveredRecords)

    [rule, examples] = newRule(supportMtx, countMtx, stopThresh, 0, size(recordMtx, 1));
    countMtx = updateCounts(countMtx, rule, examples);
    supportMtx = updateSupports(supportMtx, countMtx, recordMtx, examples, rule);
    if ruleIsRelevant(rule, examples, ruleSet)
        ruleSet{end+1,1} = rule;
        ruleSet{end, 2} = examples;
        coveredRecords(examples) = 1;
        
    else
        discardedRules = discardedRules + 1;
        
    end
end



end

%% recursive function to build a single rule
function [rule, coveredExamples] = newRule(supportMtx, countMtx, threshold, previousSupport, totalExamples)

maxSupport = -1;
bestFeature = 0;
bestFeatureIndex = 0;

% loop over every feature available
for i=1:(size(supportMtx,2)-1)
    support = sum(supportMtx(1:end-1,i));
    
    if support>maxSupport
       maxSupport = support;
       bestFeature = supportMtx(end,i);
       bestFeatureIndex = i;
    end
        
end

%get the set of examples that the rule applies to
examplesInd = find(supportMtx(1:end-1,bestFeatureIndex));
examples = supportMtx(examplesInd,end);

coverage = numel(examples)/totalExamples;
% coverage = 1;
maxSupport = maxSupport * coverage;

%if best addition to the pattern is significantly worse than the output of
%the past pattern, then stop building the pattern
if maxSupport < threshold*previousSupport
    rule=-1; coveredExamples = []; return;
   
    
else
    %get a subset of the support matrix that satisfies the existing rule
    newSupportMtx = [supportMtx(examplesInd,:); supportMtx(end,:)];
    newSupportMtx = [newSupportMtx(:,1:bestFeatureIndex-1), newSupportMtx(:,bestFeatureIndex+1:end)];
    
    
    [rule, coveredExamples] = newRule(newSupportMtx, countMtx, threshold, maxSupport, totalExamples);
    if rule==-1
        rule = [bestFeature];
        coveredExamples = examples;
    else
        rule = [bestFeature, rule];
    end
end    


end

%% update the count matrix
%   using an exponential factor instead of linear counts so convergence
%   happens more quickly
function [newCountMtx]  = updateCounts(countMtx, rule, examples)

newCountMtx = countMtx;
% newCountMtx(examples, rule) = newCountMtx(examples, rule) + 1;
newCountMtx(examples, rule) = newCountMtx(examples, rule) * 1.1;

end

%% update the matrix used for support. 
%   The purpose is to update based on how often an example and beacon have been used in other
%   rules
function [supportMtx] = updateSupports(supportMtx, countMtx, recordMtx, examples, rule)

%need to replace all but last row and column since those are just indexes
% supportMtx(1:end-1, 1:end-1) = (1./countMtx) .* recordMtx;
supportMtx(examples, rule) = supportMtx(examples, rule) - 1/4;

if min(supportMtx(:)) < 0
    disp('you have gone too far this time... on the support mtx');
end

end

function [bool] = ruleIsRelevant(rule, examples, goodRules)

bool = true;

for i=1:size(goodRules,1)
   
    r = goodRules{i,1};
    e = goodRules{i,2}; %this is the set of examples used for rule i
    
    if length(e) < length(examples)
        continue;
%     elseif mean(ismember(rule, r)) < 0.25 || mean(ismember(r, rule)) < 0.25
%         continue; %if rules very dissimilar, allow it
    elseif all(ismember(examples, e)) %if true, new rule is a subset of another
        bool = false; 
        break;
    end
    
    
    
end

end