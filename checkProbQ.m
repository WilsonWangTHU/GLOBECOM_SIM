function [powerMax, probQ] = checkProbQ(nBaseStation, nBatteryState, ...
    nUserState, arrivalRate, leaveRate, powerStrategy, sunlightCoeff, ...
    Jsc, Voc, n, relativeEUnit)

% example input:
%	nBaseStation = 2;
% 	nBatteryState = 2;
% 	nUserState = 2;
% 	arrivalRate = [0.1, 0.1];
% 	leaveRate = [0.1, 0.1];
% 	powerStrategy = 1;
% 	sunlightCoeff = [1, 0.7];
% 	relativeEUnit = 1;

% 	Jsc = 13.364; % the statistic in our model
%	Voc = 0.7631; %
% 	n = 2;

% Output is in the form of trMtrSen(u, b, u', b', baseStation)
% because different baseStation could have different arrival rate

% relativeEUnit means how much one unit of energy is, when compared
% with the

% sunlightCoeff means that the average sunlight could provide
% how many unit of relativeEUnit energy


nKT_q = 0.0259 * n;  % VOLT
V = [0: 0.001: Voc];
P = (Jsc - Jsc * (exp(V / nKT_q) - 1) / (exp(Voc / nKT_q) - 1)) .* V;

% normalization the power so that the max harvesting is the average sunlight
% level of the sunlightCoeff
pathLength = length(P) / (nBatteryState);
powerMax= max(P);
P = P / max(P);

powerSample = P(round(0.5 * pathLength + ((1 : nBatteryState) - 1) * ...
    pathLength));

% calculate the probs of Q, given the battery state and the sunlight level
% which is a quasi - static process

% note the difference of  Q and Q + 1 in the probQ, as in matlab, the index 
% starts from 1
probQ = zeros(nBatteryState, nBatteryState);
for batteryState = 1: 1: nBatteryState
    for Q = 0: 1: nBatteryState - batteryState
        if Q == 0
            probQ(Q + 1, batteryState) = quad( @(x)probIntegral1( x, ...
                sunlightCoeff(1), sunlightCoeff(2), relativeEUnit, 0, ...
                powerSample(batteryState)), 0, relativeEUnit );
        else
            probQ(Q + 1, batteryState) = ...
                quad( @(x)probIntegral1( x, sunlightCoeff(1), ...
                    sunlightCoeff(2), relativeEUnit, Q, ...
                    powerSample(batteryState)), Q * relativeEUnit, ...
                    (Q + 1) * relativeEUnit ) + ...
                quad( @(x)probIntegral2( x, sunlightCoeff(1), ...
                    sunlightCoeff(2), relativeEUnit, Q - 1, ...
                    powerSample(batteryState)), (Q - 1) * relativeEUnit, ...
                    Q * relativeEUnit );
        end
    end
    probQ(:, batteryState) = ...
        probQ(:, batteryState) / sum( probQ(:, batteryState));
end
