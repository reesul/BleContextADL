function [apOutput, thresholdClusters, originalClusters] = bleAPCluster(S, N, varargin)

%setup parameters
damp=0.9; minClusterSize=-1; scalingFactor=1; reformat = false; useMedian = false;%some defaults
i=1;
while i<=length(varargin)
    if strcmp(varargin{i}, 'Threshold size')
        minClusterSize = varargin{i+1};
        i=i+2;
    elseif strcmp(varargin{i}, 'scalingFactor')
        scalingFactor=varargin{i+1};
        i=i+2;
    elseif strcmp(varargin{i}, 'damp')
        damp=varargin{i+1};
        i=i+2;
    elseif strcmp(varargin{i}, 'AP reformat')
        reformat = true;
        i=i+1;
    elseif strcmp(varargin{i}, 'median pref')
        useMedian = true;
        i=i+1;
    else
        i=i+1;
    end
    
end

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
SAP = zeros(N^2-N, 3);
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
size(SAP);

%resize based on j
SAP = SAP(1:(j-1),:);
medianPref=median(SAP(:,3));

minimumPref = min(SAP(:,3));
    
if ~reformat
    SAP = S;
end
    
size(SAP);
% SAP(:,3)=nonzeros(SAP(:,3))
% size(SAP)

if useMedian
    P = medianPref;%*ones(N,1)*scalingFactor; %Use scalar value if using median ONLY
else
    P = minimumPref;
end
%S = S*scalingFactor;

%use plot to show net similarities, details for some extra debugging, and
%'nonoise' to make result entirely deterministic
[idx,netsim,dpsim,expref]=apcluster(SAP,P, 'maxits', 2000, 'dampfact', damp, 'nonoise');

apOutput = {idx,netsim,dpsim,expref};

numClusters = length(unique(idx))
originalClusters = cell(length(idx),1);

for i=1:length(idx)
    c = idx(i); %cluster for node i
    originalClusters{c} = [originalClusters{c}, i];
end

originalClusters = originalClusters(~cellfun(@isempty,originalClusters)); % remove empty clusters from the set

% Apply a minimum cluster size if applicable
thresholdClusters = {};
if minClusterSize > 0
    for i=1:length(originalClusters)

        if length(originalClusters{i}) >= minClusterSize
            thresholdClusters{end+1} = originalClusters{i};
        end

    end
    %numClusters = length(thresholdClusters)
end
    
end