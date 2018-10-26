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