clc, clear;
% consider different arrive rate

nBaseStation = 2;
nBatteryState = 3;
nUserState = 2;
 
for iArrival = 1: 1: 16
    
arrivalRate = [0.4, 0.4];
leaveRate = [0.1, 0.1];

sunlightCoeff = [0.125 * iArrival, 0.125/2 * iArrival];


relativeEUnit = 1;
powerStrategy = 1;

discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;
collisionConstraints = 1;

filename = [num2str(iArrival) 'fig4lightRate.POMDP'];
    
returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
    Jsc, Voc, n, relativeEUnit, collisionConstraints );

end