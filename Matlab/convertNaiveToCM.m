function cm  = convertNaiveToCM(labelNames, labels, classified)

cm = zeros(length(labelNames));

for i=1:length(labels)
    
   lNum = find(strcmp(labels{i}, labelNames));
   cm(lNum, classified(i)) = cm(lNum, classified(i))+1;
    
end

end