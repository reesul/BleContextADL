function [date] = num2date(num)

ms = mod(num, 1000);
num = floor(num/1000);
s = mod(num, 60);
num = floor(num/60);
m = mod(num, 60);
num = floor(num/60);
h = num;

% date = sprintf('%s:%s:%s.%s', string(h), string(m), string(s), string(ms));
date = sprintf('%d:%d:%d.%03d', h, m, s, ms);
end