function[aTable] = visualizeRules(ruleSet, labelName, records)

% binLabels = binaryLabels(classLabel, records(end-1,:));
% binLabelsInd = find(binLabels);

%makes it easy to find and count specific beacons in the examples
recordMtx = recordMatrix(records);

%reformat the set of rules
rules = ruleSet(:,1);
examples = ruleSet(:,2);
realExamples = [];
for e=1:length(examples)
    realExamples = [realExamples, examples{e}'];
end

% number of examples for A and not-A activities (labelName==A)
realExamples = unique(realExamples);
numExamples = length(realExamples);
numNotExamples = size(records,2) - numExamples;

ruleCoverage = zeros(length(rules),1);
fpCoverage = zeros(length(rules),1);
notA = cell(length(rules),1);
for r=1:length(rules)
    %calculate coverage rates
    ruleCoverage(r) = length(examples{r})/numExamples;
    fpCoverage(r) = sum(all(recordMtx(:, rules{r}),2)) - length(examples{r});
    fpCoverage(r) = fpCoverage(r)/numNotExamples;
    
    %get the set of activities this rules applies to besides A
%     coveredExamples = find(recordMtx(:,rules{r}))
    otherLabels = unique(records(end-1,  logical(all(recordMtx(:,rules{r}),2))));
    otherLabels = otherLabels(~strcmp(otherLabels, {labelName}));
    otherLabels = join(otherLabels,', ');
    if isempty(otherLabels)
        otherLabels = {''};
    end
    notA(r) = (otherLabels);
    
    
    
end

ruleCoverage;

clf;

if length(rules)==1
    hold on
    bar(1,ruleCoverage,'b')
    bar(2,fpCoverage,'r')
    set(gca, 'XTick', []);
    hold off
else
    barData = bar([ruleCoverage, fpCoverage]);
    xlabel('rule index');
end

legend1 = sprintf('%s', labelName);
legend2 = sprintf('NOT_%s', labelName);
legend({legend1, legend2})
ylabel('coverage (%)');
titl = sprintf('%s rules', labelName);
title(titl);

ruleIndex = [1:length(rules)]';
varName = {'ruleNumber', 'coverage', 'falsePositive', legend2};
aTable = table(ruleIndex, ruleCoverage, fpCoverage, notA, 'VariableNames', varName);

x=1; %for debugging; place breakpoint on this statement
end