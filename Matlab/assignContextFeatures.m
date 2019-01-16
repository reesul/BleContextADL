function [contextFeatures] = assignContextFeatures(records, labelNames, rules)

numLabels = length(labelNames);

recordMtx = recordMatrix(records);
contextFeatures = zeros(size(records,2), numLabels);
% contextFeatures = zeros(size(records,2), numLabels+2); %uncomment if
% using BLE statistical features

for r=1:size(recordMtx, 1)
    detectedContext = zeros(1, numLabels);
    for l=1:length(labelNames)
        detectedContext(l) = testRuleSet(rules{l,:}, recordMtx(r,:),l);
        
    end
    contextFeatures(r,1:numLabels) = detectedContext;
    %uncomment below if using BLE statistical features
%     contextFeatures(r,end-1) = records{5,r}; %this is turnover rate
%     contextFeatures(r,end) = sum(recordMtx(r,:)); %number of devices
%     fprintf('%s\t%s\n', records{end-1:end, r});  

    if ~any(detectedContext) %debugging check
        records(:,r); 
    end
    
end

end