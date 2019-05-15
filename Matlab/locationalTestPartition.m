%% used to find which testing instances should be used in which location-based context set
function [subsets] = locationalTestPartition(records, locations)

subsets=cell(size(locations));

for i=1:size(records,2)
    check = false; % if an unexpected location is found, include those instances with the null context label
    for j = 1:length(locations)
        
        if strcmp(records(end,i), locations{j}) %include records whose context label is this location
            subsets{j} = [subsets{j}, i];
            check=true;
            break;
        end
    end
    if ~check
       ind = find(strcmp([locations{:}], 'null'));
       subsets{ind} = [subsets{ind},i];
    end
end
end
