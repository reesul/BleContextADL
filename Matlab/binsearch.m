function [index] = binsearch(findVal, data)
%does a binary search on the data to get the index of the value to find
%If value is not present, it uses the a value close to it (not necessarily
%the closest value, but within one index of it)
%Requirement: data must be sorted (works on ascending order, may not work
%for descending)
%%% Data must be in a vector!

left = 1;
right = length(data);

while left <= right
    mid = ceil((left + right) / 2);
    
    if data(mid) == findVal
        break;
    else if data(mid) > findVal
        right = mid - 1;
        else
            left = mid + 1;
        end
    end
end

index = mid;


end