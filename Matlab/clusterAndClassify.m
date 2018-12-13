function [fTree, fClusters, clusterWeights, f1Scores, f1Last, testingRecords] = clusterAndClassify(records, targetLabel, csvData)

%init parameters
isRandomSplit = false; % for relaxing activity, set to true bc not enough labels in later days of data
isDownSample = true;
testTrainSplit = 0.75;
binaryThresh = 0.05;
negativeToPositiveRatio = 2;
epsilon = 0.005; %bound for change in performance
updateDampenFactor = 0.7;
APdampenFactor = 0.8;
isWeightedFeatures = false;
isContinuousFeatures = false;

fprintf('Class: %s\n', targetLabel);

%split into testing and training sets; then get labels for each
[trainingRecords, testingRecords] = balanceClass(records, testTrainSplit, targetLabel, isRandomSplit, true, negativeToPositiveRatio, isDownSample);
trainingLabels = binaryLabels(targetLabel, trainingRecords(end-1,:));
testingLabels = binaryLabels(targetLabel, testingRecords(end-1,:));
 

%reduce records to the unique set in preparation for clustering
recordsToCluster = filterRecords(trainingRecords); 

%used to give preference to beacons that indicative of a location; updated
%after each cluster->classify cycle
clusterWeights = ones(1, length(records{3,1}));

%init params for iteratively clustering and classifying
f1Scores = [];
confusionMtx = zeros(2);
oldClusterRecords = {};
stopCondition = false;
oldF1 = 0;
iter = 1;

%clsuter and classify
while ~stopCondition
    % itertively cluster and classify until stop condition is met
    S = similarityRecords(recordsToCluster, 1, 1, clusterWeights);
%     S = similarityRecords(recordsToCluster, 1, 1, ones(1,length(clusterWeights)));

    %create the clusters using the similarity matrix S
%     [~,~,clusters] = bleAPCluster(S, length(S), 'damp', APdampenFactor, 'median pref');
    [~,~,clusters] = bleAPCluster(S, length(S), 'damp', APdampenFactor);
    [clusters, clusterReps, clusterRecords] = organizeClusters(clusters, recordsToCluster);

    %calculate features sets based on the clusters; Have a training
    %instance for each record, and a feature for each cluster
    [continuousFeatures,featuresBinary] = clusterFeatures(clusterReps, trainingRecords, binaryThresh, isWeightedFeatures, clusterWeights);
    [continuousFeaturesTest,testFeaturesBinary] = clusterFeatures(clusterReps, testingRecords, binaryThresh, isWeightedFeatures, clusterWeights);

%     [trainingSet, testingSet] = balanceClass([features, labelBinary'], testTrainSplit, isRandomSplit);

    %do classification on trainingSet
    fprintf('Begin Training\n')

    %train a decision tree
    if isContinuousFeatures
        tree = fitctree(continuousFeatures, trainingLabels'); %use continuous features    
        testOutput = predict(tree, continuousFeaturesTest);
    else
        tree = fitctree(featuresBinary, trainingLabels'); %use  binary features
        testOutput = predict(tree, testFeaturesBinary);
    end

    %calculate statistics for classifier performance
    [~,~,f1] = confusionMatrix(testOutput, testingLabels');
    %use predict(tree, testingSet(:,1:end-1) to get tree outputs

    %decompose the decision tree structure into the set of features i.e.
    %clusters that were distinctive
    goodClusters = treeDecomposition(tree);
    
    if ~isequal(goodClusters, treeDecompReese(tree))
        fprintf('tree decomps disagree!\n')
    end

    % Based on the distinctive clusters, redistribute weights using the
    % relative frequency of each beacon
    P = sum(clusterReps(goodClusters,:));
    clusterWeights = updateWeights(clusterWeights, P, updateDampenFactor);

    %stop condition up for debate
    %stopCondition = isequal(oldClusterRecords, clusterRecords);
%     changeInPerformance = f1-oldF1;
%     if abs(changeInPerformance) < epsilon %this may be flawed; there is no guaranteed minima to be reached, so it is possible that this will diverge
%         stopCondition = true;
%     elseif isnan(f1)
%         stopCondition = true;
%     end

    oldF1 = f1;
    f1Scores(end+1) = f1;

    oldClusterRecords = clusterRecords;
    fprintf('Iteration %d gave F1-score of %f\n', iter, f1);
    iter = iter+1;
    if iter>3
    stopCondition = true;
    end
end

fTree = tree;
fClusters = clusterRecords;
f1Last = f1Scores(end);

end

function [confusionMtx, normCM, f1] = confusionMatrix(testOutput, testLabels)

%predicted class along x axis, actual along y; second index is for positive
%class
confusionMtx = zeros(2);

confusionMtx(2,2) = sum(bitand(testOutput, testLabels));
confusionMtx(2,1) = sum(testLabels) - confusionMtx(2,2);%predicted no, actual yes; false negative
confusionMtx(1,2) = sum(testOutput) - confusionMtx(2,2); %predicted yes, actual no; false positive
confusionMtx(1,1) = numel(testOutput) - sum(confusionMtx(:));

%normalize based on the the labels
numNeg = sum(~testLabels);
numPos = sum(testLabels);

normCM = zeros(2);
normCM(1,1) = confusionMtx(1,1)/numNeg;
normCM(1,2) = confusionMtx(1,2)/numNeg;
normCM(2,1) = confusionMtx(2,1)/numPos;
normCM(2,2) = confusionMtx(2,2)/numPos;

confusionMtx
normCM

accuracy = (confusionMtx(1,1)+confusionMtx(2,2)) / sum(confusionMtx(:));
precision  = confusionMtx(2,2) / (confusionMtx (2,2) + confusionMtx(1,2));%true positive and false positive
recall = confusionMtx(2,2) / (confusionMtx (2,2) + confusionMtx(2,1)); %true positive and false negative
f1 = 2*precision*recall / (precision+recall);

end