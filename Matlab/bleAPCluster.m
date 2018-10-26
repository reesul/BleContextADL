function [apOutput, thresholdClusters, originalClusters] = bleAPCluster(S, varargin)

%setup parameters
damp=0.5; minClusterSize=15; scalingFactor=3;
i=1;
while i<=length(varargin)
    if strcmp(varargin{i}, 'clusterSize')
        minClusterSize = varargin{i+1};
        i=i+2;
    elseif strcmp(varargin{i}, 'scalingFactor')
        scalingFactor=varargin{i+1};
        i=i+2;
    elseif strcmp(varargin{i}, 'damp')
        damp=varargin{i+1};
        i=i+2;
    else
        i=i+1;
    end
    
    
end

N=length(S);
SAP = zeros(N^2-N, 3);


%ignore, template
% N=100; x=rand(N,2); % Create N, 2-D data points
% M=N*N-N; s=zeros(M,3); % Make ALL N^2-N similarities
% j=1;
% for i=1:N
%   for k=[1:i-1,i+1:N]
%     s(j,1)=i; s(j,2)=k; s(j,3)=-sum((x(i,:)-x(k,:)).^2);
%     j=j+1;
%   end;
% end;
% p=median(s(:,3)); % Set preference to median similarity

j=1;
for i=1:N
    for k=[1:i-1,i+1:N]
        if S(i,k) ~= -inf
            SAP(j,1) = i;
            SAP(j,2) = k;
            SAP(j,3) = S(i,k);
            j=j+1;
        end
        
    end
end
size(SAP)
%resize based on j
SAP = SAP(1:(j-1),:);

size(SAP)
% SAP(:,3)=nonzeros(SAP(:,3))
% size(SAP)

m=median(SAP(:,3))
P = m*ones(N,1)*scalingFactor;
%S = S*scalingFactor;



[idx,netsim,dpsim,expref]=apcluster(S,P, 'maxits', 1000, 'dampfact', damp, 'plot', 'nonoise');

apOutput = {idx,netsim,dpsim,expref};

numClusters = length(unique(idx))
originalClusters = cell(length(S),1);

for i=1:N
    c = idx(i);
    originalClusters{c} = [originalClusters{c}, i];
end

thresholdClusters = {};
newOGclusters = {};
for i=1:N
    
    if length(originalClusters{i}) > 0
        newOGclusters{end+1} = originalClusters{i};
    end
    if length(originalClusters{i}) >= minClusterSize
        thresholdClusters{end+1} = originalClusters{i};
    end
     
end
numClusters = length(thresholdClusters)
originalClusters = newOGclusters;