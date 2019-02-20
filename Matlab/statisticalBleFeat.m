function [features] = statisticalBleFeat(records)

features = zeros(size(records,2),3);

for i=1:size(records,2)
    
   features(i,1) = records{5,i};
   features(i,2) = records{4,i};
   features(i,3) = sum([records{3,i}]);
    
end

end