function [feat] = imuFeatureWindow(window, isAcc)

    %BE SURE TO CHANGE THIS IF FEATURES ARE ADDED OR REMOVED
    numFeatures = 22*4;

    if isempty(window) || size(window,1) < 20
        feat = -inf*ones(1,numFeatures);
        return;
    end
    %features in the time domain; straight-forward
    avg = mean(window,1);
    st_dev = std(window,1);
    root_mean = rms(window,1);
    mean_cross_rate = MCR(window);
    variance = var(window);
    
    %find a max and min, but remove spikes in the data for accelerometer
    if isAcc
        maxVal = zeros(1,4);
        minVal = zeros(1,4);
        g = 9.8;
%         threshWindow = cell(1,4)
        for i=1:size(window,2)
            w = window(:,i);
            w = w(w < 2*g & w > -2*g); %filter out datapoints that are too large or too small
            maxVal(i) = max(w);
            minVal(i) = min(w);
        end
    else
        maxVal = max(window);
        minVal = min(window);
    end
    
    %get first 10 orders of AR coefficients
    ar10 = zeros(4,10);
    for i=1:size(window,2)
        a = ar(window(:,i),10);
        coeff = a.a; %get the coefficients themselves
        ar10(i,:) = coeff(2:end);
    end
    ar10 = ar10(:)';
    
    %calculate features in the frequency domain
    ignorePsdInd = 20;
    Fs = 20; %sampled at about 20 hz
    N=2000; 
    
    ft = fft(window, N); %take fft along the magnitude
    
    psd = (ft.*conj(ft))./(N*Fs);
    psd = psd(ignorePsdInd+1:N/2+1,:); %input is real valued, so fft is symmetric and only the first half (minus DC) needs to be considered
    pLen = length(psd);
    freq = Fs/N*ignorePsdInd : Fs/N : Fs/2;
    
    %Ignore: Take bins for 0-1 Hz (ignoring DC component, so 0+), 1-2, 2-5, and 5-10 
    % Take bins for 0-0.5Hz, 0.5-1Hz, 1-2Hz, and 2-5. 
    bin_0_05 = mean(psd(1:round(pLen/20),:),1);
    bin_05_1 = mean(psd(round(pLen/20)+1:round(pLen/10),:),1);   
%     bin_0_1 = mean(psd(1:round(pLen/10),:),1);	
    bin_1_2 = mean(psd(round(pLen/10)+1:round(pLen/5),:),1);
    bin_2_5 = mean(psd(round(pLen/5)+1:round(pLen/2),:),1);
%     bin_5_10 = mean(psd(round(pLen/2)+1:end,:),1);	
    	    
    %fidn the frequency at which the maximum component occurs	    %fidn the frequency at which the maximum component occurs
    [~, ind] = max(psd);
    maxFreq = freq(ind);
    	    
%     feat = [avg, st_dev, root_mean, mean_cross_rate, variance, maxVal, minVal, ar10, maxFreq, bin_0_1, bin_1_2, bin_2_5, bin_5_10];
    feat = [avg, st_dev, root_mean, mean_cross_rate, variance, maxVal, minVal, ar10, maxFreq, bin_0_05, bin_05_1, bin_1_2, bin_2_5];
end