%create .arff file for Weka

dataPath = 'C:\Users\reesul\Documents\Activity_Recognition\Processing\\';
arffFileName = strcat(dataPath,'data_imu.arff');
%if .arff file is already there, just delete it so it doesn't show in files
if (fopen(arffFileName, 'r') ~= -1)
    fclose('all');
    delete(arffFileName);
    disp('Deleted existing arff file');
end

files = dir(dataPath);
files = files(3:end); %remove '.' and '..' folders
fileNames = {files(:).name};

fArff = fopen(arffFileName, 'w');

%first write the header of the .arff file, like relation and feature
%names

%names of the features
features = {'mean', 'std', 'rms', 'mcr', 'var', 'int', 'skew', 'fft1', 'fft2', 'fft3'};

fprintf(fArff, '@relation context\n\n');

%write the attribute section for IMU
for i=1:8*length(features)
   feat_sel = i;
   if (i<=40)
      %acc features
      feat_sel = floor(((feat_sel-1)/4.0)+1);
      att_str = strcat('@attribute a_', features{feat_sel});
      switch (mod(i,4))
          case 1
              fprintf(fArff, strcat(att_str, '_x numeric\n'));
          case 2
              fprintf(fArff, strcat(att_str, '_y numeric\n'));
          case 3
              fprintf(fArff, strcat(att_str, '_z numeric\n'));
          case 0
              fprintf(fArff, strcat(att_str, '_mag numeric\n'));
      end
   else
       %gyro features
       feat_sel = feat_sel-40;
       feat_sel = floor(((feat_sel-1)/4.0)+1);
       att_str = strcat('@attribute g_', features{feat_sel});
       switch (mod(i,4))
          case 1
              fprintf(fArff, strcat(att_str, '_x numeric\n'));
          case 2
              fprintf(fArff, strcat(att_str, '_y numeric\n'));
          case 3
              fprintf(fArff, strcat(att_str, '_z numeric\n'));
          case 0
              fprintf(fArff, strcat(att_str, '_mag numeric\n'));
      end
       
   end
end

%write attribute section for HR
features = {'mean', 'std', 'rms', 'mcr', 'var', 'int', 'skew'};
att_str = '@attribute hr_';
for i=1:length(features)
    fprintf(fArff, strcat(att_str, features{i}, ' numeric\n'));
    
end

%attribute section for time features
features = {'timeOfDay', 'dayOfWeek'};
att_str = '@attribute t_';
for i=1:length(features)
    fprintf(fArff, strcat(att_str, features{i}, ' integer\n'));
    
end


%attribute section for known ble beacons
[U,L,N,numDevices] = getKnownID();
clear U L N %don't need these for anything, only numDevices
for i=1:numDevices
   fprintf(fArff, '@attribute ble_knownDev_%d {0,1}\n', i); 
    
end

%class labels
fprintf(fArff, '@attribute activity {Home,WorkInLab,LabSeminar,Class,LabCourse,Eating,Break,Traveling,Restroom,Gym,Meeting}\n\n');


%now write the data section of the file

fprintf(fArff, '@data\n');

for i=1:length(files)
    name = files(i).name;
    if (~strcmp(name(end-3:end),'.csv'))
        continue;    
    end
        
    fdata = fopen(strcat(dataPath, name));
    %%%write all data from all csv files
    while ~feof(fdata)
        line = fgetl(fdata);
        fprintf(fArff, '%s\n', line);
    end
    
    
    fclose(fdata);
end


fclose(fArff);