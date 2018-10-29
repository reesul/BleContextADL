function [rawdata, mac, time] = getBleInfo(fullBleStr)
%Gets data from the BLE scan that can be used to uniquely identify the
%device i.e. MAC address and raw packet (contains data like UUID)

    brackets_start = strfind(fullBleStr,'{');
    brackets_end = strfind(fullBleStr,'}');
    
    rawdata = fullBleStr(brackets_start(end)+1:brackets_end(end)-1);
    mac = fullBleStr(brackets_start(2)+1:brackets_end(2)-1);
    time = fullBleStr(brackets_start(1)+1:brackets_end(1)-1);
    
end