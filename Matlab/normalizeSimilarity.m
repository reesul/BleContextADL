function [normS, normFinalS] = normalizeSimilarity(S)

normS = zeros(size(S));

for i=1:size(S,1)
   normTo = S(i,i);
   
   vec = S(i,:);
   
   normVec = vec/normTo;
   normS(i,:) = normVec;
   
end

m=min(normS);
m=min(m);

if m==-inf
    %do something a little different in this scenario, get second smallest
    %value
    tempS = normS(:);
    tempS=sort(unique(tempS));
    m=tempS(2)
end

normFinalS = normS + abs(m);


end