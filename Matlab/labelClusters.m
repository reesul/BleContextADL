function [labeledClusters] = labelClusters(csvData, clusters, labelNames)


labeledClusters = [clusters, cell(size(clusters,1),1)];

for i=1:size(clusters,1)

    clus = clusters{i};
    labels = cell(size(clus,2),1);
    for r=1:size(clus,2)
        
        labels{r} = getLabel(csvData, clus{1,r}, clus{2,r}); 

    end

%     if all(strcmp(labels
    for l=1:length(labelNames)
        if all(strcmp(labelNames(l),labels))
            labeledClusters(i,2) = labelNames(l);
        end
    end


end


end

