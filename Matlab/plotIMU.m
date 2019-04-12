function [] = plotIMU(gdata, adata, label, record)
    recordTime = record{2}
    recordDate = record{1}

    metadata = [label{1}, ' @ ', num2date(recordTime) , ' on ', recordDate];
    disp(metadata)
    Fs = 20; %sampling frequency

    [apsd, afreq] = getPSD(adata);
    [gpsd, gfreq] = getPSD(gdata);
    apsd = apsd(1:length(afreq),:);
    gpsd = gpsd(1:length(gfreq),:);

    figure(1)
    subplot(4,2,1)
    plot(adata(:,1));
    title('ACC X');
    xlabel('time')
    subplot(4,2,2)
    plot(adata(:,2));
    title('ACC Y');
    xlabel('time')
    subplot(4,2,5)
    plot(adata(:,3));
    title('ACC Z');
    xlabel('time')
    subplot(4,2,6)
    plot(adata(:,4));
    title('Magnitude of ACC');
    xlabel('time')

    subplot(4,2,3)
    plot(gdata(:,1));
    title('GYRO X');
    xlabel('time')
    subplot(4,2,4)
    plot(gdata(:,2));
    xlabel('time')
    subplot(4,2,7)
    plot(gdata(:,3));
    title('GYRO Z');
    xlabel('time')
    subplot(4,2,8)
    plot(gdata(:,4));
    title('Magnitude of GYRO');
    xlabel('time')
    
    figure(2)
    
    subplot(4,2,1)
    plot(afreq, apsd(:,1));
    title('ACC X');
    xlabel('frequency')
    subplot(4,2,2)
    plot(afreq, apsd(:,2));
    title('ACC Y');
    xlabel('frequency')
    subplot(4,2,5)
    plot(afreq, apsd(:,3));
    title('ACC Z');
    xlabel('frequency')
    subplot(4,2,6)
    plot(afreq, apsd(:,4));
    title('Magnitude of ACC');
    xlabel('frequency')

    subplot(4,2,3)
    plot(gfreq, gpsd(:,1));
    title('GYRO X');
    xlabel('frequency')
    subplot(4,2,4)
    plot(gfreq, gpsd(:,2));
    title('GYRO Y');
    xlabel('frequency')
    subplot(4,2,7)
    plot(gfreq, gpsd(:,3));
    title('GYRO Z');
    xlabel('frequency')
    subplot(4,2,8)
    plot(gfreq, gpsd(:,4));
    title('Magnitude of GYRO');
    xlabel('frequency')


    
end

function [psd, freq] = getPSD(window)

    ignoreInd = 20;

    Fs = 20; %sampled at about 20 hz
    N=2000; %
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(ignoreInd+1:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd); %this will be N/2
    
    freq = Fs/N*ignoreInd : Fs/N : Fs/(2*2); %only show up to 5Hz (divide by 4), because 5-10 has virtually no information
    
    

end
