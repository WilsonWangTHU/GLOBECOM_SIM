function y = probIntegral1(x, miu, sigma, E_Unit, startState, P_Sample)
miu = miu * P_Sample;
sigma = sigma * P_Sample ^2;
Coeff = ((startState + 1) * E_Unit - x) / E_Unit;
y = Coeff .* 1 ./ sigma / sqrt(2 * pi) .* exp(- ((x - miu).^2) / (2 * (sigma ^2)));
end
