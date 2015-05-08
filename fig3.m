clc, clear;
% consider different arrive rate

nBaseStation = 2;
nBatteryState = 3;
nUserState = 2;
 
for iArrival = 1: 1: 16
    
arrivalRate = [0.4, 0.4];
leaveRate = [0.01 * iArrival + 0.09, 0.01 * iArrival + 0.09];

sunlightCoeff = [1, 0.5];

relativeEUnit = 1;
powerStrategy = 1;

discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %r
n = 2;
collisionConstraints = 1;

filename = [num2str(iArrival) 'fig3leaveRate.POMDP'];
    
returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
    Jsc, Voc, n, relativeEUnit, collisionConstraints );

end
