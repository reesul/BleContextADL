function [patternAndStats] = getPatternStats(patterns, rec, rec_not)

TP_end = cell(size(patterns));
FP_end = cell(size(patterns));
PLR_end = cell(size(patterns));

for i=1:length(patterns)
    [TP_end{i}, FP_end{i}, PLR_end{i}] = PLR(patterns{i}, rec, rec_not);
end

patternAndStats  = [patterns, TP_end, FP_end, PLR_end];



end