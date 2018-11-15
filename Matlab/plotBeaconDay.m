%dayStr should be in the format MM/DD/YY
function [] = plotBeaconDay(dayStr, records)



rInd = find(strcmp(records(1,:), dayStr));
rDay = records(:,rInd);

xaxis = cell2mat(rDay(2,:));
CVs = cell2mat(rDay(4,:));
turnover = cell2mat(rDay(5,:));


recordMtx = rDay(3,:);
recordMtx = cell2mat(recordMtx);
recordMtx = reshape(recordMtx,[length(rDay{3,1}),size(rDay,2)]);


numBeacons = sum(recordMtx,1);

% todo figure out how to get this added on successfully
% addpath('./addaxis');

figure(1)
hold on

yyaxis left

plot(xaxis, CVs, 'r--');
plot(xaxis, turnover, 'b-o');

yyaxis right
plot(xaxis, numBeacons,'g');

s =['BLE characteristics for' ' ' rDay{1,1}];
disp(s)
title(s)
legend({'CVs','Turnover','Beacon Count'});

hold off



end