%does a search to find the next index for a window of BLE data
%NOTE: this search is very specific, requires the last index as a base
    %point, as the data is assumed to be sorted, and we will be looking for
    %increasing index as the windows are created using this function
%The idea is to traverse the data, until the value of the data at the current
%index is above findVal. At this point, the index should move back by 1, so
%that the index always returns an index that corresponds to a value (i.e.
%time) that is less than or equal to the value we are searching for. This ensures we do
%not end up with indices from the 'future' per se.
function [index] = searchBleTime(findVal, data, last_index)

index = last_index;

while (data(index)<=findVal)
    index = index+1;
    if (index>length(data)) %reached end of possible indexes, exit loop
        break;
    end
end

%searching is designed to overstep, so move backwards by 1
index = index-1;
%in case index was 1 (and now 0), set explicitly to 1 to avoid index errors
if (index==0)
    index=1;
end

%find edge in case there are several of the same value
if data(index)~=findVal && index<length(data)
    while (data(index)==data(index+1))
        index = index+1;
        if(index==length(data)) 
            break;
        end
    end
end

end