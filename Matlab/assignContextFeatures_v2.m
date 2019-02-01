function [contextFeatures] = assignContextFeatures_v2(records, labelNames, patterns, patternProbabilities, appliedPatterns)
numContextFeatures = 2* length(labelNames);

contextFeatures = zeros(size(records,2), numContextFeatures);
recordMtx = recordMatrix(records);

for i=1:size(contextFeatures,1)
    
    prMtx = testRecord(recordMtx(i,:), patterns, patternProbabilities);
    cf = [max(prMtx, [], 2)', mean(prMtx,2)'];
%     statBleFeat = zeros(1,3);
%     
%     statBleFeat(1) = records{5,i}; %turnover; calculated when records created
%     statBleFeat(2) = sum(recordMtx(i,:));
%     statBleFeat(3) = ratioPatternDevices(recordMtx(i,:), appliedPatterns{i});
    
    
%     contextFeatures(i,:) = [cf, statBleFeat];
    contextFeatures(i,:) = cf;
    
    
%     plotMatrix(prMtx, labelNames)
    
end


end


function [] = plotMatrix(mtx, labelNames)

for i=1:size(mtx,1)
    
    subplot(3,3,i)
    plot(mtx(i,:),'r*')
    title(labelNames(i))
    axis([1 inf 0 1]);
   
end

% pause

end

function [ratio] = ratioPatternDevices(record, appliedPatterns)

if ~iscell(appliedPatterns)
   ratio = 0;
   return;
end


patternDevices = [appliedPatterns{:}];
patternDevices = unique(patternDevices);

numDevices = sum(record);
devices = find(record);

ratio = length(patternDevices) / numDevices;
end