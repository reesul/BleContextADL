function [w] = updateWeights(oldW, P, alpha)

if (alpha > 1 || alpha < 0)
    warning('alpha must be between 0 and 1');
    return;
end

[sortedP, ind] = sort(P, 'descend')

k = sum(~sortedP); %amount that can be redistributed to other elements
n = length(P);
denom = sum(P);

w = zeros(size(oldW));

for i=1:(n-k)
    weight = sortedP(i)*k/denom + 1;
    w(ind(i)) = weight;

end


%apply exponential weight moving average
w = alpha*oldW + (1-alpha)*w;
sum(w)
sum(oldW)
end