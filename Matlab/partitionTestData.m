function [subsets] = partitionTestData(testingRecords, allPatterns, patternPr, shareContext, activities)


subsets = cell(1, length(shareContext));

minP = 2/length(activities);


for i=1:size(testingRecords,2)
   
    prMtx = testRecord(testingRecords{3,i}, allPatterns, patternPr);
    meanPr = mean(prMtx,2);
    
    ind = meanPr > minP;
    contextSig = activities(ind);
    
    validContext = false;
    for j=1:length(shareContext)
       if isequal(contextSig, shareContext{j})
           subsets{j} = [subsets{j},i];
           validContext  = true;
           break;
       end        
    end
    
    if ~validContext
        subsets{1} = [subsets{1}, i];
    end
    
end

end