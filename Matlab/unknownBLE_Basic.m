function [MAC_packetMap, packet_MACMap, collisionMap] = unknownBLE_Basic(bleData)

%% First iteration of identifying unknown BLE devices
% start off with MAC, then try UUID, then play around with combinations

%% Create initial Map object
% Need to iteratively add onto this
MAC_packetMap = containers.Map
packet_MACMap = containers.Map
collisionMap = containers.Map

mismatch = 0;
MACwithCollisions = {}

for i=1:length(bleData)
    %extract mac
    scan = bleData{i};
    startMac = strfind(scan,'mac:{') + length('mac:{');
    MAC = scan(startMac: startMac+16);
    
    if MAC_packetMap.isKey(MAC)
        MAC_packetMap(MAC) = MAC_packetMap(MAC)+1 %increments number of scans
    else
        MAC_packetMap(MAC) = 1
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
        packet
        packet_MACMap(packet)
        MAC
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
        packet_MACMap(packet) = MAC
    end

end

values = packet_MACMap;
MACwithCollisions;
mismatch




end