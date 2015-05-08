function [overallreward, collisionDropRate, energyHarvested, nAccess] = energySimulation( ...
    trMtrSen, trMtrAcs, nBaseStation, nBatteryState, nUserState, ...
    vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, ...
    Voc, n, collisionConstraints, u_stationaryBelief, ...
    userState, batteryState, expectedEnergy, powerMax )

% use this to record the reward of each loop
overallreward = 0;
energyHarvested = 0;
nAccess = 0;
% get the needed information from the alpha vector from the POMDP
% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;

% it is the belief of state the user knows
userBelief = zeros( nUserState, nBatteryState, nBaseStation );
userBelief(:, :, :) = u_stationaryBelief;

% initializing belief
userBelief(:, :, :) = u_stationaryBelief;


% the waiting list of energy harvesting algorithm
waitingList = [1: 1: nBaseStation];
nCollision = 0;
for iRunning = 1: 1: nRunning
        
    fprintf('\n'); fprintf('in the %dth time slot\n', iRunning);
    % the decision Process
    % note the defination of action is different!
    
    action = energyFindBestAction(trMtrAcs, trMtrSen, userBelief, ...
        nState, nUserState, nBatteryState, nBaseStation, expectedEnergy, collisionConstraints);
    fprintf( 'the action is now: %d\n', action );

    fprintf( 'the overallreward is now: %d\n', overallreward );
    for iBase = 1: 1: nBaseStation
        fprintf('And for base %d, the true battery is %d, user is %d\n', ...
            iBase, batteryState(iBase), userState(iBase));
    end
    infoStation = 0;
    accessStation = 0;
    % update the waiting list
    if nBaseStation > 1
        if action == 0
            temp = waitingList(1);
            waitingList(1: end - 1) = waitingList(2 : end);
            waitingList(end) = temp;
            infoStation = temp;
        else
            nAccess = nAccess + 1;
            position = find(waitingList == action);
            infoStation = action;
            accessStation = action;
            if position ~= nBaseStation
                % not the end of waiting
                waitingList(position: end - 1) = waitingList(position + 1: end);
                waitingList(end) = position;
            end
        end
    else % only one base station
        infoStation = 1;
        accessStation = (action == 1);
        nAccess = nAccess + accessStation;
    end
%     
%     % record the first one when necessary
%     oldUserState = userState;
%     oldBatteryState = batteryState;
    
    % calculate the immediate reward
    if action >= 1
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

collisionDropRate = nCollision / nAccess;
