%  the arrival Rate is different, from 

nBaseStation = 2;
nBatteryState = 2;
nUserState = 2;

leaveRate = [0.1, 0.1];
sunlightCoeff = [1, 0.7];
E_Unit = 1;
powerStrategy = 1;
discount = 0.9;

senseCost = - 0.1;
accessFail = - 1;
accessGain = zeros(nUserState, nBatteryState, nBaseStation);

for Rate = 1: 1: 8

arrivalRate = [0.03 * Rate, 0.1];

filename = [num2str(Rate) 'arrivalRate.POMDP'];

returnFlag = inputfile(nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, E_Unit, powerStrategy,...
    discount, senseCost, accessFail, accessGain );

end


%  the powerStrategy is different, from 

nBaseStation = 2;
nBatteryState = 2;
nUserState = 2;

leaveRate = [0.1, 0.1];
sunlightCoeff = [1, 0.7];
E_Unit = 1;
discount = 0.9;

arrivalRate = [0.1, 0.1];
senseCost = - 0.1;
accessFail = - 1;
accessGain = zeros(nUserState, nBatteryState, nBaseStation);

for power = 1: 1: 2

powerStrategy = power;
filename = [num2str(power) 'power.POMDP'];

returnFlag = inputfile(nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, E_Unit, powerStrategy,...
    discount, senseCost, accessFail, accessGain );

end


%  the sunlight is different, from 

nBaseStation = 2;
nBatteryState = 2;
nUserState = 2;

leaveRate = [0.1, 0.1];

E_Unit = 1;
discount = 0.9;

powerStrategy = 1;
arrivalRate = [0.1, 0.1];
senseCost = - 0.1;
accessFail = - 1;
accessGain = zeros(nUserState, nBatteryState, nBaseStation);

for light = 1: 1: 8
    
sunlightCoeff = [0.2 * light, 0.7];
filename = [num2str(light) 'light.POMDP'];

returnFlag = inputfile(nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, E_Unit, powerStrategy,...
    discount, senseCost, accessFail, accessGain );

end

%  the accessFail is different, from 

nBaseStation = 2;
nBatteryState = 2;
nUserState = 2;

leaveRate = [0.1, 0.1];

E_Unit = 1;
discount = 0.9;

sunlightCoeff = [0.2 * light, 0.7];
powerStrategy = 1;
arrivalRate = [0.1, 0.1];
senseCost = - 0.1;
accessGain = zeros(nUserState, nBatteryState, nBaseStation);

for Fail = 1: 1: 8
    
accessFail = - 0.2 * Fail;
filename = [num2str(Fail) 'accessFail.POMDP'];

returnFlag = inputfile(nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, E_Unit, powerStrategy,...
    discount, senseCost, accessFail, accessGain );

end
