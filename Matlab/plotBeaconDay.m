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
addpath('./addaxis');

figure(1)
plot(xaxis, CVs);
title('CV')

figure(2)
plot(xaxis, turnover);
title('Turnover')

figure(3)
plot(xaxis, numBeacons);
title('numBeacons')



end