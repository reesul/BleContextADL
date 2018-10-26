function [S] = similarityBLE(occurrenceMap, penalty)

%if no penalty set, use a default value
if nargin < 2
    penalty = 0.5;
end

S = zeros(length(occurrenceMap));

keys = occurrenceMap.keys();

for i=1:length(keys)
    
    for j=1:length(keys)
        if i==j
            S(i,i) = diagonalSimilarity(keys{i}, occurrenceMap);
        else
            S(i,j) = beaconSimilarity(occurrenceMap(keys{i}), occurrenceMap(keys{j}), penalty); 
        end
        
        
    end
end



end

function [s] = diagonalSimilarity(value, occurrenceMap)
occ = occurrenceMap(value);
s = size(occ,1);

end

function[s] = beaconSimilarity(A, B, lambda)
sMatrix = zeros(size(A,1),1);
A;
B;
%lastJ = 1; %becomes much more complex; not worth the performance
%improvement - this is not the most intensive part of processing
for i=1:size(A,1)
    intersect = 0;
    jUsed = [];
    %intersect = length of time that occ1(i) shares with occ2(any)
    %calculate intersect between occ1(i) and anything relevant in occ2
    for j=1:size(B,1)
       if A(i,1) ~= B(j,1)
           continue; % not the same day... ignore this occurrence of B; move onto next
       end
       
       if A(i,2) <= B(j,2) %A(i) starts before B(j)
            if A(i,3) >= B(j,3)
                intersect = intersect + (B(j,3) - B(j,2));
                jUsed(end+1) = j;
            elseif A(i,3) >= B(j,2) %some overlap
                intersect = intersect + (A(i,3) - B(j,2));
                jUsed(end+1) = j;
            end
       else
            if A(i,3) < B(j,3)
                intersect = intersect + (A(i,3) - A(i,2));
                jUsed(end+1) = j;
            elseif A(i,2) <= B(j,3)
                intersect = intersect + (B(j,3) - A(i,2));
                jUsed(end+1) = j;
           end           
           
       end
               
    end
    
    if intersect==0
        sMatrix(i) = -lambda;
    else
        %calculate union
        unionA = A(i,3)-A(i,2); %union is the amount of total time taken up by occ1(i) and occ2(all relevant)
        unionB = 0;
        for j=1:length(jUsed)
           unionB = unionB + (B(jUsed(j),3) - B(jUsed(j),2)); 
        end
        union = unionA + unionB - intersect; % union = A+B-(AB)
        sMatrix(i) = intersect/union;
        if sMatrix(i) > 1
            disp('error, this value should be normalized');
        end
        
    end
    
end

s = sum(sMatrix);
if s == size(A,1)*(-lambda) %if no overlap, use total dissimilarity value
    s=-inf;
end

    
    
end
