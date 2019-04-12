function [] = imuFigure(labels, dataWindows, labelToFind)

binLab = binaryLabels(labelToFind, labels)

for i=1:length(labels)
    
    if binLab(i)
        
    x=1;
    adata = dataWindows{i,1};
    gdata = dataWindows{i,2};
    
    if isempty(adata)
        continue;
    end

    Fs = 20; %sampling frequency

    [apsd, afreq] = getPSD(adata);
    [gpsd, gfreq] = getPSD(gdata);
    apsd = apsd(1:length(afreq),:);
    gpsd = gpsd(1:length(gfreq),:);
    
%     subplot(4,1,1)
    figure(1)
    plot(0:60/(size(adata,1)-1):60, adata(:,4))
    title('Accelerometer, Time-Domain')
    xlabel('Time')
    axis([0 inf 0 25]);
    
%     subplot(4,1,3)
    figure(2)
    plot(0:60/(size(gdata,1)-1):60, gdata(:,4))
    title('Gyroscope, Time-Domain')
    xlabel('Time')
    axis([0 inf 0 10]);
    
%     subplot(4,1,2)
    figure(3)
    plot(afreq, apsd(:,4))
    title('Accelerometer, Frequency-Domain')
    xlabel('Frequency')
    axis([0 inf 0 10])
    
%     subplot(4,1,4)
    figure(4)
    plot(gfreq, gpsd(:,4))
    title('Gyroscope, Frequency Domain')
    xlabel('Frequency')
    axis([0 inf 0 0.5])
    
    end
end


end

function [psd, freq] = getPSD(window)

    ignoreInd = 20;

    Fs = 20; %sampled at about 20 hz
    N=2000; %
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(ignoreInd+1:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd); %this will be N/2
    
    freq = Fs/N*ignoreInd : Fs/N : Fs/(2*2); %only show up to 5Hz, because 5-10 has virtually no information
    
     

end
