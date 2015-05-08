clc, clear;
nBaseStation = 2;
nBatteryState = 3;
nUserState = 2;
filename = 'testOutputFile.POMDP';
arrivalRate = [0.1, 0.1];
leaveRate = [0.1, 0.1];
sunlightCoeff = [1, 0.005];
relativeEUnit = 1;
powerStrategy = 1;
discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;
forcedDropConstraints = 0.1;

returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
    Jsc, Voc, n, relativeEUnit, forcedDropConstraints );


% ---------------------- %

