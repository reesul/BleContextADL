%% plotting tools for UbiComp submission
% This will probably need to be reused, especially the ones beyond the
% first section. 

%% horizontal bar graph showing number of performed activities
% just change the following two lines, and then the title
% labels = finalRecords(encd-1,:);
labelNames = activityLabelNames;


[labelNames, ~, ic] = unique(finalRecords(end-1,:));
% [~, ~, ic] = unique(labels);
countAct = [];
check = false(length(labelNames))
for i=1:length(labelNames)
    labelNames(i);
    if ismember(labelNames(i), activityLabelNames)
        countAct(end+1) = sum(ic==i);
        check(i) = 1;
    end
    if strcmp(labelNames(i), 'research')
        labelNames{i} = 'working'
    end
end
countAct = countAct(countAct>0);
labelNames=labelNames(check);

showTrTe = 0;

if ~showTrTe %show count for all activities
    tmp = countAct(end-2); countAct(end-2:end-1) = countAct(end-1:end); countAct(end) = tmp;
    tmp = labelNames(end-2); labelNames(end-2:end-1) = labelNames(end-1:end); labelNames(end) = tmp;
    barh(fliplr(countAct));
    xlabel('Number of Instances');
    ylabel('Activities');
    set(gca, 'ytick', 1:length(labelNames), 'yticklabel', fliplr(labelNames))

    titleName = sprintf('Subject %d Activity Distribution', subject);
    title(titleName)

else %show training set and testing set counts to diagnose imbalance there
    counts = zeros(length(activityLabelNames),1);
    counts=counts';
    for i=1:length(counts)
    counts(i) = sum(strcmp(activityLabelNames(i),trainingRecords(end-1,:)));
    end

    countsTe = zeros(length(activityLabelNames),1);
    countsTe=countsTe';
    for i=1:length(counts)
    countsTe(i) = sum(strcmp(activityLabelNames(i),testingRecords(end-1,:)));
    end
    
%     counts = fliplr([countAct; counts; countsTe])';
    counts = flipud(fliplr([counts; countsTe]))';
    
    barh(counts, 'grouped')
    xlabel('Number of Instances');
    ylabel('Activities');
    set(gca, 'ytick', [1:length(activityLabelNames)], 'yticklabel', fliplr(activityLabelNames))
    legend({'training', 'testing'})
    titleName = sprintf('Subject %d Activity Distribution', subject);
    title(titleName)
    
end
%% comparison of input modalities
%weighted f1-score
singleClassifierResults = [0.548	0.657	0.762	0.791 0.809	0.83  0.87	0.9356; ... %subject 1
    0.68, 0.66, 0.78, 0.795, 0.82, 0.835,  0.843, 0.877; ... %subject 2
    0.61, 0.49, 0.77, 0.78, 0.73, 0.80, 0.82, 0.854]' %subject 3

singleClassifierResults = [singleClassifierResults, mean(singleClassifierResults,2)]
singleClassifierLabels = {'IMU only', 'BLE statistics', 'Beacons as binary features',...
    'BLE statistics, Beacons as features', 'IMU and BLE statistics', 'IMU, Beacons as features',  ...
    'IMU, BLE statistics, Beacons as features', 'Our Method'} %same order as columns of results above

bar(singleClassifierResults, 'grouped')
ylabel('Weighted Average F-1 Score')
xlabel('Feature Set')
title('Comparison of Inputs Types')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Average', 'Location', 'northwest');
set(gca, 'xtick', 1:length(singleClassifierResults), 'xticklabel', singleClassifierLabels, 'XTickLabelRotation', 15)


%% comparison of context-separation methods
ContextSepResults = [0.87, 0.9323, 0.9323, .928, 0.9331, 0.9362; ... %subject 1
    0.84, 0.853, 0.853, .86, 0.87, 0.88; ...%subject 2
    0.82, 0.76, 0.76, 0.832, 0.824, 0.85]'; %subject 3

ContextSepResults = [ContextSepResults, mean(ContextSepResults,2)]; 

ContextSepLabels = {'Single Classifier', 'Basic Usage, Single-Beacon Patterns', 'Basic Usage, AHAC Patterns'...
    'ACP, HAC Patterns', 'ACP, Single-Beacon Patterns', ...
    'ACP, AHAC Patterns (Our Method)'};

% Use this to change colors; make sure it will be distinguishable enough in
% BW (different hue). DO THIS FOR ANY PLOT SHOWING MULIPLE SUBJECTS.
colors = colormap([0 0 1; 1 1 0; 1 1 1; 1 1 1]) %may need to change the color; use decimal number to specify r,g,b
hb = bar(ContextSepResults, 'grouped')
% hb(1).FaceColor = colors(1,:);
% hb(2).FaceColor = colors(2,:);
% hb(3).FaceColor = colors(3,:);
% hb(4).FaceColor = colors(4,:);


ylabel('Weighted Average F-1 Score')
xlabel('Approach')
title('Comparison of Context-Separation Approaches')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Average', 'Location', 'northwest');
set(gca, 'xtick', 1:length(ContextSepResults), 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.70 1])

%% Augmented data results

ContextSepResults = [0.84, 0.82, 0.82, .902, .9133, 0.9336; ... %subject 1
    0.80, 0.81, .81, .843, .855, .871; ... %subject 2
    0.80, 0.745, 0.745, 0.812, 0.824, 0.849]'; %subject 3

ContextSepResults = [ContextSepResults, mean(ContextSepResults,2)];

ContextSepLabels = {'Single Classifier', 'Basic Usage, Single-Beacon Patterns', 'Basic Usage, AHAC Patterns'...
    'ACP, HAC Patterns', 'ACP, Single-Beacon Patterns', ...
    'ACP, AHAC Patterns (Our Method)'};


% Use this to change colors; make sure it will be distinguishable enough in
% BW (different hue). DO THIS FOR ANY PLOT SHOWING MULIPLE SUBJECTS.
colors = colormap([0 0 1; 1 1 0; 1 1 1])
hb = bar(ContextSepResults, 'grouped')
% hb(1).FaceColor = colors(1,:);
% hb(2).FaceColor = colors(2,:);
% hb(3).FaceColor = colors(3,:);



ylabel('Weighted Average F-1 Score')
xlabel('Approach')
title('Comparison of Context-Separation Approaches on Augmented Dataset')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Location', 'northwest');
set(gca, 'xtick', 1:length(ContextSepLabels), 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.70 1])

%% per-activity f1 for each subject, without and with context
%note to future self: probably need to explicitly set the subject unless
%importing the proper workspace
if subject==1
    wwoContext = [0.727 0.737 0.608 0.666 	0.919 0.4	0.731 	0.608 ,0.826; ...
        0.7428 0.944 0.676 0.702 0.976 0.490 0.971 0.622 0.961];
    ADLlabels = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'schoolwork', 'walking', 'working'};
elseif subject ==2
     wwoContext = [0.7401	0.75	0.75	0.325	0.380	0.6266 0.788; ...
         0.942 0.866 0.814 0.534	0.935 0.733 0.922   ];
    ADLlabels = {'class', 'exercising', 'getting ready', 'meeting', 'shopping', 'walking', 'working'};
elseif subject==3
    wwoContext = [0.8368	0.5714	0.7207	0.4762	0.2705	0.6538	0.6774	0.7105	0.8619; ...
         0.974 0.7555 0.8112 0.6	0.5079 	0.792 	0.949	0.826  0.943 ];
    ADLlabels = {'class', 'cleaning', 'driving', 'eating', 'meeting', 'relaxing', 'shopping', 'walking', 'working'};
end

hb = bar(wwoContext', 'grouped')
ylabel('F-1 Score')
xlabel('ADL Label')
titleName = sprintf('Subject %d Performance With and Without Context', subject);
title(titleName);
legend('Without Context', 'With Context', 'Location', 'southoutside');
set(gca, 'xtick', 1:length(ADLlabels), 'xticklabel', ADLlabels, 'XTickLabelRotation', 30)
% set(gca, 'xtick', 1:length(ADLlabels), 'xticklabel', ADLlabels)

%% augmented performance per activity per subject

if subject==1
    contextSep = [0.759	0.877	0.000	0.339	0.978	0.378	0.869	0.853	0.605; ...
        0.778	0.791	0.618	0.667	0.920	0.577	0.872	0.776	0.609; ...
        0.771	0.942	0.676	0.681	0.987	0.563	0.946	0.955	0.700; ...
        0.806	0.951	0.685	0.681	0.989	0.606	0.959	0.963	0.700];
    ADLlabels = {'biking', 'class', 'cooking', 'driving', 'exercising', 'meeting', 'schoolwork', 'walking', 'working'};
    tmp = contextSep(:,end-2); contextSep(:,end-2:end-1) = contextSep(:,end-1:end); contextSep(:,end) = tmp
elseif subject ==2
     contextSep = [0.836	0.692	0.741	0.314	0.848	0.821	0.615; ...
        0.762	0.667	0.737	0.316	0.802	0.381	0.627; ...
        0.908	0.714	0.767	0.453	0.852	0.800	0.518; ...
        0.925	0.828	0.800	0.468	0.907	0.935	0.739 ];
    ADLlabels = {'class', 'exercising', 'getting ready', 'meeting', 'shopping', 'walking', 'working'};
    tmp = contextSep(:,end-2); contextSep(:,end-2:end-1) = contextSep(:,end-1:end); contextSep(:,end) = tmp

elseif subject==3
    contextSep = [0.957	0.261	0.484	0.353	0.392	0.312	0.890	0.831	0.793; ...
         0.846	0.636	0.741	0.488	0.370	0.654	0.885	0.677	0.779; ...
         0.973	0.488	0.812	0.512	0.423	0.717	0.923	0.700	0.821; ...
         0.973	0.682	0.812	0.548	0.479	0.748	0.932	0.700	0.829];
    ADLlabels = {'class', 'cleaning', 'driving', 'eating', 'meeting', 'relaxing', 'shopping', 'walking', 'working'};
    tmp = contextSep(:,end-2); contextSep(:,end-2:end-1) = contextSep(:,end-1:end); contextSep(:,end) = tmp

end

hb = bar(contextSep', 'grouped')
ylabel('F-1 Score')
xlabel('ADL Label')
titleName = sprintf('Subject %d Results for Context Detection on Noisy Data', subject);
title(titleName);
legend('Single Classifier with Beacons as Features', 'Single-Beacon Patterns, Basic Pattern Usage', 'Single-Beacon Patterns, ACP', 'AHAC, ACP (Our Approach)', 'Location', 'southoutside');
set(gca, 'xtick', 1:length(ADLlabels), 'xticklabel', ADLlabels, 'XTickLabelRotation', 15)
% set(gca, 'xtick', 1:length(ADLlabels), 'xticklabel', ADLlabels)