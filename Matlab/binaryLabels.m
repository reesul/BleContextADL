function [labels] = binaryLabels(targetLabel, labelOriginal)

labels = zeros(1,length(labelOriginal));

for i=1:length(labelOriginal)

    if strcmp(targetLabel, labelOriginal(i))
        labels(i) = 1;
    end

labels=logical(labels);
    
end