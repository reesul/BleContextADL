function [MAC, value, device] = searchDeviceMap(recognizedDevices, searchField, searchValue)

keys = recognizedDevices.keys();

MAC='null';
value=-1;
device = 'null';

if strcmp(searchField,'08') || strcmp(searchField,'09')
    searchValue = upper(sprintf('%x', searchValue))
    
end

for i=1:length(keys)
    rd = recognizedDevices(keys{i});
    if isequal(rd(searchField), searchValue)
       MAC = keys{i};
       value = rd('value');
       device = rd;
       return;
        
    end
    
    if strcmp(rd(searchField), searchValue)
       MAC = keys{i};
       value = rd('value');
       device = rd;
       return;

    end

end