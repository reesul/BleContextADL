%% calculate statistics for the confusion matrix cm
function [acc, wacc, acc_per, f1, wf1, f1_per] = cmStats(cm)

positives = sum(cm,2);
numInstances = sum(positives);

acc_per = zeros(length(cm),1);
for i=1:size(cm,2)
    acc_per(i) = cm(i,i)/positives(i);
    if isnan(acc_per(i))
        acc_per(i) = 0;
    end
end
acc = mean(acc_per);
wacc = sum(positives.*acc_per)/numInstances; %weighted average accuracy

f1_per = zeros(size(acc_per));
recall = zeros(length(cm),1); %uses false negative
precision = zeros(size(recall)); %uses false positive

for i=1:size(cm,2)
    precision(i) = cm(i,i) / sum(cm(:,i)); %false positive reate
    recall(i) = cm(i,i) / sum(cm(i,:)); %false negative rate
    f1_per(i) = harmmean([precision(i), recall(i)]); %f1 is harmonic mean
    
    if isnan(f1_per(i))
        f1_per(i) = 0;
    end
end

f1 = mean(f1_per);
wf1 = sum(positives.*f1_per)/numInstances; %weighted average f1

end