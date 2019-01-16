function [features, indexes] = removeEmptyInstances(initFeatures)

nonNullInd = logical(zeros(size(initFeatures,1),1));
for i=1:length(nonNullInd)
    if any(initFeatures(i,:)==-inf)
        nonNullInd(i) = false;
    else
        nonNullInd(i) = true;
    end
end

features = initFeatures(nonNullInd,:);
indexes = find(nonNullInd);



end


