clear, clc;

nBaseStation = 2;
nBatteryState = 11;
nUserState = 5;
arrivalRate = [0.1, 0.1];
leaveRate = [0.1, 0.1];
powerStrategy = 1;
sunlightCoeff = [1, 0.7];
relativeEUnit = 1;

Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;

[trMtrSen, trMtrAcs, powerMax, probQ] = transMatrixGet(nBaseStation, nBatteryState, ...
    nUserState, arrivalRate, leaveRate, powerStrategy, sunlightCoeff, ...
    Jsc, Voc, n, relativeEUnit);
probQ