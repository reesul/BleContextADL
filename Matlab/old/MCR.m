function [y] = MCR(x)
% calculate mean cross rate, x is data
% if x is a matrix, then MCR is calcuated for each column

s = size(x);
if(s(1)==1 || s(2)==1) %then this is a vector
    u=mean(x);
    y = sum(abs(diff(x>u)))/length(x);

else %this is a matrix, assuming we want MCR of the column
    u=mean(x);
    z = bsxfun(@ge, x, u);
    y = sum(abs(diff(z)))/length(z);

end