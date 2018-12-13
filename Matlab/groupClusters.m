function [joinedClusters, joinedClusterRecords, joinedClusterVectors] = groupClusters(clusters, clusterRecords, clusterVectors, joinThreshold)


while true %break whenever we no longer find any more to join
    join = [0, 0, -1]  ;  
    for i=1:size(clusterVectors,1)-1
        for j=i+1:size(clusterVectors,1)
            sim = clusterSimiliarity(clusterVectors(i,:), clusterVectors(j,:));
                    
            %we will combine the most similar pair of clusters (above
            %threshold)
            if (sim > joinThreshold && sim > join(3))
                join = [i,j,sim];
            end
            
        end
    end
    
    if join(3) == -1
        break;
    end
    
    i = join(1); j = join(2); %retrieve values we stored for indices of clusters to join
    fprintf('joining clusters %d and %d; lengths are %d and %d\n', i, j, length(clusters{i}), length(clusters{j}));
    
    %join the two clusters 
    jRecords = [clusterRecords{i}, clusterRecords{j}];
    jVectors = bitor(clusterVectors(i,:), clusterVectors(j,:));
    jClusters = {[clusters{i}, clusters{j}]};
    
    %get the indexes for the entire set EXCEPT i and j
    indexes = [1:i-1, i+1:j-1, j+1:size(clusterVectors,1)];
    clusters = [clusters(indexes); jClusters];
    clusterRecords = [clusterRecords(indexes); {jRecords}];
    clusterVectors = [clusterVectors(indexes,:); jVectors];
    

end

% do some sorting and filtering
[~,I] = sort(cellfun(@length, clusters), 'descend');
clusters = clusters(I);
clusterRecords = clusterRecords(I, :);
clusterVectors = clusterVectors(I, :);

%remove clusters with less than 5 records
I = find(cellfun(@length, clusters) > 3);
clusters = clusters(I);
clusterRecords = clusterRecords(I, :);
clusterVectors = clusterVectors(I, :);

%set aside output variables
joinedClusters = clusters;
joinedClusterRecords = clusterRecords;
joinedClusterVectors = clusterVectors;

end

function sim = clusterSimiliarity(c1,c2)
and = sum(bitand(c1,c2));
or = sum(bitor(c1,c2));

sim = and/or;

end