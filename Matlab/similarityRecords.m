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
%   S_AP is formatted specifically for the affinity propagaton algorithm.
%   This format drastically reduces size

function [S] = similarityRecords(records, alpha, beta)

S = zeros(length(records));
N = length(records);
%S_AP = zeros(nchoosek(length(records),2),3); % format expected by affinity propagation

%only upper-right diagonal as this is a symmetric matrix; diagonal not
%needed for affinity propagation algo

%get the records a matrix for faster indexing
recordMtx = records(3,:);
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(records{3,1}),length(records)]);
recordMtx = recordMtx'; %transpose so a single record is a row; (index as i,:) for whole record i

% k=1;

for i=1:N
%     r1 = records{3,i};
    r1 = recordMtx(i,:);
    
    for j=(i+1):N %only need to get half of the matrix
        if i==j
            %These should get special treatment if they are to be used
            continue;
        end
        
%         r2 = records{3,j};
        r2 = recordMtx(j,:);
        
        %S(i,j) = calculateSim(r1, r2, alpha, beta);
        s = calculateSim(r1, r2, alpha, beta);
        if isnan(s)
            s=-inf;
        end
        S(i,j) = s;
        
        %S_AP matrix
%         if s > -inf
%             S_AP(k,1) = i;
%             S_AP(k,2) = j;
%             S_AP(k,3) = s;
%             k = k+1;
%         end
    end
end

S = S+S'; %symmetric matrix, so we can just add the transpose to fill out the other half

%S_AP = S_AP(1 : (find(S_AP(:,1),1,'last')) , :); %remove trailing zeros


end


%% utilitze a Tanimoto coefficient as the base of this similarity metric
function [s] = calculateSim(r1,r2,a,b)

bitAnd = and(r1,r2);
tanimoto = sum(bitAnd)/(sum(r1)+sum(r2)-sum(bitAnd));


s = a*log(tanimoto*b);

if isnan(tanimoto) || isnan(s)
    fprintf('nan\n');
end

end

