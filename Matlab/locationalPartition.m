%% partition data into subsets of ADLs using the context labels. The records here should be the training records, not all of them
function [subsets, labels] = locationalPartition(records)

locations = unique(records(end,:));
subsets = cell(length(locations),3);
subsets(:,1) = locations;

for i = 1:size(records,2)
    for j = 1:length(locations)
        if strcmp(records(end,i), locations{j})
            subsets{j,2} = [subsets{j,2}, i]; %indices of training instances that apply to this
            subsets{j,3} = unique([subsets{j,3}, records(end-1,i)]); % the ADL labels seen in this location
            break;
        end
    end

end

labels =cell(length(locations),1);
for i=1:length(locations)
labels(i) = {locations(i)};
end

end