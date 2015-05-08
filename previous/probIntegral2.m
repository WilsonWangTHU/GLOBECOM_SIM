function y = probIntegral2(x, miu, sigma, E_Unit, startState, P_Sample)
miu = miu * P_Sample;
sigma = sigma * P_Sample ^2;
Coeff = (x - (startState) * E_Unit) / E_Unit;
y = Coeff .* 1 / sigma / sqrt(2 * pi) .* exp(- ((x - miu).^2) / (2 * (sigma ^2)));
end
