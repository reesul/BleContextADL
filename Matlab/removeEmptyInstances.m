%% find the indices of instances whose features are invalid (hence the -inf value)
% this will happen if there is BLE data but not ACC/GYRO data saved for
% some reason. most commonly happens if HR data is being used since values
% are reported unreliably. 
function [indexes] = removeEmptyInstances(initFeatures)

nonNullInd = false(size(initFeatures,1),1);
for i=1:length(nonNullInd)
    if any(initFeatures(i,:)==-inf)
        nonNullInd(i) = false;
    else
        nonNullInd(i) = true;
    end
end

% features = initFeatures(nonNullInd,:);
% indexes = find(nonNullInd);

indexes = nonNullInd;



end


