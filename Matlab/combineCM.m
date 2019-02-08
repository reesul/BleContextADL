%combine confusion matrices

%% Using greedy method
%using test set, context features included
CMclass = [0   1   0   0   0   0   0   0   0;   0 313   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   3   0   0   0   0   0   0   0];
CMclass_meeting =  [0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 ;0 0 0 0 0 9 0 0 0;0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0];
CMclass_walking = [0  0  0  0  0  0  0  0  0  ;0 37  0  0  0  0  0  0  0;0 0  0  0  0  0  0  0  0 ;0  0  0  0  0  0  0  0  0;0  0  0  0  0  0  0  0  0;0  0  0  0  0  0  0  0  0;0  0  0  0  0  0  0  0  0;0  0  0  0  0  0  0  0  0;0  0  0  0  0  0  0  0  2];
CMcooking_schoolwork = [0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0  39   0   0   0   0   2   0;   0   0   2   0   0   0   0   3   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0  17   0   0   0   0 393   0;   0   0   0   0   0   0   0   0   0];
CMdriving = [ 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 8 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMexercising = [   0   0   0   0   1   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   1   0   0   0   0;   0   0   0   0 272   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMmeeting = [ 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 7 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMmeeting_research = [   0   0   0   0   0   0   3   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0  27 562   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMnull = [27  3  0  0  0  0  4  0  2;  2 27  0  1  0  4  3  0  1;  0  0  0  0  0  0  0  0  0;  1  1  0  6  0  0  6  0  1;  0  0  0  0  5  0  0  0  0;  0 16  0  3  0  1  7  0  0;  1  1  0  1  0  0 13  0  1;  0  0  0  0  0  0  0  0  0;  0  5  0  1  0  0  0  0  9];
CMtotalContextGreedy = CMclass+CMclass_meeting+CMclass_walking+CMcooking_schoolwork+CMdriving+CMexercising+CMmeeting+CMmeeting_research+CMnull;
[acc, wacc, acc_per, f1, wf1, f1_per] = cmStats(CMtotalContextGreedy)
contextGreedyResults = {acc_NoCF, wacc_NoCF, acc_per_NoCF, f1_NoCF, wf1_NoCF, f1_per_NoCF};


% test set, context features omitted
CMclass = [   0   1   0   0   0   0   0   0   0;   0 313   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   3   0   0   0   0   0   0   0];
CMclass_meeting =  [0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 3 0 0 0 6 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMclass_walking =   [0  0  0  0  0  0  0  0  0;  0 37  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  2];
CMcooking_schoolwork = [0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0  24   0   0   0   0  17   0;   0   0   1   0   0   0   0   4   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   5   0   0   0   0 405   0;   0   0   0   0   0   0   0   0   0];
CMdriving =  [0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 8 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMexercising = [   0   0   0   0   1   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   1   0   0   0   0;   0   0   0   0 272   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMmeeting = [ 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 7 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMmeeting_research = [   0   0   0   0   0   0   3   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0  27 562   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMnull = [ 27  4  0  0  0  0  4  0  1;  0 19  0  1  1  0 13  4  0;  0  0  0  0  0  0  0  0  0;  1  2  0  6  2  0  1  0  3;  0  0  0  0  4  0  1  0  0;  1  2  0  1  0 20  3  0  0;  0  1  0  0  0  3 13  0  0;  0  0  0  0  0  0  0  0  0;  0  2  0  0  1  0  0  0 12];
CMtotalNoContextGreedy = CMclass+CMclass_meeting+CMclass_walking+CMcooking_schoolwork+CMdriving+CMexercising+CMmeeting+CMmeeting_research+CMnull;
[acc_NoCF, wacc_NoCF, acc_per_NoCF, f1_NoCF, wf1_NoCF, f1_per_NoCF] = cmStats(CMtotalNoContextGreedy)
noContextGreedyResults = {acc_NoCF, wacc_NoCF, acc_per_NoCF, f1_NoCF, wf1_NoCF, f1_per_NoCF};

%% Hierarchical clustering method
%using context features
CMclass = [   0   0   0   0   0   0   0   0   0;   0 263   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   1   0   0   0   0   0   0   0];
CMclass_meeting = [  0  1  0  0  0  0  0  0  0;  0 11  0  0  0  2  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  3  0  0  0  6  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  1  0  0  0  0  0  0  0];
CMclass_walking = [  0  0  0  0  0  0  0  0  0;  0 19  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0];
CMcooking_schoolwork = [   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   2   0   0   0   0  39   0;   0   0   0   0   0   0   0   3   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   5   0   0   0   0 379   0;   0   0   0   0   0   0   0   0   0];
CMexercising =[   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   1   0   0   0   0;   0   0   0   0 272   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMmeeting_research = [   0   0   0   0   0   0   4   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0  34 552   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMnull = [ 18  7  0  6  0  1  4  0  1;  5 65  0  6  5  6  6  0  0;  0  0  0  0  0  0  0  0  0;  2  8  0  9  2  0  3  1  0;  0  1  0  0  4  0  0  0  0;  0 17  0  1  1 13  2  0  0;  0  4  0  0  0  1 12  0  0;  0  0  0  0  0  0  0 26  0;  0  7  0  1  0  0  2  0  5];
CMresearch = [ 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 3 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMtotalContextHAC = CMclass+CMclass_meeting+CMclass_walking+CMcooking_schoolwork+CMexercising+CMmeeting_research+CMnull+CMresearch
[acc_CF, wacc_CF, acc_per_CF, f1_CF, wf1_CF, f1_per_CF] = cmStats(CMtotalContextHAC)
noContextHACResults = {acc_CF, wacc_CF, acc_per_CF, f1_CF, wf1_CF, f1_per_CF};

%using no context features; only IMU and statistical BLE
CMclass = [   0   0   0   0   0   0   0   0   0;   0 263   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   1   0   0   0   0   0   0   0];
CMclass_meeting = [  0  1  0  0  0  0  0  0  0;  0 12  0  0  0  1  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  2  0  0  0  7  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  1  0  0  0  0  0  0  0];
CMclass_walking = [  0  0  0  0  0  0  0  0  0;  0 19  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0;  0  0  0  0  0  0  0  0  0];
CMcooking_schoolwork =  [  0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0  19   0   0   0   0  22   0;   0   0   0   0   0   0   0   3   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0  11   0   0   0   0 373   0;   0   0   0   0   0   0   0   0   0];
CMexercising = [   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   1   0   0   0   0;   0   0   0   0 272   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMmeeting_research = [   0   0   0   0   0   1   3   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0  35 551   0   0;   0   0   0   0   0   0   0   0   0;   0   0   0   0   0   0   0   0   0];
CMnull = [ 19  3  0  6  0  1  4  0  4;  3 49  1  0 10  4 18  4  4;  0  0  0  0  0  0  0  0  0;  4  4  0  9  3  0  3  0  2;  0  2  0  0  2  0  1  0  0;  0  1  0  0  0 22 11  0  0;  2  4  0  0  2  3  6  0  0;  0  6  0  0  0  0  9 11  0;  1  2  0  1  0  0  1  0 10];
CMresearch = [ 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 3 0 0; 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0];
CMtotalContextHAC = CMclass+CMclass_meeting+CMclass_walking+CMcooking_schoolwork+CMexercising+CMmeeting_research+CMnull+CMresearch
[acc_NoCF, wacc_NoCF, acc_per_NoCF, f1_NoCF, wf1_NoCF, f1_per_NoCF] = cmStats(CMtotalContextHAC)
noContextHACResults = {acc_NoCF, wacc_NoCF, acc_per_NoCF, f1_NoCF, wf1_NoCF, f1_per_NoCF};


%% calculate statistics for the confusion matrix cm
function [acc, wacc, acc_per, f1, wf1, f1_per] = cmStats(cm)

positives = sum(cm,2);
numInstances = sum(positives);

acc_per = zeros(length(cm),1);
for i=1:size(cm,2)
    acc_per(i) = cm(i,i)/positives(i);
end
acc = mean(acc_per);
wacc = sum(positives.*acc_per)/numInstances;

f1_per = zeros(size(acc_per));
recall = zeros(length(cm),1); %uses false negative
precision = zeros(size(recall)); %uses false positive
for i=1:size(cm,2)
    precision(i) = cm(i,i) / sum(cm(:,i));
    recall(i) = cm(i,i) / sum(cm(i,:));
    f1_per(i) = harmmean([precision(i), recall(i)]);
end

f1 = mean(f1_per);
wf1 = sum(positives.*f1_per)/numInstances

end

