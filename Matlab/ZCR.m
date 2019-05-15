function y = ZCR(x)
%   zero crossing rate

y = sum(abs(diff(x>0)))/length(x);

end