function bestAction = myopicFindBestAction(trMtrAcs, trMtrSen, userBelief, ...
    nState, nUserState, nBatteryState, nBaseStation, ...
    forcedDropConstraints, senseFirst, wait)
if senseFirst == 0 % the pure myopic method
    
    Value = -100;
    bestAction = -1;
    
    for iBase = 1: 1: nBaseStation
        tempVector = squeeze(userBelief(:, :, iBase));
        energy = [0: 1: nBatteryState - 1];
        
        newValue = energy * sum( tempVector, 1 )';
        % calculate the myopic energy harvested next time slot
        
        if newValue > Value
            bestAction = iBase - 1 + nBaseStation;
            Value = newValue;
        end
    end
else % the pure CSMA method
    Value = -100;
    bestAction = -1;
    
    for iBase = 1: 1: nBaseStation
        
        tempVector = squeeze(userBelief(:, :, iBase));
        
        energy = [0: 1: nBatteryState - 1];
        averageBattery = energy * sum( tempVector, 1 )';
        
        user = [0: 1: nUserState - 1];
        averageUser = user * sum( tempVector, 2 ) + 1;
        
        % calculate the myopic energy harvested next time slot
        newValue = averageBattery / averageUser;
        
        if newValue > Value
            bestAction = iBase - 1 + nBaseStation;
            Value = newValue;
        end
    end
end

% the process is sleeping!
if wait ~= 0
    bestAction = bestAction - nBaseStation;
end