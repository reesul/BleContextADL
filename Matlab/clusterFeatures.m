function [features, featuresBinary] = clusterFeatures(clusters, records, threshold, isWeighted, clusterWeights)

numClusters = size(clusters,1);
numInstances = size(records,2);

features = zeros(numInstances, numClusters);
featuresBinary = zeros(numInstances, numClusters);

for i=1:numInstances
    
    for j=1:numClusters
         if isWeighted
             features(i,j) = calcFeatureWeighted(records{3,i},clusters(j,:), clusterWeights);
             featuresBinary(i,j) = features(i,j)  > threshold;
        else
             features(i,j) = calcFeature(records{3,i},clusters(j,:));
             featuresBinary(i,j) = features(i,j)  > threshold;
        end

    end

end


end



function [f] = calcFeature(r,c)

    and = sum(bitand(r,c));
    or = sum(bitor(r,c));
    f = and/or;


end

function [f] = calcFeatureWeighted(r,c,w)

    and = sum(w.*bitand(r,c));
    or = sum(bitor(r,c));
    f = and/or;


end