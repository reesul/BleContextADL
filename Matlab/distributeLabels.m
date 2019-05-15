%% this function finds the indicies for testing and training using a temporal split
function [trInd, teInd] = distributeLabels(records, labelNames)

split = 0.70; %aiming for a 75% split, but it works it's way up to higher percentage usually; start conservative

trInd = false(1,size(records,2));
teInd = false(1,size(records,2));

for l=1:length(labelNames)
    %label to distribute testing and training sets
    label = labelNames{l}
    binL = binaryLabels(label, records(end-1,:)); %binary labels
    ind = find(binL); %these are the indices of records that have the target label
    
    splitInd = round(length(ind)*split); %split at this index, but first search for last occurrence of this interval of the same activity
    %work through instances until we find some that are separated by 30
    %minutes, a day, or different labels
    while strcmp(records(end-1,ind(splitInd)), records(end-1,ind(splitInd+1))) && ... 
            strcmp(records(1,ind(splitInd)), records(1,ind(splitInd+1))) && ... %make sure data is from different days
            records{2,ind(splitInd)} - records{2,ind(splitInd+1)} < 1000*60*30 %or instances have a 30 minute separation 
        splitInd = splitInd+1;
        
        if splitInd+1 > length(ind)
            break;
        end
    end
    
    if splitInd > 0.85*length(ind) %don't let it go too far (i.e. beyond 85% split
        splitInd = round(length(ind)*split);
        %do similar thing as before, but move backwards
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
        train = ind(1:splitInd); %indices for instances for the training set
        test = ind(splitInd+1:end); %indices for the testing set
        trInd(train)= true; %put these into logical vector format for easy indexing
        teInd(test) = true;
    end
    
end


end