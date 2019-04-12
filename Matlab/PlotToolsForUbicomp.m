%plotting tools for UbiComp submission

%% horizontal bar graph showing number of performed activities
% just change the following two lines, and then the title
labels = finalRecords(end-1,:)
labelNames = activityLabelNames;


[~, ~, ic] = unique(labels);
countAct = zeros(1,9);
for i=1:length(labelNames)
countAct(i) = sum(ic==i);
end

barh(fliplr(countAct));
xlabel('Number of Instances');
ylabel('Activities');
set(gca, 'ytick', [1:length(labelNames)], 'yticklabel', fliplr(labelNames))

title('Subject 1 Activity Distribution')


%% comparison of input modalities
singleClassifierResults = [0.548	0.657	0.762	0.809	0.83 0.791 0.87	0.9356; ...
    ones(1,8)*.1; ...
    ones(1,8)*.2]'
singleClassifierLabels = {'IMU only', 'BLE statisics', 'Beacons as binary features',...
    'IMU and BLE statistics', 'IMU, Beacons as features', 'BLE statistics, Beacons as features' ...
    'IMU, BLE statistics, Beacons as features', 'Our Method'}

bar(singleClassifierResults, 'grouped')
ylabel('Weighted Average F-1 Score')
xlabel('Feature Set')
title('Comparison of Inputs Types')
legend('Subject 1', 'Subject 2', 'Subject 3', 'Location', 'northwest');
set(gca, 'xtick', 1:length(singleClassifierResults), 'xticklabel', singleClassifierLabels, 'XTickLabelRotation', 15)


%% comparison of context-separation methods
ContextSepResults = [0.9323, 0.9331, 0.9287, 0.9362, 0.952; ...
    0.91*ones(1,5); ...
    0.96*ones(1,5)]';

ContextSepLabels = {'Naive, Single-Beacon Patterns', 'Naive, AHAC Patterns'...
    'Probabilistic, Single-Beacon Patterns', ...
    'Probabilisitic, HAC Patterns', 'Probabilistic, AHAC Patterns',...
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
legend('Subject 1', 'Subject 2', 'Subject 3', 'Location', 'northwest');
set(gca, 'xtick', 1:length(ContextSepResults), 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.9 1])

%% Augmented data results

ContextSepResults = [0.820, 0.9133, 0.9336; ...
    0.91*ones(1,3); ...
    0.96*ones(1,3)]';

ContextSepLabels = {'Naive, Single-Beacon Patterns', 'Probabilistic, Single-Beacon Patterns', ...
    'Probabilistic, AHAC Patterns'};

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
set(gca, 'xtick', 1:5, 'xticklabel', ContextSepLabels, 'XTickLabelRotation', 15)
ylim([0.75 1])