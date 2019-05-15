%% finds which instances should be applied to which sharedContext sets provided after running 'partitionData'
% Effectively the same as 'paritionData', but the sharedContexts are
% already defined
function [subsets, recordDecisions, naiveClassify] = partitionTestData(testingRecords, allPatterns, patternPr, shareContext, activities, epsilon)

testLabels = testingRecords(end-1,:);

subsets = cell(1, length(shareContext));
naiveClassify = zeros(size(testingRecords,2),1);

minP = (1+epsilon)/length(activities);

useAbsMax = false;


for i=1:size(testingRecords,2)
   
    [prMtx, satisfiedP] = testRecord(testingRecords{3,i}, allPatterns, patternPr);
    recordDecisions{i,2} = satisfiedP;
    meanPr = mean(prMtx,2);
    
    if useAbsMax
        if size(prMtx,2) > 1
            [~,actWithMaxP] = max(max(prMtx,[], 2));
        else
            [~,actWithMaxP] = max(prMtx);
        end
    else
       [~, actWithMaxP] = max(meanPr); 
    end
    naiveClassify(i) = actWithMaxP ;
    
    ind = meanPr > minP;
    contextSig = activities(ind);
    
    validContext = false;
    for j=1:length(shareContext)
       if isequal(contextSig, shareContext{j})
           subsets{j} = [subsets{j},i];
           validContext  = true;
           if ~any(ismember(testingRecords(end-1,i), contextSig))
               
               break;
           end
           break;
       end        
    end
    
    if ~validContext
        subsets{1} = [subsets{1}, i];
    end
    
end

end