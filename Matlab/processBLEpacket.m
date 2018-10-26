function [packetinfo] = processBLEpacket(packet)

packetinfo = {};
index = 1; %note that the packet is a byte string, so pairs of characters must be together
%thus, this number should always be an odd number (because index starts at
%1)

while index <= length(packet)
    len=packet(index:index+1);
    len=hex2dec(len) * 2; %because we have hex digits, but length is in bytes

    if len==0
        break;
    end
    
    %next two bytes describe the packet
    type = packet(index+2:index+3);
    
    %remainder of bites are the payload for this data unit
    %   starts 2 bytes after index (1 for length, 1 for type)
    %   second bound has index+2 to account for first byte not being
    %   included in overall length
    payload = packet(index+4:(index+2)+(len-1));


    %save type and data into info
    packetinfo{end+1,1} = type;
    packetinfo{end,2} = payload;

    index = index+(len+2); % update index to move onto the next data unit in the packet

end