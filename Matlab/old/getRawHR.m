function [data, time, timeStr] = getRawHR(filename)
%gets the raw heart rate data from the file specified in the argument, returns the
%data itself, timestamp as an integer (milliseconds since midnight), and
%timestamp as its native string

    %pull data from file
    file = fopen(filename);
    res={};
    while ~feof(file)
      res{end+1,1} = fgetl(file);
    end
    fclose(file);

    %intialize data and timestamps
    num_lines = numel(res);
    time = zeros(num_lines-1,1);
    timeStr = cell(num_lines-1,1);
    data = zeros(num_lines-1,1);

    for i=1:num_lines-1

        %get the line of text, pull information from this
        line = res{i+1};
        if (size(line,2) == 0) %may have empty line sometimes, best is to just find the lines and delete manually..
            printf('*****Empty line at %d\n*******\nDelete it!\n*******',i);
            continue;
        end
        
        comma = strfind(line,',');

        %get timestamp
        
        timeStr{i} = line(1:comma(1)-1);
        time(i) = date2num(timeStr{i});

        %get data itself: x, y, z
        data(i,1) = str2double(line(comma(1)+1:end));
%         data(i,2) = str2double(line(comma(2)+1:comma(3)-1));
%         data(i,3) = str2double(line(comma(3)+1:end));


    end

end