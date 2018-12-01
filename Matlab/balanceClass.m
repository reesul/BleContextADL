function [balancedSet] = balanceClass(features, holdout)

% remove some instances from the end (temporal sorted input) to get the
% training set
features = features(1:int32(size(features,1)*(1-holdout)),:);

%figure out which labels we need to keep, and how much we need to
%downsample by
labels = logical(features(:,end));
numPositive = sum(labels);

positiveInstances = features(labels, :);
negativeInstances = features(~labels,:);

%reduce set of negative instances to 1:2 ratio 
negInd = randperm(length(negativeInstances));

if 2*numPositive > size(negativeInstances,1) %ensure no index out of bounds
    numNegative = size(negativeInstances,1)
else
    numNegative = 2*numPositive;
end

negInd = negInd(1:numNegative);

negativeInstances = negativeInstances(negInd, :);

%combine positive and random sets in random order
balancedSet = [positiveInstances; negativeInstances];
balancedSet = balancedSet(randperm(size(balancedSet,1)),:);


end