function [] = writeFeatCSV_v2(feat, time, filename)
%write the CSV file of features for this set of features

fid = fopen(filename, 'w+');
width  = size(feat,2) + 1; %extra column for labels
length = size(feat,1);

%write features to file
for i = 1:length
    for j=1:width
        if(j==width)
           t = time{i};
           fprintf(fid,'%s', t(end-11:end));
        else
            fprintf(fid,'%f,',feat(i,j));
        end
    end
    if i~=length
        fprintf(fid,'\n');
    end
end

fclose(fid);




end