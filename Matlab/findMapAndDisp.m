function [] = findMapAndDisp(value, map)

M = findMACs(value, map);

for i=1:length(M)
    m = M{i};
    d = map(m);
    s = sprintf('i=%d, MAC=%s',i,m);
    disp(s);
    dispDeviceMap(d);
    disp(' ');
    
end

end


function [] = dispDeviceMap(device)

k = device.keys();
for i=1:length(k)
    f = device(k{i});
    
    if strcmp(k{i},'EddyStone') && ~isempty(f)
        for j=1:2            
            if isempty(f(j))
                fprintf('%s(%d) : NULL\n', k{i},j);
            else
                fprintf('%s(%d) : %s\n', k{i}, j, string(f{j}));
            end
        end
        continue;
    end    
    if isempty(f)
        fprintf('%s : NULL\n', k{i});
    else
        fprintf('%s : %s\n', k{i}, string(f));
    end

            
end
end