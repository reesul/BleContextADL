function [trInd, teInd] = distributeLabels(records, labelNames)

split = 0.70

trInd = false(1,size(records,2));
teInd = false(1,size(records,2));

for l=1:length(labelNames)
    label = labelNames{l}
    binL = binaryLabels(label, records(end-1,:));
    ind = find(binL);
    
    splitInd = round(length(ind)*split);
    while strcmp(records(end-1,ind(splitInd)), records(end-1,ind(splitInd+1))) && ...
            strcmp(records(1,ind(splitInd)), records(1,ind(splitInd+1))) && ... %make sure data is from different days
            records{2,ind(splitInd)} - records{2,ind(splitInd+1)} < 1000*60*30 %or instances have a 30 minute separation 
        splitInd = splitInd+1;
        if splitInd+1 > length(ind)
            break;
        end
    end
    
    if splitInd > 0.85*length(ind) %don't let it go too far
        splitInd = round(length(ind)*split);
        while strcmp(records(end-1,ind(splitInd)), records(end-1,ind(splitInd+1))) && ...
            strcmp(records(1,ind(splitInd)), records(1,ind(splitInd+1))) && ... %make sure data is from different days
            records{2,ind(splitInd)} - records{2,ind(splitInd+1)} < 1000*60*30 %or instances have a 30 minute separation 
           
            splitInd = splitInd-1;
            if splitInd <= 0
                break;
            end
        end
    end
    
    if splitInd > 0 
        train = ind(1:splitInd);
        test = ind(splitInd+1:end);
        trInd(train)= true;
        teInd(test) = true;
    end
    
end


end