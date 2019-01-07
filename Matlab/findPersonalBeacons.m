function [pBeacons] = findPersonalBeacons(classLabels, records)

recordMtxFull = recordMatrix(records)

%initialize
recordMtxs = cell(length(classLabels),1);
ruleSets = cell(length(classLabels),2);
beaconSet = cell(length(classLabels),1);

%build a set of rules for each class, setup their examples, and save all
%beacons that were considered for those rules
for i=1:length(classLabels)
    label = classLabels{i}
    %get a matrix for this particular class
    recordMtxs{i} = getClassMtx(label, records, recordMtxFull);
    ruleSets(i,:) = {createRules_v2(records, classLabels(i))};
    
    
    ruleBeacons = ruleSets{i,1}(:,1)  %set of beacons used for the ruleset of this clas
    s = sum(recordMtxs{i});
    beaconSet{i} = find(s); % the beacons actually detected in this class's examples
end

fprintf('look for beacons shared across many classes');

for i=1:length(classLabels)-1
    bi = beaconSet{i};
    li = classLabels{i};
    for j = i+1:length(classLabels)
        lj = classLabels{j};
        bj = beaconSet{j};
        
        intersection = max(sum(ismember(bi,bj), sum(ismember(bj, bi))))
        intersectBeacons = intersect(bi,bj)
        iou = intersection / (length(bi) + length(bj) - intersection)
        
    end
end

end

function classRecordMtx = getClassMtx(classLabel, records, recordMtxFull)

binLabels = binaryLabels(classLabel, records(end-1,:));
classRecordMtx = recordMtxFull(binLabels,:);

end