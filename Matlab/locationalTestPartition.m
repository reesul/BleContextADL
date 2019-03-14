function [subsets] = locationalTestPartition(records, locations)

subsets=cell(size(locations));

for i=1:size(records,2)
    check = false;
    for j = 1:length(locations)
        
        if strcmp(records(end,i), locations{j})
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
