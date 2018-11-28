%extract features from the BLE data (known devices only)
%  window is the set of device scans to consider for making features
%  numDevices is the number of devices we have prior information on.
%Pass in the known IDs that are present within the windows (integer from 0
%  to numDevices-1. numDevices is number of BLE beacons we know prior
%  information for.
%Function may need modification in the future to allow for more features
function feat = getBleFeatKnown(knownIDinWindow, numDevices)

    feat = zeros(1,numDevices);
    feat(knownIDinWindow+1) = 1;
    

end