function state = userBattery2State( user, battery, nUserState, ...
    nBatteryState, nBaseStation )

nSingleState = (nBatteryState - 1) * nUserState + 1;

state = 0;

for iStation = 1: 1: nBaseStation
    singleState = smallMix( user(iStation), battery(iStation), nBatteryState, nUserState );
    state = state + singleState * nSingleState ^ (nBaseStation - iStation);
end
end

function singleState = smallMix( singleUser, singleBattery, nBatteryState,...
    nUserState )

if singleBattery == 0
    singleState = 0;
else
    singleState = (singleBattery - 1) * nUserState + singleUser + 1;
end

end

