function [MACs] = findMACs(deviceID, deviceMap)

MACs = {};

k = deviceMap.keys();
for i=1:length(k)
    device = deviceMap(k{i});
    v = device('value');
    
    if v==deviceID
        MACs{end+1} = k{i};
        
    end
end
    
    
end