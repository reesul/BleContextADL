function [MACs] = findMACs(deviceID, deviceMap)

MACs = {};

for v=1:length(deviceID)
    dd = deviceID(v);
    k = deviceMap.keys();
    for i=1:length(k)
        device = deviceMap(k{i});
        v = device('value');

        if v==dd
            MACs{end+1} = k{i};

        end
    end

if isempty(MACs)
    disp('no macs found for device IDs');
end
    
end