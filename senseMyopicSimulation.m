function [overallreward, collisionDropRate, energyHarvested, nAccess] = senseMyopicSimulation( ...
    trMtrSen, trMtrAcs, nBaseStation, nBatteryState, nUserState, ...
    vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, ...
    Voc, n, collisionConstraints, u_stationaryBelief, ...
    userState, batteryState, powerMax )

% use this to record the reward of each loop
overallreward = 0;
energyHarvested = 0;
nAccess = 0;
% get the needed information from the alpha vector from the POMDP
% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;

PUreward = 0;
% it is the belief of state the user knows
userBelief = zeros( nUserState, nBatteryState, nBaseStation );
userBelief(:, :, :) = u_stationaryBelief;

% initializing belief
userBelief(:, :, :) = u_stationaryBelief;

nCollision = 0;
senseStation = -1; % if this flag is 1, then the sense is already done
for iRunning = 1: 1: nRunning
    for iB = 1: 1: nBaseStation
        PUreward = PUreward + min(userState(iB), batteryState(iB));
    end
    
    fprintf('\n'); fprintf('in the %dth time slot\n', iRunning);
    % the decision Process
    % note the defination of action is different!
    if senseStation == -1 % haven't sense
        action = myopicFindBestAction(trMtrAcs, trMtrSen, userBelief, ...
            nState, nUserState, nBatteryState, nBaseStation, ...
            collisionConstraints, 1, 0);
        senseStation = action - nBaseStation + 1;
        action = senseStation - 1;
    else % sensed already!
        if batteryState(senseStation) >= ( 1 + userState(senseStation)) && ...
                userState(senseStation) < nUserState && ...
                ~(batteryState(senseStation) >= 1 && batteryState(senseStation) < 2 && userState(senseStation) == 0) ...
                && userState(senseStation) ~= nUserState - 1
            % it is going to be a success!
            action = senseStation + nBaseStation - 1;
            senseStation = -1; % reset the flag
        else
            % do the sense again
            action = myopicFindBestAction(trMtrAcs, trMtrSen, userBelief, ...
                nState, nUserState, nBatteryState, nBaseStation, ...
                collisionConstraints, 1, 0);
            senseStation = action - nBaseStation + 1;
            action = senseStation - 1;
        end
    end
    fprintf( 'the action is now: %d\n', action );
    
    fprintf( 'the overallreward is now: %d\n', overallreward );
    for iBase = 1: 1: nBaseStation
        fprintf('And for base %d, the true battery is %d, user is %d\n', ...
            iBase, batteryState(iBase), userState(iBase));
    end
    
    accessStation = 0;
    
    % calculate the immediate reward
    infoStation = mod( action, nBaseStation) + 1;
    if action >= nBaseStation
        accessStation = action - nBaseStation + 1;
        nAccess = nAccess + 1;
        
        % succeed if the BS has enough battery and no collision accurs
        if batteryState(accessStation) >= ( 1 + userState(accessStation)) && ...
                userState(accessStation) < nUserState && ...
                ~(batteryState(accessStation) >= 1 && batteryState(accessStation) < 2 && userState(accessStation) == 0) ...
                && userState(accessStation) ~= nUserState - 1
            % (batteryState(accessStation) >= 1 && userState(accessStation) == 0) || batteryState(accessStation) >=2
            overallreward = overallreward + 1;
            fprintf('Access succeeds!\n');
        else
            if userState(accessStation) == nUserState - 1 && batteryState(accessStation) >= ( 1 + userState(accessStation))
                fprintf('Access fails! A collision accurs\n');
                nCollision = nCollision + 1;
            else
                fprintf('Access fails! No enough battery\n');
            end
        end
    end
    
    % the world changed
    drop = zeros(nBaseStation, 1);
    for iBase = 1: 1: nBaseStation
        if iBase == accessStation
            [userState(iBase), batteryState(iBase), chargeBattery, drop(iBase)] = renewWorldState( ...
                1, trMtrAcs, userState(iBase), batteryState(iBase), sunlightCoeff, ...
                nUserState, nBatteryState, powerStrategy, arrivalRate(iBase), ...
                leaveRate(iBase), Jsc, Voc, n, powerMax);
        else
            [userState(iBase), batteryState(iBase), chargeBattery, drop(iBase)] = renewWorldState( ...
                0, trMtrSen, userState(iBase), batteryState(iBase), sunlightCoeff, ...
                nUserState, nBatteryState, powerStrategy, arrivalRate(iBase), ...
                leaveRate(iBase), Jsc, Voc, n, powerMax);
        end
        energyHarvested = energyHarvested + chargeBattery;
    end
    
%     % calculate the forced drop
%     if oldUserState(infoStation) >= 1 && oldBatteryState(infoStation) >= 2 && ...
%             userState(infoStation) == 0 && action >= nBaseStation && drop(action - nBaseStation + 1) == 1
%         nForceDrop = nForceDrop + 1;
%     end
    
    userBelief = userBeliefUpdate( trMtrAcs, trMtrSen, accessStation, userBelief, ...
        nUserState, nBatteryState, nBaseStation );
    
    % and the user know the real situation of the BS he senses
    userBelief(:, :, infoStation) = 0;
    userSenseBattery = floor( batteryState(infoStation) );
    userBelief(userState(infoStation) + 1, userSenseBattery + 1, infoStation) = 1;

end

energyHarvested = PUreward;
collisionDropRate = nCollision / nAccess;
