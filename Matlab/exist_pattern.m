function bool = exist_pattern( pattern,list )
m = length(list);
bool = false;
for i=1:m
    if length(intersect(pattern,list{i})) == length(pattern)
        bool = true;
        return;
    end
end
end