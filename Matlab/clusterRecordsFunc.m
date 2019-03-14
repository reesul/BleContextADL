function [ruleSets] = clusterRecordsFunc(recordLabels, recordMtx, activityLabelNames, isSingle)
% clear 
% load('TRAIN.mat')
% recordLabels = trainLabels';
% recordMtx=recordMtxTrain;
n = size(recordLabels,1);
label = zeros(n,1);
for i = 1:n
    for j = 1:size(activityLabelNames,2)
        if string(recordLabels(i)) == activityLabelNames(j)
            label(i) = j;
        end
    end
end
% ---------------------------------------------------------------------------------------
%%
ruleSets = cell(length(activityLabelNames),1);
for activity=1:length(activityLabelNames)
%     activity = 9; % specify activity
    l = activityLabelNames{activity};
    binLabels = binaryLabels(l, recordLabels)';
    rec = recordMtx(binLabels,:);
    rec_not = recordMtx(~binLabels,:);
%     [ind,rec] = activityWiseSeparation(recordMtx,label,activity,0);
%     display('Rec');
%     [ind_not,rec_not] = activityWiseSeparation(recordMtx,label,activity,1);
%     display('Rec_not');
    %%
    prob_threshold = 0.02;
    n = size(recordMtx,2);
    PLR_array = zeros(n,1);
    TP = zeros(n,1);
    FP = zeros(n,1);
    for i=1:n
          [TP(i),FP(i),PLR_array(i)] = PLR(i,rec,rec_not);
    end

    list={};
    for i=1:length(PLR_array)
        if TP(i)>prob_threshold
            list{end+1}=i;
        end
    end

    [TP_init,FP_init,PLR_init] = PLR_OR(list,rec,rec_not);

    M = length(list);
    PLR_total=zeros(M,1);
    TP_total=zeros(M,1);
    FP_total=zeros(M,1);
    PLR_combine=zeros(M,1);
    TP_combine=zeros(M,1);
    FP_combine=zeros(M,1);
    LIST={};
    for cluster_count = 1:M-1
        cluster_count
            LIST{end+1}=list;
            m = length(list);
            PLR_tmp = zeros(m,m);
            TP_tmp = zeros(m,m);
            FP_tmp = zeros(m,m);
            for i=1:m %compare (n choose 2) clusters
                for j=i+1:m
                    [TP_tmp(i,j),FP_tmp(i,j),PLR_tmp(i,j)] = PLR([list{i},list{j}],rec,rec_not);
                end
            end
            if max(max(PLR_tmp)) > 0 %find cluster pair to merge (row, column pair)
                [~,ind]=max(PLR_tmp);
                [~,col]=max(max(PLR_tmp));
                row = ind(col);
            else
                [~,ind]=min(abs(PLR_tmp));
                [~,col]=min(min(abs(PLR_tmp)));
                row = ind(col);
            end
            PLR_combine(cluster_count)=PLR_tmp(row,col);
            TP_combine(cluster_count)=TP_tmp(row,col);
            FP_combine(cluster_count)=FP_tmp(row,col);
            list{end+1}=[list{row},list{col}];
            if row>col
                list(row)=[];
                list(col)=[];
            else
                list(col)=[];
                list(row)=[];
            end
            [TP_total(cluster_count),FP_total(cluster_count),PLR_total(cluster_count)] = PLR_OR(list,rec,rec_not);

    end
    figure(1);
    clf;
    plot([PLR_init;PLR_total])
    hold on
    plot([TP_init;TP_total])
    plot([FP_init;FP_total])
    legend('Positive Likelihood','True Positive Coverage','False Positive Coverage');
    title(activityLabelNames{activity})

    %make decision on the cut.... TODO: make this adaptive to statistics in
    %the record
    saveList = {};
    if isSingle
        saveList = LIST{1}';
    else
        PLR_cut = PLR_total ./ PLR_init;
        lowPLRChangeInd = sum(PLR_cut > 0.95); %non-increasing, so the sum is also the last index that is good enough for this threshold
        if lowPLRChangeInd
            saveList = LIST{lowPLRChangeInd}';
        else
            saveList = LIST{1}';
        end
    end
    
    TP_end = cell(size(saveList));
    FP_end = cell(size(saveList));
    PLR_end = cell(size(saveList));
    for i=1:length(saveList)
        [TP_end{i}, FP_end{i}, PLR_end{i}] = PLR(saveList{i}, rec, rec_not);
    end
    saveList = [saveList, TP_end, FP_end, PLR_end];
        
    ruleSets{activity} = saveList;
end
