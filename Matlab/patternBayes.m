function [P, mergedPatterns, rawPatterns, stats] = patternBayes(ruleSets, records, classLabels)

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
noDuplicatePatterns = cell(0,2);
%% Remove the duplicates from that merged set
% There could be duplicate patterns learned from different activities
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
prA = 1/numActivities;
P = zeros(numActivities, size(mergedPatterns,1));

for i=1:size(mergedPatterns,1)
    pattern = mergedPatterns{i,1};
    coverage = zeros(numActivities,1);
    
    for j=1:numActivities
        binLabel = binLabelsAll{j};
        activityRecordMtx = recordMtx(binLabel,:);
        numInstances = size(activityRecordMtx,1);
        
        coverage(j) = sum(all(activityRecordMtx(:,pattern),2))/numInstances;
        
    end
    
    for j=1:length(classLabels)
        P(j,i) = coverage(j) / sum(coverage);
    end
end


giniOfPatterns = zeros(1,size(P,2)); 
entropyOfPatterns = zeros(1,size(P,2));
for i = 1:size(P,2)
    [giniOfPatterns(i), entropyOfPatterns(i)] = patternEvalIndexes(P(:,i));
end

stats = [giniOfPatterns; entropyOfPatterns];

return;
end




% %% old portion
% 
% % P = cell(size(ruleSets));
% for i=1:numActivities
%     %get the instances that correspond to this class only
%     label = classLabels(i);
%     binLabels = binaryLabels(label, records(end-1,:));
%     notLabel = ~binLabels;
%    
%     
%     classRecords = records(:,binLabels);
%     classRecordMtx = recordMtx(binLabels,:);
%     notClassRecords = records(:, notLabel);
%     notClassRecordMtx = recordMtx(notLabel, :);
%     
%     numInstances = sum(binLabels);
%     numNotClassInstances = sum(notLabel);
%     patterns = ruleSets{i};
%     prob = cell(size(patterns,1),1);
%     
%     for j=1:size(patterns,1)
%         rule = patterns{j,1}; %the context-identifiers that make up a rule/pattern
% 
%         % trying a per-class approach to modeling P(pattern)
%         coverage = zeros(numActivities,1);
%         for k=1:numActivities
%             bl = binLabelsAll{k};
%             classRecordMtx = recordMtx(bl,:);
%             numInstances = sum(bl);
%             
%             coverage(k) = sum(all(classRecordMtx(:,rule),2))/numInstances;
%         end
%         
%         prob{j} = coverage(i)/sum(coverage);
%         %
%         
% % %         coverage = sum(all(classRecordMtx(:,rule),2))/numInstances;
% % %         notClassCoverage = sum(all(notClassRecordMtx(:,rule),2))/numNotClassInstances;
% % 
% %         %calculate bayes probability of P(Activity|pattern)
% %         % P(A|p) = P(p|A)*P(A)/P(p); P(p|A) is coverage, P(A) is uniform
% %         prob{j} = coverage*pClass;
% %         %then divide by P(p). **Perhaps doing this per-class would be
% %         %better than class A vs. NOT class A
% %         prob{j} = prob{j} / (prob{j} + notClassCoverage*(1-pClass));
%         
%     end
%     
%     P{i} = prob;
% end
% 
% 
% end

function [gini, entropy] = patternEvalIndexes(p)

gini = sum(p.*(1-p));
entropy = 0;
for i=1:length(p)
    if p(i) > 0
        entropy = entropy - p(i)*log(p(i))/log(length(p));
    end
end

    
end