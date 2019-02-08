function [features] = hrFeatureWindow(window)

if isempty(window)
    features = nan(1,7);
    return;
end

avg = mean(window);
maxHr = max(window);
minHr = min(window);
st_dev = std(window);
root_mean = rms(window);
mean_cross_rate = MCR(window);
variance = var(window);

features = [avg, maxHr, minHr, st_dev, root_mean, mean_cross_rate, variance];
    
end