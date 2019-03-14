%  clear 
% %load('TRAIN.mat')
% load('HAC_patterns.mat');
% load('activityLAbelNames.mat');
function [Patterns] = clusterRecordsFunc_v2(recordLabels, recordMtx, activityLabelNames, isSingle)

% recordLabels = trainingLabels;
%recordLabels = trainLabels';
%recordMtx=recordMtxTrain;
% recordMtx = ;
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
TP_threshold = 0.97;
Patterns={};
% ruleSets = cell(length(activityLabelNames),1);
for act = 1:9
    activity = act; % specify activity

    l = activityLabelNames{activity};
    binLabels = binaryLabels(l, recordLabels)';
    rec = recordMtx(binLabels,:);
    rec_not = recordMtx(~binLabels,:);
    % [ind,rec] = activityWiseSeparation(recordMtx,label,activity,0);
    % display(activityLabelNames{act});
    % [ind_not,rec_not] = activityWiseSeparation(recordMtx,label,activity,1);
    % display(['not ',activityLabelNames{act}]);
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
    
    if isSingle
        Patterns{end+1} = list;
        continue;
    end

    [TP_init,FP_init,PLR_init] = PLR_OR(list,rec,rec_not);

    M = length(list);
    PLR_total=zeros(M,1);
    TP_total=zeros(M,1);
    FP_total=zeros(M,1);
    PLR_combine=zeros(M,1);
    TP_combine=zeros(M,1);
    FP_combine=zeros(M,1);
    IoU = zeros(M,1);
    LIST={};
    cluster_count = 0;
    inter_over_uni = 1;
    TP_TOT = TP_init;
    
    iouThresh = 0.75;
    while cluster_count <= M-1 && inter_over_uni>iouThresh && TP_TOT>TP_threshold*TP_init %stop condition for clustering
        cluster_count = cluster_count+1
            LIST{end+1}=list;
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
                    score(i,j) = IoU_tmp(i,j) ; %+ TP_tmp(i,j) - 0.2*FP_tmp(i,j);
                end
            end
    %         if max(max(score)) > 0
                [~,ind]=max(score);
                [~,col]=max(max(score));
                row = ind(col);
                [T,F,P] = PLR(list{row},rec,rec_not);
                [T2,F2,P2] = PLR(list{col},rec,rec_not);
    %         else
    %             [~,ind]=min(abs(PLR_tmp));
    %             [~,col]=min(min(abs(PLR_tmp)));
    %             row = ind(col);
    %         end
            PLR_combine(cluster_count)=score(row,col);
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
            inter_over_uni = IoU_tmp(row,col);
            TP1 = T;
            TP2 = T2;
            TP_comb = TP_combine(cluster_count);
            IoU(cluster_count) = IoU_tmp(row,col);
            [TP_total(cluster_count),FP_total(cluster_count),PLR_total(cluster_count)] = PLR_OR(list,rec,rec_not);
            TP_TOT = TP_total(cluster_count);
    end
    u = 2;
    check = 1;
    while u<cluster_count && check
        if PLR_total(u)> PLR_total(u+1) && PLR_total(u) > PLR_total(u-1) % detect peak
            check = 0; 
        else
            u = u + 1;
        end
    end
    if length(LIST) == 1
        patt = getPatternStats(LIST{1}, rec, rec_not);
%         Patterns{end+1} = LIST{1}';
        Patterns{end+1} = LIST{1}';
    else
        if check
        Patterns{end+1} = LIST{u}';
        else
        Patterns{end+1} = LIST{u-1}';
        end
    end
    % A = figure()
    % plot([PLR_init;PLR_total])
    % hold on
    % plot([TP_init;TP_total])
    % plot([FP_init;FP_total])
    % legend('Positive Likelihood','True Positive Coverage','False Positive Coverage');
    % title(activityLabelNames{activity})
    q=1;
%     while q <length(Patterns{end}) % removing clusters
%         [t,f,p] = PLR(Patterns{end}{q},rec,rec_not);
%         %unsure about below condition
%         if (t-f) < 0.015 || f>0.4  % removes the one that have FP>40% or TP-FP less than 1.5%. RG: this could go negative though - any FP > TP removes patterns
%            if q<length(Patterns{end})
%             for e = q:length(Patterns{end})-1
%                 Patterns{end}{e} = Patterns{end}{e+1};
%             end
%             end
%             Patterns{end}(end) = [];
%         else
%             
%            
%             
%          q = q+1;
%         end
%     end
    
    Patterns{end} = getPatternStats(Patterns{end}, rec, rec_not);
end


%RG: Correct formatting of pattern set to match functions moving forward
retPatterns = cell(fliplr(size(Patterns)));
for i=1:size(Patterns,2)
    retPatterns{i} = Patterns{i}';
end
Patterns = retPatterns;

end
