%% This script is used for testing various parameters for BLE clustering
% The clean set of devices should already be obtained for this script, and
% in the workspace (best to pull from a .mat file before starting script, as this 
% should have all of the expected names already in it)
%
% Note: it is likely that the 'datapath' variable will need to be changed!
%
% This script is organized to be run in sections depending on which
% parameters need to be adjusted. 

%% Generate the set of records
%window size for a record (milliseconds), suggested range: 15-60 seconds
recordInterval = 1000 * 60; 
recordSet = createRecords(datapath, cleanDevices, recordInterval, cleanNumDev); % use 60 second interval for creating records

boxplot(cell2mat(recordSet(4,:)));
fprintf('Refer to the plot to select a good threshold value for CV of each record;\n lower values are better!\n\n');
pause;

%% Filter the set of records into a 'good' set to be used for clustering
% determine the threshold based on the boxplot from the previous section;
% See 'filterRecords' description to see usage for filtering based on
% percentage of array length
threshold=1.25; %threshold for CV values of each record
goodRecordSet = filterRecords(recordSet, 'numeric threshold', threshold);

%% Generate a similarity matrix and run through affinity propagation
% Recommended to use a grid search on this portion
gridSize = [5,5];
apResults = cell(gridSize);

upperAlpha = 2; lowerAlpha = -2; %powers of 10
upperBeta = 2; lowerBeta = -2;  %powers of 10

saveName = sprintf('AP_results_ID-%d_recordSize-%ds', tryIdentification, recordInterval/1000);

a = 1; b = 1; %indexes for apResults
for alpha = 10.^linspace(lowerAlpha,upperAlpha,gridSize(1))
    b=1;
    for beta = 10.^linspace(lowerBeta,upperBeta,gridSize(2))
        S = similarityRecords(goodRecordSet, alpha, beta);
        [apOutput,~,clusters] = bleAPCluster(S, length(S), 'damp', 0.9);
        [clusterReps, clusterRecords] = organizeClusters(clusters, goodRecordSet);
        
        apResults{a,b} = {clusters, clusterReps, clusterRecords, apOutput, [alpha, beta]};
        b = b+1;
    end
    a = a+1;
    save(saveName);
end

%% evaluate all results
% TODO once evaluation script is created