%split is the percentage to build the training set from
function [trainingSet, testingSet] = balanceClass(features, split, className, isRandomSplit, isRecords, negPosRatio)

% do a random percentage split into test and training data
if isRecords
    [test, train] = getTestTrainSetRecords(features, split, isRandomSplit);
    trainingSet = downsampleRecords(train, className, negPosRatio);
    testingSet = downsampleRecords(test, className, negPosRatio);
else
    [test, train] = getTestTrainSet(features, split, isRandomSplit);
    trainingSet = downsample(train, negPosRatio);
    testingSet = downsample(test, negPosRatio);
end

% downsample both sets to max 1:2 ratio of positive:negative labels


end

%randomly partition into testing and training sets
function [test, train] = getTestTrainSet(features, split, isRandomSplit)

setSize = size(features,1);
trainSize = ceil(setSize*split);
testSize = floor(setSize*(1-split));

if setSize ~= trainSize+testSize
    warning('error with train and test size')
end

if isRandomSplit
    trainStartInd = randi(setSize);
else
    trainStartInd = 1;
end

%in this scenario, we need to wrap around for training
if trainSize + trainStartInd >= setSize
    trainEndInd = trainSize - (setSize - trainStartInd);
    train = [features(1:trainEndInd-1,:); features(trainStartInd:end,:)];
    test = features(trainEndInd:trainStartInd-1,:);

else
%wrap asround for testing set
    trainEndInd = trainStartInd + trainSize;
    train = features(trainStartInd:trainEndInd-1,:);
    test = [features(1:trainStartInd-1,:); features(trainEndInd:end,:)]; 
 
end

%check sizes to pick up on any indexing errors
if (size(test,1) ~= testSize) || (size(train,1) ~= trainSize)
    warning('sizes for test and training set do not match; debug');

end

% randomly shuffle test and training sets
test = test(randperm(testSize),:);
train = train(randperm(trainSize),:);


end


function [features] = downsample(features, negPosRatio) 

if isempty(features)
return;
end

labels = logical(features(:,end));
numPositive = sum(labels);

positiveInstances = features(labels, :);
negativeInstances = features(~labels,:);

%reduce set of negative instances to 1:2 ratio 
negInd = randperm(size(negativeInstances,1));

if negPosRatio*numPositive > size(negativeInstances,1) %ensure no index out of bounds
    numNegative = size(negativeInstances,1);
else
    numNegative = negPosRatio*numPositive;
end

negInd = negInd(1:numNegative);

negativeInstances = negativeInstances(negInd, :);

%combine positive and random sets in random order
features = [positiveInstances; negativeInstances];
features = features(randperm(size(features,1)),:);



end
function [test, train] = getTestTrainSetRecords(records, split, isRandomSplit)

setSize = size(records,2);
trainSize = ceil(setSize*split);
testSize = floor(setSize*(1-split));

if setSize ~= trainSize+testSize
    warning('error with train and test size')
end

if isRandomSplit
    trainStartInd = randi(setSize);
else
    trainStartInd = 1;
end

%in this scenario, we need to wrap around for training
if trainSize + trainStartInd >= setSize
    trainEndInd = trainSize - (setSize - trainStartInd);
    train = [records(:,1:trainEndInd-1), records(:,trainStartInd:end)];
    test = records(:,trainEndInd:trainStartInd-1);

else
%wrap asround for testing set
    trainEndInd = trainStartInd + trainSize;
    train = records(:,trainStartInd:trainEndInd-1);
    test = [records(:,1:trainStartInd-1), records(:,trainEndInd:end)]; 
 
end

%check sizes to pick up on any indexing errors
if (size(test,2) ~= testSize) || (size(train,2) ~= trainSize)
    warning('sizes for test and training set do not match; debug');

end

% randomly shuffle test and training sets
test = test(:,randperm(testSize));
train = train(:,randperm(trainSize));


end


function [records] = downsampleRecords(records, className, negPosRatio) 

if isempty(records)
    return;
end



labels = records(end-1,:);
binLabels = logical(binaryLabels(className, labels));
numPositive = sum(binLabels);

positiveInstances = records(:, binLabels);
negativeInstances = records(:, ~binLabels);

%reduce set of negative instances to 1:2 ratio 
negInd = randperm(size(negativeInstances,2)); %randomize order

if negPosRatio*numPositive > size(negativeInstances,2) %ensure no index out of bounds
    numNegative = size(negativeInstances,2);
else
    numNegative = negPosRatio*numPositive;
end

negInd = negInd(1:numNegative);

negativeInstances = negativeInstances(:, negInd);

%combine positive and random sets in random order
records = [positiveInstances, negativeInstances];
records = records(:, randperm(size(records,2)));

end