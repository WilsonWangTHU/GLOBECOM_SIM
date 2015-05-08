function uBelief = getStaionaryProb( trMtrSen, nUserState, nBatteryState, nBaseStation )


% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;

transitionProb = ones( nState, nState );

uBelief = zeros(nUserState, nBatteryState, nBaseStation);


for startState = 0: 1: nState - 1
    for endState = 0: 1: nState - 1
        for iBase = 1: 1: nBaseStation
            [startUser, startBattery] = state2UserBattery( ...
                startState, nUserState, nBatteryState, nBaseStation );
            [endUser, endBattery] = state2UserBattery( ...
                endState, nUserState, nBatteryState, nBaseStation );
            
            transitionProb(startState + 1, endState + 1) = ...
                transitionProb(startState + 1, endState + 1) * ...
                trMtrSen(startUser(iBase) + 1, startBattery(iBase) + 1, endUser(iBase) + 1, endBattery(iBase) + 1, iBase);
        end
    end
end

probDistribution = get_stationary_distribution( transitionProb );

for state = 0: 1: nState - 1
    
    [user, battery] = state2UserBattery( state, nUserState, nBatteryState, nBaseStation );
        
    for iBase = 1: 1: nBaseStation
        uBelief(user(iBase) + 1, battery(iBase) + 1, iBase) = uBelief(user(iBase) + 1, battery(iBase) + 1, iBase) + ...
            probDistribution(state + 1);
    end
end


% check for sum == 1
for iBase = 1: 1: nBaseStation
        if sum(sum(uBelief(:, :, iBase))) ~= 1
            fprintf('possible wrong probability, delta probability %f', sum(sum(uBelief(:, :, iBase))) - 1);
            uBelief(:, :, iBase) = uBelief(:, :, iBase) / sum(sum(uBelief(:, :, iBase)));
        end
end

