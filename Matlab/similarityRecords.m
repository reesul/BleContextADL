%% calculate similarity values between nodes of the graph
%   Similarity is calculated as the intersect over union of two binary
%   vectors (i.e. Tanimoto simiarlity coefficient), input to a logarithm
%   function whose purpose is to map values near 0 to -inf and values near
%   1 to some positive, finite value. 1/beta is a threshold giving
%   similarity of 0
%
% Input: records: is a cell, first element is date, second timestamp of
%   record, 3rd is a bit vector (the useful part), and 4th is a value used
%   for filtering data
%  alpha: scaling factor outside of log function
%  beta: scaling factor inside of log function
%
% Output: S is a square matrix describing the similarity between each set of
%   records, based on the beacons detected within that record

function [S] = similarityRecords(records, alpha, beta)

S = zeros(length(records));

%only upper-right diagonal as this is a symmetric matrix; diagonal not
%needed for affinity propagation algo
for i=1:(length(S))
    for j=(i+1):length(S)
        
        r1 = records{3,i};
        r2 = records{3,j};
        S(i,j) = calculateSim(r1, r2, alpha, beta);
        
    end
end




end


%% utilitze a Tanimoto coefficient as the base of this similarity metric
function [s] = calculateSim(r1,r2,a,b)

bitAnd = and(r1,r2)
tanimoto = sum(bitAnd)/(sum(r1)+sum(r2)-sum(bitAnd));

s = a*log(tanimoto*b);

end

