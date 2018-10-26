function [knownID, fullBleStr, indices, numDevices] = knownBeacons(bleScans)
%function to extract known beacons' data from the entire list
%give integer corresponding to the device's identifier (within estimote), 
% return this integer and the full string of data from that scan


%% Create map of known devices
%   example of an estimote's identifier: 723562d1c6bc290341a23a485d85720c

    [UUIDs, localIDs, names, numDevices] = getKnownID();
    deviceMap = containers.Map(UUIDs, localIDs);
    
%% Extract data for known devices
% loop over all scans
%   get the raw packet, look for estimote identifier, then compare to known
%   UUIDs
       
%indices of known devices, helpful for selecting data for output     
indices = [];
knownID = []; 
        
for i=1:length(bleScans)
   singleScan = bleScans{i};
   [raw,mac] = getBleInfo(singleScan); %not using MAC currently
   
   %estimote packets are 60 hexadecimal digits (30 bytes) in length
   if(length(raw)==60)
       possibleID = raw(end-35:end-4);
       if(isKey(deviceMap,possibleID))
           
           knownID = [knownID; deviceMap(possibleID)];
           indices = [indices; i];
           
       end

   end
    
    
end

fullBleStr = bleScans(indices);

end