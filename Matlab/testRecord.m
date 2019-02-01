function [Pr, validP] = testRecord(record, patterns, patternPr)

patterns = patterns(:,1);
Pr = [];
validP = cell(1,0);



for i=1:size(patterns,1)
    
    p = patterns{i};
    if all(record(p))
        %pattern is applicable
        validPr = patternPr(:, i);
        Pr = [Pr, validPr];
        validP = [validP, {p}]; %must be cell type because patterns are variable length
    end
    
end

if isempty(Pr)
   find(record);
   Pr = 1/size(patternPr,1) * ones(size(patternPr,1),1);
   validP = -1;
%    disp('no patterns applied for record') 
end

end