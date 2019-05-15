%% gets the BLE statistical features. Most of these are created while creating records
% First two are turnover, second two are device count. Filtered is
% first, unfiltered second
function [features] = statisticalBleFeat(records)

features = zeros(size(records,2),4);

for i=1:size(records,2)
    
   features(i,1) = records{5,i};
   features(i,2) = records{4,i};
   features(i,3) = sum([records{3,i}]);
   features(i,4) = records{6,i};
    
end

end