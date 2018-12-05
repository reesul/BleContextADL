function goodClusters = treeDecomposition(tree)

% ref. https://www.mathworks.com/help/stats/classificationtree-class.html
cut = tree.CutPredictor;
tf = tree.IsBranchNode;
parent = tree.Parent;
children = tree.Children;
classN = tree.NodeClass;

len = length(tf);

keys = {};
vals = {};

% create Map container - struct

% update duplicated cluster names by adding random chars
for idx = 1:len
    k = char(cut(idx));
    if ~isempty(k)

        kOriginal = k;
        
        while any(strcmp(k, keys))
            % if same cluster exists, add random char in front
            randIdx = randsample(65:74, 8);
            k = sprintf('%s%s', char(randIdx), kOriginal);
        end
        cut{idx} = k;
    end
end

% struct: (parent node index, current column(cluster) name, left, right
for idx = 1:len

    k = char(cut(idx));
    if ~isempty(k)
        
        cc = children(idx, :);
        s = struct;
        s.parentIdx = parent(idx);
        s.current = k;
        s.left = assignNext(cut, cc(1), classN); % x_N < 0.5 side
        s.right = assignNext(cut, cc(2), classN); % x_N >= 0.5 side
%         
%         kOriginal = k;
%         if strcmp(kOriginal, 'x251')
%             disp('k');
%         end
%         while any(strcmp(k, keys))
%             % if same cluster exists, add random char in front
%             randIdx = randsample(65:74, 8);
%             k = sprintf('%s%s', char(randIdx), kOriginal);
%         end

        cut{idx} = k;

        keys{end + 1} = k;
        vals{end + 1} = s;
    end
end

M = containers.Map(keys, vals);

goodClusters = getUniqueLeavesOfOnes(M, keys, cut);

end

function ret = assignNext(cut, ccX, classN)
item = char(cut(ccX));
if isempty(item)
    val = str2num(char(classN(ccX)));
    ret = val; % this is a leaf, either (double type) 0 / 1
else
    ret = item;
end
end

function clusterIdx = col2clusterIdx(cCell)
cc = regexp(cCell,'\d*','Match');
clusterIdx = str2num(char(cc{1}));
end

function goodClusters = getUniqueLeavesOfOnes(M, keys, cut)

goodClusters = [];

for k = keys
    kk = char(k);
    v = M(kk);
    
    [isLeftOne, isRightOne] = checkLeftRightIsOne(v);
    
    if isLeftOne || isRightOne % search parents
        gc = [];
        if isRightOne
            gc = [gc col2clusterIdx(k)];
        end
        pIdx = v.parentIdx;
        vChild = v;
        while pIdx ~= 0
            % pp = parent(pIdx);
            keyParent = char(cut(pIdx));
            vParent = M(keyParent);
            
            isParentFromRight = checkChildPosition(vParent, vChild);
            
            if isParentFromRight
                gc = [gc col2clusterIdx(keyParent)];
            end
            
            pIdx = vParent.parentIdx;
            vChild = vParent;
            
        end
        
        goodClusters = [goodClusters gc];
    end
    
end

goodClusters = unique(goodClusters);

end

function isParentFromRight = checkChildPosition(vParent, vChild)
parentRight = vParent.right;
child = vChild.current;
isParentFromRight = strcmp(child, parentRight);
end

function [isLeftOne, isRightOne] = checkLeftRightIsOne(v)
isLeftOne = false(1);
isRightOne = false(1);

if ~ischar(v.left)
    isLeftOne = v.left == 1;
end
if ~ischar(v.right)
    isRightOne = v.right == 1;
end

end