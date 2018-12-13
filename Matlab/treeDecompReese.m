function [goodClusters] = treeDecompReese(tree)


cut = tree.CutPredictor;
leaves = ~(tree.IsBranchNode);
parent = tree.Parent;
children = tree.Children;
classN = tree.NodeClass;
classN = str2double(classN);

%leaves with class node
goodLeaves = find(leaves & classN);
goodClusters = [];

%parse up the tree for each of these
for g=1:length(goodLeaves)
    leafNode = goodLeaves(g);
    childNode = leafNode;

    clus = [];

    while childNode ~= 1
        parentNode = parent(childNode);
        if children(parentNode,2) == childNode
            %get the cluster that controlled this branch
            feature = cut(parentNode);
            feature = str2num(feature{1}(2:end));
            clus = [clus, feature];

        end
        

        %update child and parent
        childNode = parentNode;
        

    end
    goodClusters = [goodClusters, clus];

end

goodClusters = unique(goodClusters);

end