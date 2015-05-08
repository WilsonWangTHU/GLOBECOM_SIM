function [newUserState, newBatteryState, ChargeBattery, drop] = renewWorldState(...
    flagAccess, trMat, userState, batteryState, sunlightCoeff, ...
    nUserState, nBatteryState, powerStrategy, singleArrivalRate, ...
    singleLeaveRate, Jsc, Voc, n, powerMax)
drop = 0;
nKT_q = 0.0259 * n;
v = ( floor( batteryState ) + 0.5 ) / nBatteryState * Voc;

P = (Jsc - Jsc * (exp(v / nKT_q) - 1) / (exp(Voc / nKT_q) - 1)) .* v / powerMax;
P = 1;

% --------------------------------------------------------------------------------- %

ChargeBattery = P * normrnd( sunlightCoeff(1), sunlightCoeff(2) );
if ChargeBattery < 0; ChargeBattery = 0; end

if ChargeBattery + batteryState > nBatteryState
    ChargeBattery = nBatteryState - batteryState;
end

if userState + flagAccess <= batteryState % the battery is enough
    ConsumedBattery = userState + flagAccess;
else
    ConsumedBattery = floor(batteryState);
end

newBatteryState = ChargeBattery + batteryState - powerStrategy * ConsumedBattery;

% (nUserState - 1)
% ((userState > 1 && batteryState >= 1) + ...
%     flagAccess * ((batteryState > 1 && userState == 0) || ...
%     (batteryState > 2)));

if newBatteryState >= nBatteryState
    newBatteryState = nBatteryState - 0.001;
end

% the user is in the system, we take him out first for calculation
oneMore = 0; oneLess = 0;
switch userState
    case 0
        oneMore = singleArrivalRate;
    case nUserState - 1
        oneLess = userState * singleLeaveRate;
    otherwise
        oneLess = userState * singleLeaveRate;
        oneMore = singleArrivalRate;
end

% generate the userChange
seed = rand(1);
userChange = (seed < oneMore) * 1 + ...
    (seed > oneMore && seed < oneMore + oneLess) * (-1) + ...
    (seed > oneMore + oneLess) * 0;

newUserState = userState + userChange;
if newBatteryState < 1 && newUserState ~= 0
    drop = 1;
    newUserState = 0;
end

