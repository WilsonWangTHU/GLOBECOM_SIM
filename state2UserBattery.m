function [user, battery] = state2UserBattery( state, nUserState, ...
    nBatteryState, nBaseStation )

% transform the state into userState and batteryState battery and user are 
% real numbers

% singleState = (battery(1~(nBatteryState-1)) - 1) * nUserState +...
% (user(0~nUserState - 1)) + 1 ; no-battery singleState: 0
user = zeros( nBaseStation, 1 );
battery = zeros( nBaseStation, 1 );

nSingleState = (nBatteryState - 1) * nUserState + 1;

% singleState1 singleState2 singleState3
if state == 0 % it is the no-battery state %
    user(:) = 0;
    battery(:) = 0;
else
    singleState = bigDivide( state, nBaseStation, nSingleState );
    
    for iStation = 1: 1: nBaseStation
        [ user(iStation), battery(iStation) ] = smallDivide( ...
            singleState(iStation), nBaseStation, nUserState );
    end
end


end

function singleState = bigDivide( state, nBaseStation, nSingleState )

% s1*n^2 + s2*n^1 + s3, s_i = 0~(n-1)
singleState = zeros( nBaseStation, 1 );
for iStation = 1: 1: nBaseStation
    singleState(nBaseStation - iStation + 1) = mod( state, nSingleState );
    state = (state - singleState(nBaseStation - iStation + 1)) / nSingleState;
end

end

function [singleUser, singleBattery] = smallDivide( singleState, ...
    nBatteryState, nUserState )
if singleState == 0
    singleUser = 0;
    singleBattery = 0;
else
    singleUser = mod( singleState - 1, nUserState );
    singleBattery = (singleState - singleUser - 1) / nUserState + 1;
end
end
