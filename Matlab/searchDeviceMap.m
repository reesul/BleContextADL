function [MAC, value, device] = searchDeviceMap(recognizedDevices, searchField, searchValue)

keys = recognizedDevices.keys();

MAC={};
value=[];
device = {};

if strcmp(searchField,'08') || strcmp(searchField,'09')
    searchValue = upper(sprintf('%x', searchValue));
    
end

for i=1:length(keys)
    rd = recognizedDevices(keys{i});
    if isequal(rd(searchField), searchValue)
       MAC{end+1} = keys{i};
       value(end+1) = rd('value');
       device{end+1} = rd;
        
    end
    
    if strcmp(rd(searchField), searchValue)
       MAC{end+1} = keys{i};
       value(end+1) = rd('value');
       device{end+1} = rd;

    end

end