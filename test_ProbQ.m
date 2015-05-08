clear, clc;

nBaseStation = 1;
nUserState = 4;

arrivalRate = [0.1, 0.1];
leaveRate = [0.1, 0.1];
powerStrategy = 1;
sunlightCoeff = [1, 0.5];
relativeEUnit = 1;

Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;

for iSun = 1: 1: 10
    sunlightCoeff(1) = 2 * iSun;
    sunlightCoeff(2) = 0.05 * iSun;
    for iB = 2: 1: 10
        nBatteryState = iB;
        
        [powerMax, probQ] = checkProbQ(nBaseStation, nBatteryState, ...
            nUserState, arrivalRate, leaveRate, powerStrategy, sunlightCoeff, ...
            Jsc, Voc, n, relativeEUnit);
        
        for iiB = 1: 1: nBatteryState - 1
            endQ = nBatteryState;
            for iQ = endQ: -1: 1
                
                check = sum(probQ(iQ: endQ, iiB + 1)) - ...
                    sum(probQ(iQ + 1: endQ, iiB));
                if abs(check) > 1e-4 && check < 0
                    fprintf('When sunlightCoeff = %f, nBatteryState = %d, Battery = %d, %d, checkSum = %f \n', ...
                        sunlightCoeff(1), iB, iiB, iiB + 1, check);
                end
            end
        end
    end
end