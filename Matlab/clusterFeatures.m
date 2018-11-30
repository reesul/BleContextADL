function [features, featuresBinary] = clusterFeatures(clusters, records, threshold)

numClusters = size(clusters,1);
numInstances = size(records,2);

features = zeros(numInstances, numClusters);
featuresBinary = zeros(numInstances, numClusters);

for i=1:numInstances
    
    for j=1:numClusters

         features(i,j) = calcFeature(records{3,i},clusters(j,:));
         featuresBinary(i,j) = features(i,j)  > threshold;

    end

end


end



function [f] = calcFeature(r,c)

    and = sum(bitand(r,c));
    or = sum(bitor(r,c));
    f = and/or;


end