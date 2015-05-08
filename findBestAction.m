function bestAction = findBestAction(userBelief, alphaVector, nVector, nState, ...
    nUserState, nBatteryState, nBaseStation)

stateProb = zeros(nState, 1);

% the last state is not considered when making decisions
for startState = 0: 1: nState - 1
    stateProb(startState + 1) = 1;
    
    [user, battery] = state2UserBattery( startState, nUserState, ...
        nBatteryState, nBaseStation );
    for iBaseStation = 1: 1: nBaseStation
        stateProb(startState + 1) = stateProb(startState + 1) * ...
            userBelief(user(iBaseStation) + 1, battery(iBaseStation) + 1, iBaseStation) ;
    end
    
end

Value = -100;
bestAction = -1;

for action = 1: 1: size(nVector)
    for number = 1: 1: nVector(action)
        
        tempVector = zeros(nState, 1);
        tempVector(:) = alphaVector(action, :, number);
        
        newValue = tempVector' * stateProb;
        
        if newValue > Value
            bestAction = action - 1;
            Value = newValue;
        end
        
    end
end
% Value
