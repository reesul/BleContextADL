function [fTree, fClusters, clusterWeights] = clusterAndClassify(records, targetLabel, csvData)

%init variables
isRandomSplit = false;
testTrainSplit = 0.75;
binaryThresh = 0.1;
negativeToPositiveRatio = 2;
epsilon = 0.005; %bound for change in performance

%used to retrieve activity labels
%get the 'labels' variable by doing csvData = readActivityCsv(), labels =
labels = getLabelVec(csvData, records);
records = [records; labels]; 
%consider splitting records into a testing and training set

[trainingRecords, testingRecords] = balanceClass(records, testTrainSplit, targetLabel, isRandomSplit, true, negativeToPositiveRatio);
trainingLabels = binaryLabels(targetLabel, trainingRecords(end-1,:));
testingLabels = binaryLabels(targetLabel, testingRecords(end-1,:));
 
fprintf('Classes have been balanced\n');

%reduce records to the unique set in preparation for clustering
recordsToCluster = filterRecords(trainingRecords); 

%used to give preference to beacons that indicative of a location; updated
%after each cluster->classify cycle
clusterWeights = ones(1, length(records{3,1}));

fprintf('Begin clustering and classifying\n');

confusionMtx = zeros(2);
oldClusterRecords = {};
stopCondition = false;
oldF1 = 0;
while ~stopCondition
    % itertively cluster and classify until stop condition is met
    S = similarityRecords(recordsToCluster, 1, 1, clusterWeights);

%     [~,~,clusters] = bleAPCluster(S, length(S), 'damp', 0.9, 'median pref');
    [~,~,clusters] = bleAPCluster(S, length(S), 'damp', 0.8);
    [clusterReps, clusterRecords] = organizeClusters(clusters, recordsToCluster);

    [~,features] = clusterFeatures(clusterReps, trainingRecords, binaryThresh);
    [~,testFeatures] = clusterFeatures(clusterReps, testingRecords, binaryThresh);

%     [trainingSet, testingSet] = balanceClass([features, labelBinary'], testTrainSplit, isRandomSplit);

    %do classification on trainingSet
    tree = fitctree(features, trainingLabels');
    testOutput = predict(tree, testFeatures);
    [confusionMtx,~,f1] = confusionMatrix(testOutput, testingLabels');
    %use predict(tree, testingSet(:,1:end-1) to get tree outputs

    % goodClusters = treeDecomposition();
    % convert goodClusters into a set of binary vectors; sum these into a
    % priorities vector, P
    % P = sum(clusterReps(:,activityClusters);
    % clusterWeights = updateWeights(clusterWeights, P, 0.5)

    %stop condition up for debate
    %stopCondition = isequal(oldClusterRecords, clusterRecords);
    changeInPerformance = f1-oldF1;
    if abs(changeInPerformance) < epsilon %this may be flawed; there is no guaranteed minima to be reached, so it is possible that this will diverge
        stopCondition = true;
    end
    oldF1 = f1

    oldClusterRecords = clusterRecords;
end

fTree = tree;
fClusters = clusterRecords;

end

function [confusionMtx, normCM, f1] = confusionMatrix(testOutput, testLabels)

%predicted class along x axis, actual along y; second index is for positive
%class
confusionMtx = zeros(2);

confusionMtx(2,2) = sum(bitand(testOutput, testLabels));
confusionMtx(2,1) = sum(testLabels) - confusionMtx(2,2);%predicted no, actual yes
confusionMtx(1,2) = sum(testOutput) - confusionMtx(2,2); %predicted yes, actual no
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

accuracy = (confusionMtx(1,1)+confusionMtx(2,2)) / sum(confusionMtx(:))
precision  = confusionMtx(2,2) / (confusionMtx (2,2) + confusionMtx(1,2));%true positive and false positive
recall = confusionMtx(2,2) / (confusionMtx (2,2) + confusionMtx(2,1)) %true positive and false negative
f1 = 2*precision*recall / (precision+recall);

end