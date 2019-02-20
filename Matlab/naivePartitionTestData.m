function [subsets] = naivePartitionTestData(records, rulesets, sharedContextLabels, labels)

subsets = cell(size(sharedContextLabels,1),1);
numActivities = length(labels);
recordMtx = recordMatrix(records);

for i=1:size(recordMtx,1)
    r = recordMtx(i,:);
    ac = false(1,numActivities);
    for j = 1:numActivities

        patterns = rulesets{j}(:,1);
            for k = 1:size(patterns,1)

                if all(r(patterns{k}))
                    ac(j) = 1;
                    break;
                end
            end

    end
    
    rl = labels(ac);

    validContext = false;
    for j=1:size(sharedContextLabels,1)
        if isequal(rl, sharedContextLabels{j})
            subsets{j} = [subsets{j}, i];
            validContext = true;
        end
    end
    if ~validContext
        subsets{1} = [subsets{1}, i];
    end
end