%% Uses basic pattern usage; if an activity has at least one pattern satisfied, then it is part of the shared context set.
% this function finds which instances of the testing set (records)
% correspond to which sharedContextLabel. The default is the 'null' set
% that happens whenever the set of appropriate ADLs does not actually exist
% in teh sharedContextLabels. 
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

                if all(r(patterns{k})) %find a single pattern that is satisfied, and break;
                    ac(j) = 1;
                    break;
                end
            end

    end
    
    rl = labels(ac); %retrieve the actual labels for this record's context

    validContext = false;
    for j=1:size(sharedContextLabels,1)
        if isequal(rl, sharedContextLabels{j}) % try to find a set of activity labels in the sharedContext set equalivalent to what this record found
            subsets{j} = [subsets{j}, i];
            validContext = true;
        end
    end
    if ~validContext
        subsets{1} = [subsets{1}, i]; %null context is the first set; put this instance there
    end
end