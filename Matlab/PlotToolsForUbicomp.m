%plotting tools for UbiComp submission

%% horizontal bar graph showing number of performed activities
% just change the following two lines, and then the title
labels = finalRecords(end-1,:);
% labelNames = activityLabelNames;


[labelNames, ~, ic] = unique(labels);
countAct = zeros(1,length(activityLabelNames));
for i=1:length(labelNames)
    labelNames(i);
    if ismember(labelNames(i), activityLabelNames)
        countAct(i) = sum(ic==i);
    end
end
countAct = countAct(countAct>0);

showTrTe = 1;

if ~showTrTe
    barh(fliplr(countAct));
    xlabel('Number of Instances');
    ylabel('Activities');
    set(gca, 'ytick', 1:length(activityLabelNames), 'yticklabel', fliplr(activityLabelNames))

    titleName = sprintf('Subject %d Activity Distribution', subject);
    title(titleName)

else
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
singleClassifierResults = [0.548	0.657	0.762	0.809	0.83 0.791 0.87	0.9356; ...
    0.68, 0.66, 0.78, 0.82, 0.835, 0.795, 0.843, 0.877; ...
    ones(1,8)*.2]'

singleClassifierResults = [singleClassifierResults, mean(singleClassifierResults,2)]
singleClassifierLabels = {'IMU only', 'BLE statistics', 'Beacons as binary features',...
    'IMU and BLE statistics', 'IMU, Beacons as features', 'BLE statistics, Beacons as features' ...
    'IMU, BLE statistics, Beacons as features', 'Our Method'}

bar(singleClassifierResults, 'grouped')
ylabel('Weighted Average F-1 Score')
xlabel('Feature Set')
title('Comparison of Inputs Types')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Average', 'Location', 'northwest');
set(gca, 'xtick', 1:length(singleClassifierResults), 'xticklabel', singleClassifierLabels, 'XTickLabelRotation', 15)


%% comparison of context-separation methods
ContextSepResults = [0.87, 0.9323, 0.9323, 0.9331, 0.9287, 0.9362, 0.952; ...
    0.84, 0.853, 0.853, 0.87, 0.867, 0.877, 0.91; ...
    0.8*ones(1,7)]';

ContextSepResults = [ContextSepResults, mean(ContextSepResults,2)]; 

ContextSepLabels = {'Single Classifier', 'Basic Usage, Single-Beacon Patterns', 'Basic Usage, AHAC Patterns'...
    'ACP, Single-Beacon Patterns', ...
    'ACP, HAC Patterns', 'ACP, AHAC Patterns (Our Method)',...
    'Location-based Separation'};

% Use this to change colors; make sure it will be distinguishable enough in
% BW (different hue). DO THIS FOR ANY PLOT SHOWING MULIPLE SUBJECTS.
colors = colormap([0 0 1; 1 1 0; 1 1 1])
hb = bar(ContextSepResults, 'grouped')
% hb(1).FaceColor = colors(1,:);
% hb(2).FaceColor = colors(2,:);
% hb(3).FaceColor = colors(3,:);



ylabel('Weighted Average F-1 Score')
xlabel('Approach')
title('Comparison of Context-Separation Approaches')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Average', 'Location', 'northwest');
set(gca, 'xtick', 1:length(ContextSepResults), 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.70 1])

%% Augmented data results

ContextSepResults = [0.82, 0.82, 0.78, 0.9133, 0.9336, 0.952; ... %TODO update ACP, HAC (3rd)
    0.75*ones(1,6); ...
    0.76*ones(1,6)]';

ContextSepLabels = {'Basic, Single-Beacon Patterns', 'Basic, AHAC Patterns', ...
    'ACP, Single-Beacon Patterns', ...
    'ACP, HAC Patterns', 'ACP, AHAC Patterns (Our Method)', 'Location-based Separation'};

% ContextSepLabels = {'Naive, Single-Beacon Patterns', 'Probabilistic, Single-Beacon Patterns', ...
%     'Probabilistic, AHAC Patterns'};

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
set(gca, 'xtick', 1:6, 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.70 1])