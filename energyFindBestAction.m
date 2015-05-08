function bestAction = energyFindBestAction(trMtrAcs, trMtrSen, userBelief, nState, nUserState, ...
    nBatteryState, nBaseStation, expectedEnergy, dropRateConstraints)

stateProb = zeros( nState, 1 );
batteryBelief = zeros( nBatteryState, nBaseStation );

Value = -100;
bestAction = -1;

for action = 0: 1: nBaseStation
    
    nUserBelief = userBeliefUpdate( trMtrAcs, trMtrSen, action, userBelief, ...
        nUserState, nBatteryState, nBaseStation );
    batteryBelief(:) = sum( nUserBelief, 1 );
    newValue = sum( expectedEnergy * batteryBelief );
    % calculate the myopic energy harvested next time slot
    
    if action ~=0
        % calculate the probs that a collision and energy waste accurs
        if nUserState < nBatteryState
            %action
            collisionProbs = sum( userBelief(nUserState, ...
                nUserState + 1 : end, action) );
            newValue = newValue + collisionProbs * (-1);
        end
    end
    
    if newValue > Value
        bestAction = action;
        Value = newValue;
    end
end
