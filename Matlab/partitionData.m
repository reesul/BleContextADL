function [subsets, shareContext, subsetsNotReduced, naiveClassify] = partitionData(activityLabelNames, cTrainingRaw, sizeThreshold, epsilon)
% find the activities that occur together that we would need to train
% separate imu classifiers for


numActivities = length(activityLabelNames);
minP = (1+epsilon)/numActivities;
naiveClassify = zeros(size(cTrainingRaw,2),1);


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
    
    if size(pMtx,2) > 1
        [~,actWithMaxP] = max(max(pMtx,[], 2));
    else
        [~,actWithMaxP] = max(pMtx);
    end
    naiveClassify(i) = actWithMaxP ;
    

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
if nullInd
    finalSubsets(1,:) = subsets(nullInd,:); %copy the catch-all context signature as the first
else
    finalSubsets(1,:) = cell(1,3);
    
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

