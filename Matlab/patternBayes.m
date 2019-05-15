%% Calculate activity-context probabilities for each pattern founds
function [P, mergedPatterns, rawPatterns] = patternBayes(ruleSets, records, classLabels)

numActivities = length(ruleSets);

%% First mege all of the rule sets into a single set
mergedPatterns = cell(0,size(ruleSets{1},2));

for i=1:size(ruleSets,1)
    rs = ruleSets{i};
%     rs{:} = classLabels(i)
    originLabel = cell(size(rs,1), 1);
%     originLabel = classLabels(i);
    if size(ruleSets{i},2)>size(ruleSets{i},1) %handle transposed patterns
        mergedPatterns = [mergedPatterns; ruleSets{i}(1,:)'];
    else
        mergedPatterns = [mergedPatterns; [ruleSets{i}, originLabel]];
    end
end

rawPatterns = mergedPatterns;
if size(mergedPatterns,2)>1
    mergedPatterns = mergedPatterns(:,1:2);
end

%% Remove the duplicates from that merged set
% There could be duplicate patterns learned from different activities
noDuplicatePatterns = cell(0,2);
for i=1:size(mergedPatterns,1)
    p = mergedPatterns{i,1};
    isDuplicate = false;
    for j=1:size(noDuplicatePatterns)
      if isequal(p, noDuplicatePatterns{j,1})
          isDuplicate = true;
      end
    end
    
    if ~isDuplicate 
        %add to the set of non duplicate patterns
       noDuplicatePatterns(end+1,:) = mergedPatterns(i,:); 
    end
    
end

mergedPatterns = noDuplicatePatterns; %this set without duplicates is the actual set of merged patterns

recordMtx = recordMatrix(records);


%vector of binary labels for each record; eases pr(A|pattern) calculation
binLabelsAll = cell(numActivities, 1);
for i=1:numActivities
   label = classLabels{i};
   binLabelsAll{i} = binaryLabels(label, records(end-1,:));
end
    

%% Calculate probability distribution for each pattern i.e. pr(activity A | pattern p)
% Use the relative (i.e. normalized) coverage of a pattern w.r.t an activity as pr(p|A)
% for a Bayesian probability
P = zeros(numActivities, size(mergedPatterns,1));

for i=1:size(mergedPatterns,1)
    pattern = mergedPatterns{i,1};
    coverage = zeros(numActivities,1); %calculate a relative coverage for each activity
    
    for j=1:numActivities
        binLabel = binLabelsAll{j};
        activityRecordMtx = recordMtx(binLabel,:);
        numInstances = size(activityRecordMtx,1);
        
        coverage(j) = sum(all(activityRecordMtx(:,pattern),2))/numInstances; %relative coverage; how many times this pattern occurred in all instances of this activity
        
    end
    
    for j=1:length(classLabels)
        P(j,i) = coverage(j) / sum(coverage); %probability of activity|pattern is relative coverage/sum(relative coverages)
    end
end


end

    