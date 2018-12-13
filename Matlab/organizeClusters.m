function [clusters, clusterRepresenter, clusterRecords] = organizeClusters(clusters, records)
%remove empty clusters
clusters = clusters(~cellfun(@isempty,clusters));
%sort clusters based on size
[~,sortInd] = sort(cellfun(@length,clusters), 'descend');
clusters = clusters(sortInd);


numClusters = length(clusters);
numDevices = length(records{3,1});
%each row represents all beacons within a cluster as one-hot binary vector
clusterRepresenter = zeros(numClusters, numDevices);
clusterRecords=cell(numClusters,1);

for i = 1:numClusters
    recordSet = records(:,clusters{i});
    clusterRecords{i} = recordSet;
    
    recordMtx = recordSet(3,:);
    recordMtx = cell2mat(recordMtx);
    recordMtx = reshape(recordMtx,[numDevices,size(recordSet,2)]);
    recordMtx = recordMtx'; %transpose so a single record is a row; (index as i,:) for whole record i
    
    clusterRepresenter(i,:) = any(recordMtx,1);
    
end

end
