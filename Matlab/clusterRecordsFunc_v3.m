% clear 
% %load('TRAIN.mat')
% load('HAC_patterns.mat');
% load('activityLAbelNames.mat');
% recordLabels = trainingLabels;
%recordLabels = trainLabels';
%recordMtx=recordMtxTrain;
% recordMtx = trainingRecordMtx;
function[Patterns] = clusterRecordsFunc_v3(recordLabels, recordMtx, activityLabelNames, iouThresh, isSingle)

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
Patterns={};
for act = 1:length(activityLabelNames)
    activity = act; % specify activity
    
    l = activityLabelNames{activity};
    binLabels = binaryLabels(l, recordLabels)';
    rec = recordMtx(binLabels,:);
    rec_not = recordMtx(~binLabels,:);
%     [ind,rec] = activityWiseSeparation(recordMtx,label,activity,0);
% %     display('----------------------------------------------------------------------------------')
%     display(activityLabelNames{act});
%     [ind_not,rec_not] = activityWiseSeparation(recordMtx,label,activity,1);
% %     display(['not ',activityLabelNames{act}]);

    %%
    prob_threshold = 0.02;
    aux_thresh = 1/size(rec,1);
    if prob_threshold < aux_thresh
        prob_threshold = aux_thresh;
    end
    
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
    
    if isSingle
        Patterns{end+1} = list';
        continue;
    end

    [TP_init,FP_init,PLR_init] = PLR_OR(list,rec,rec_not);

    LIST={};
%     LIST{end+1} = list;
    
    cluster_count = 1;
    inter_over_uni = 1;
    TP_TOT = TP_init;
    m = length(list);
    PLR_tmp = zeros(m,m);
    TP_tmp = zeros(m,m);
    FP_tmp = zeros(m,m);
    IoU_tmp = zeros(m,m);
    score = zeros(m,m);
    for i=1:m
        for j=i+1:m
            [TP_tmp(i,j),FP_tmp(i,j),PLR_tmp(i,j)] = PLR([list{i},list{j}],rec,rec_not);
            [TP_union,FP_union,PLR_union] = PLR_OR({list{i},list{j}},rec,rec_not);
            IoU_tmp(i,j) = TP_tmp(i,j)/TP_union;
        end
    end
    
    %find a pattern to join
    [~,ind]=max(IoU_tmp);
    [~,col]=max(max(IoU_tmp));
    row = ind(col);
    [T,F,P] = PLR(list{row},rec,rec_not);
    [T2,F2,P2] = PLR(list{col},rec,rec_not);
    [T3,F3,P3] = PLR(unique([list{row},list{col}]),rec,rec_not);
    list{end+1}=[list{row},list{col}];

    %I suppose add a pattern here to simulate do while loop
    inter_over_uni = IoU_tmp(row,col)
    if inter_over_uni < iouThresh
        disp('no good pattern to join..');
    end
    TP1 = T
    TP2 = T2
    TP_comb = T3
    IoU = IoU_tmp(row,col);
    IoU_tmp(row,col) = -1;
    LIST{end+1}=list;

    while  inter_over_uni>iouThresh %main pattern joining loop
            cluster_count = cluster_count+1
            m = length(list)-1;
            PLR_tmp2 = zeros(m,1);
            TP_tmp2 = zeros(m,1);
            FP_tmp2 = zeros(m,1);
            IoU_tmp2 = zeros(m,1);
            for i=1:m
                    if length(intersect(list{i},list{end})) == length(list{i}) || exist_pattern(unique([list{row},list{col}]),list)
                    else
                        [TP_tmp2(i,1),FP_tmp2(i,1),PLR_tmp2(i,1)] = PLR([list{i},list{end}],rec,rec_not);
                        [TP_union,FP_union,PLR_union] = PLR_OR({list{i},list{end}},rec,rec_not);
                        IoU_tmp2(i,1) = TP_tmp2(i,1)/TP_union;
                    end
            end
            IoU_tmp=[IoU_tmp;zeros(1,m)];
            IoU_tmp=[IoU_tmp,[IoU_tmp2;0]];

                [~,ind]=max(IoU_tmp);
                [~,col]=max(max(IoU_tmp));
                row = ind(col);
                [T,F,P] = PLR(list{row},rec,rec_not);
                [T2,F2,P2] = PLR(list{col},rec,rec_not);
                [T3,F3,P3] = PLR(unique([list{row},list{col}]),rec,rec_not);

            list{end+1}=unique([list{row},list{col}]);

            inter_over_uni = IoU_tmp(row,col)
            TP1 = T
            TP2 = T2
            TP_comb = T3
            IoU = [IoU,IoU_tmp(row,col)];
            IoU_tmp(row,col) = -1;
            LIST{end+1}=list;
    end
    % u = 2;
    % check = 1;
    % while u<cluster_count && check
    %     if PLR_total(u)> PLR_total(u+1) && PLR_total(u) > PLR_total(u-1)
    %         check = 0; 
    %     else
    %         u = u + 1;
    %     end
    % end
    % if length(LIST) == 1
     Patterns{end+1} = getPatternStats(LIST{end}', rec, rec_not);
     

end

% A = figure()
% plot([PLR_init;PLR_total])
% hold on
% plot([TP_init;TP_total])
% plot([FP_init;FP_total])
% legend('Positive Likelihood','True Positive Coverage','False Positive Coverage');
% title(activityLabelNames{activity})

% q=1;
% while q <length(Patterns{end}) % removing clusters
%     [t,f,p] = PLR(Patterns{end}{q},rec,rec_not);
%     if t-f < 0.015 || f>0.4  % removes the one that have FP>40% or TP-FP less than 1.5%
%        if q<length(Patterns{end})
%         for e = q:length(Patterns{end})-1
%             Patterns{end}{e} = Patterns{end}{e+1};
%         end
%         end
%         Patterns{end}(end) = [];
%     else
%      q = q+1;
%     end
% end


Patterns = Patterns'