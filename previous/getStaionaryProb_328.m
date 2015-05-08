function uBelief = getStaionaryProb( trMtrSen, nUserState, nBatteryState, nBaseStation )


% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;

transitionProb = zeros( nState, nState );

uBelief = zeros(nUserState, nBatteryState, nBaseStation);

for iBase = 1: 1: nBaseStation
    
    for startState = 0: 1: nState - 1
        for endState = 0: 1: nState - 1
            [startUser, startBattery] = state2UserBattery( ...
                startState, nUserState, nBatteryState, nBaseStation );
            [endUser, endBattery] = state2UserBattery( ...
                endState, nUserState, nBatteryState, nBaseStation );
            transitionProb(startState + 1, endState + 1) = trMtrSen(startUser + 1,...
                startBattery + 1, endUser + 1, endBattery + 1, iBase);
        end
    end
    
    probDistribution = get_stationary_distribution( transitionProb );
    
    
    for iU = 1: 1: nUserState
        for iB = 1: 1: nBatteryState
            if iB == 1
                state = 0;
                if iU == 1;
                    uBelief(iU, iB, iBase) = probDistribution(state + 1);
                end
            else
                state = userBattery2State( iU - 1, iB - 1, nUserState, ...
                    nBatteryState, nBaseStation );
                
                uBelief(iU, iB, iBase) = probDistribution(state + 1);
            end
        end
    end
end
