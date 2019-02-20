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
%% original code
numActivities = length(activityLabelNames);
minP = 2/numActivities;


shareContext = {};
subsets = cell(0,3); %store the indices of each instance belonging to a particular subset
subsetsNotReduced = subsets;

% ind = patternPr(:,i) > minP
% labels = activityLabelNames(ind);
% shareContext{end+1} = labels;

%use patternPr, look at each column

% notTransport = [0; 1; 1; 0; 1; 1; 1; 1; 0];  % Use if ignoring transportation activities
for i=1:size(cTrainingRaw,1)
    
    pMtx = cTrainingRaw{i};
    meanPr = mean(pMtx,2);
%    ind = patternPr(:,i) > minP
    ind = meanPr > minP;
%     ind = ind & notTransport; % Use if ignoring transportation activities
    labels = activityLabelNames(ind);

    isIn = false;
    
    for j=1:length(shareContext)
       if isequal(shareContext{j}, labels)
           %add this index into the subset
           subsets{j, 2} = [subsets{j, 2}, i];
           subsets{j, 3} = unique([subsets{j, 3}, cTrainingRaw(i,2)]);
           isIn = true;
           break; %if commented out, then a single instance may exist in multiple subsets
       end
    end
    if ~isIn
%        disp(labels)
       shareContext{end+1} = labels;
       subsets{end+1,1} = labels;
       subsets{end, 2} = i;
       subsets{end, 3} = cTrainingRaw(i,2);
    end
       
end

nullInd = find(cellfun(@isempty, shareContext));
tooFewInstances = find(cellfun(@length, subsets(:,2)) < sizeThreshold);

finalSubsets = cell(1,3);
finalSubsets(1,:) = subsets(nullInd,:); %copy the catch-all context signature as the first

for i=1:size(subsets,1)
    if i == nullInd
        continue;
    elseif any(ismember(i,tooFewInstances))
        finalSubsets{1,2} = [finalSubsets{1,2}, subsets{i,2}];
    else 
        finalSubsets(end+1,:) = subsets(i,:);
    end
    
end
        
subsets = finalSubsets;
shareContext = subsets(:,1);

% shareContext = shareContext(cellfun(@length, shareContext) >= 2)

end

