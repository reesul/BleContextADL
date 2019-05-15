%% parition training indices such that if a single pattern originating from some activity is satisied, then that activity should be trained for in the classifer
% Returns the stared context labels(SCL), the subsets containing SCL, the
% corresponding instances, and the true ADLs that appear, and those same
% subsets, but only those whose number of instances exceeds the
% sizeThreshold
function [subsets, shareContext, subsetsNotReduced] = naivePartitionData(activityLabelNames, records, sizeThreshold, rulesets)

recordMtx = recordMatrix(records);
numActivities = length(activityLabelNames);
activeContext = false(size(records,2), numActivities);

% first find which patterns can be applied from which activity
%   Using the union of patterns to represent context naively 
for i=1:size(recordMtx,1)
    r = recordMtx(i,:);
    for j = 1:numActivities
        
        patterns = rulesets{j}(:,1);
            for k = 1:size(patterns,1)
                
                if all(r(patterns{k}))
                    activeContext(i,j) = 1;
                    break;
                end
            end
            
    end
    
end

%find the unique set of rows (each column is an activity label)
contexts = unique(activeContext, 'rows');


%get the exact label names for each 'context'
shareContext = {};
for i=1:size(contexts,1)
    shareContext{end+1} = activityLabelNames(contexts(i,:));
end
%labels corresponding to each subset
subsets = cell(size(contexts,1),3); %store the indices of each instance belonging to a particular subset
subsets(:,1) = shareContext;
subsetsNotReduced = subsets;

% repeat above, but enter information into returned array; could almost
% certainly be more efficient
for i=1:size(recordMtx,1)
    r = recordMtx(i,:);
    ac = zeros(1,numActivities);
    for j = 1:numActivities
        
        patterns = rulesets{j}(:,1);
            for k = 1:size(patterns,1)
                
                if all(r(patterns{k}))
                    ac(j) = 1;
                    break;
                end
            end
            
    end
    
    for j=1:size(contexts,1)
        if isequal(ac, contexts(j,:))
            subsets{j,2} = [subsets{j,2}, i];
            
        end
    end
    
end

tooFewInstances = find(cellfun(@length, subsets(:,2)) < sizeThreshold);
nullInd = find(cellfun(@isempty, shareContext));

reducedSubsets = cell(1,3);
reducedSubsets(1,:) = subsets(nullInd,:);


for i=1:size(subsets,1)
    if i == nullInd
        continue;
    elseif any(ismember(i,tooFewInstances))
        reducedSubsets{1,2} = [reducedSubsets{1,2}, subsets{i,2}];
    else 
        reducedSubsets(end+1,:) = subsets(i,:);
    end
    
end

subsetsNotReduced = subsets;
subsets = reducedSubsets;
shareContext = subsets(:,1);

return;