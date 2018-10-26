function [MAC_packetMap, packet_MACMap, collisionMap, fullInfoMap, values] = unknownBLE_UUID(bleData)

%% First iteration of identifying unknown BLE devices
% start off with MAC, then try UUID, then play around with combinations

%% Create initial Map object
% Need to iteratively add onto this
MAC_packetMap = containers.Map
packet_MACMap = containers.Map
collisionMap = containers.Map

fullInfoMap = containers.Map

UUID_16_complete = {};  %type '03', should be complete set of UUIDs (16 bit, 2^16 possibilities)
UUID_16_other = {};     %type '02', should be another set of 16 bit UUIDs
UUID_32_complete = {};  %type '05'
UUID_32_other = {};     %type '04'
UUID_128_complete = {}; %type '07'
UUID_128_other = {};    %type '06'
shortName = {};         %type '08'
completeName = {};      %type '09'
companySpecific = {};   %type 'FF'

MAClist = {};

mismatch = 0;
MACwithCollisions = {};

for i=1:length(bleData)
    %extract mac
    scan = bleData{i};
    startMac = strfind(scan,'mac:{') + length('mac:{');
    MAC = scan(startMac:startMac+16);
    MAClist{end+1} = MAC;
    
    if MAC_packetMap.isKey(MAC)
        MAC_packetMap(MAC) = MAC_packetMap(MAC)+1; %increments number of scans
    else
        MAC_packetMap(MAC) = 1;
    end
        
        
    %get the packet itself
    startpacket = strfind(scan,'raw_data:{') + length('raw_data:{');
    packet = scan(startpacket: end-1);
    
%     %try doing the inverse of this as well, packet is key, value is MAC
%         % if there is an exact repeat of the packet for different MAC, then
%         % it is probably the same device with a new MAC
%     if packetMap.isKey(MAC)
%         if ~strcmp(packetMap(MAC),packet) %means we have a mismatch of the packet string
%          	mismatch = mismatch +1;
%             MACwithCollisions{end+1} = MAC;
%         end
%     else
%         packetMap(MAC) = packet
%     end
    %try doing the inverse of this as well, packet is key, value is MAC
        % if there is an exact repeat of the packet for different MAC, then
        % it is probably the same device with a new MAC
    if packet_MACMap.isKey(packet)
        packet;
        packet_MACMap(packet);
        MAC;
        if ~strcmp(packet_MACMap(packet),MAC) %means we have a mismatch of the packet string
         	mismatch = mismatch +1;
            MACwithCollisions{end+1} = MAC;
            if collisionMap.isKey(MAC)
                collisionMap(MAC) = collisionMap(MAC)+1;
            else
                collisionMap(MAC)=1;
            end  
        end
    else
        packet_MACMap(packet) = MAC;
    end
    
    
    packetInfo = processBLEpacket(packet);

    if fullInfoMap.isKey(MAC)
        cells = fullInfoMap(MAC);
        cells{end+1} = {packetInfo};
        fullInfoMap(MAC) = cells;
    else
        fullInfoMap(MAC) = {packetInfo};
    end
    
    
    for i=1:size(packetInfo,1)
        packetType = packetInfo{i,1};
        packetField = packetInfo{i,2};
        switch(packetType)
            case '02'
                if length(packetField) > 4
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else
                    UUID_16_other{end+1} = packetField;
                end
            case '03'
                if length(packetField) > 4
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else
                    UUID_16_complete{end+1} = packetField;
                end
                case '04'
                if length(packetField) > 8
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else
                    UUID_32_other{end+1} = packetField;         
                end
            case '05'
                if length(packetField) > 8
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else            
                    UUID_32_complete{end+1} = packetField;
                end
            case '06'
                if length(packetField) > 32
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else            
                    UUID_128_other{end+1} = packetField;         
                end
            case '07'
                if length(packetField) > 32
                    sprintf('Packet length wrong for this type, examine: %s\n%s',packetField,packet)
                else            
                    UUID_128_complete{end+1} = packetField;
                end
            case '08'
                shortName{end+1} = packetField;
            case '09'          
                completeName{end+1} = packetField;
            case 'FF'
                companySpecific{end+1} = packetField;
                %company specific data, difficult to use without knowledge
                %on specific format
            otherwise
                packetType;
        end
    end

end




values = packet_MACMap;
MACwithCollisions;
mismatch


values = {UUID_16_complete, UUID_16_other, UUID_32_complete, UUID_32_other, ...
    UUID_128_complete, UUID_128_other, shortName, completeName, MAClist};

for i=1:size(values,2)
    %values{i} = unique(values{i});
    %values{i}
    
end




end