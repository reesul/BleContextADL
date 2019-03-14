function [subsets, recordDecisions] = partitionTestData(testingRecords, allPatterns, patternPr, shareContext, activities, epsilon)


subsets = cell(1, length(shareContext));
recordDecisions = cell(size(testingRecords,2),2);

minP = (1+epsilon)/length(activities);


for i=1:size(testingRecords,2)
   
    [prMtx, satisfiedP] = testRecord(testingRecords{3,i}, allPatterns, patternPr);
    recordDecisions{i,2} = satisfiedP;
    meanPr = mean(prMtx,2);
    
    ind = meanPr > minP;
    contextSig = activities(ind);
    
    validContext = false;
    for j=1:length(shareContext)
       if isequal(contextSig, shareContext{j})
           subsets{j} = [subsets{j},i];
           recordDecisions{1,i} = j;
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