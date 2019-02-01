% find the activities that occur together that we would need to train
% separate imu classifiers for


numActivities = length(activityLabelNames);
minP = 1/numActivities;


shareContext = {};
subsets = cell(0,2) %store the indices of each instance belonging to a particular subset

% ind = patternPr(:,i) > minP
% labels = activityLabelNames(ind);
% shareContext{end+1} = labels;

%use patternPr, look at each column

notTransport = [0; 1; 1; 0; 1; 1; 1; 1; 0];
for i=1:size(cTrainingRaw,1)
    
    pMtx = cTrainingRaw{i};
    meanPr = mean(pMtx,2);
%    ind = patternPr(:,i) > minP
    ind = meanPr > minP;
    ind = ind & notTransport;
    labels = activityLabelNames(ind);

    isIn = false;
    index
    for j=1:length(shareContext)
       if isequal(shareContext{j}, labels)
           isIn = true;
       end
    end
    if ~isIn
       disp(labels)
       shareContext{end+1} = labels;
    end
       
end

% shareContext = unique(shareContext)
for i=1:length(shareContext)
    l = shareContext{i};
    if isempty(l) || length(l) == 1
        continue;
    end
    
    s = l{1};
    for j=2:length(l)
        s = sprintf('%s, %s', s, l{j});
    end
    disp(s);
end