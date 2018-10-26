function [UUID, localID, name, numDevices] = getKnownID()
%assumes a file called 'knownUUIDs.txt' is present, and contains
%information about known devices (includes the identifier (UUID), a localID
%that is assigned by whoever processes the data, and the name of a device

    filename = 'knownUUIDs.txt';
    fid = fopen(filename);

    params = textscan(fid,'%s %s %s\n',1,'Delimiter',',');

    devices = textscan(fid,'%s %s %s','Delimiter',',');
    UUID = devices{1};
    localID = str2num(cell2mat(devices{2}));
    name = devices{3};
    
    numDevices = length(UUID);

    fclose(fid);




end