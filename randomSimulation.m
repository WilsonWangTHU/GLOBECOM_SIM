function [overallreward, collisionDropRate, energyHarvested, nAccess] = randomSimulation( ...
    trMtrSen, trMtrAcs, nBaseStation, nBatteryState, nUserState, ...
    vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, ...
    Voc, n, collisionConstraints, u_stationaryBelief, ...
    userState, batteryState, powerMax )

% nBaseStation = 2;
% nBatteryState = 3;
% nUserState = 2;
% arrivalRate = [0.1, 0.1];
% leaveRate = [0.1, 0.1];
% sunlightCoeff = [1, 0.0001];
% relativeEUnit = 1;
% powerStrategy = 1;
% discount = 0.9;
% Jsc = 13.364; % the statistic in our model
% Voc = 0.7631; %
% n = 2;
% forcedDropConstraints = 0.1;

% use this to record the reward of each loop
overallreward = 0;
nAccess = 0;
PUreward = 0;

% initializing belief

% it is the belief of state the user knows
energyHarvested = 0;
nCollision = 0;

for iRunning = 1: 1: nRunning
    for iB = 1: 1: nBaseStation
        PUreward = PUreward + min(userState(iB), batteryState(iB));
    end
    fprintf('\n'); fprintf('in the %dth time slot\n', iRunning);
    % the decision Process
    action = floor( rand(1,1) * 2 * nBaseStation );
    if action == 2 * nBaseStation
        action = action - 1;
    end
    if action ~= 0
        nAccess = nAccess + 1;
    end
    fprintf( 'the action is now: %d\n', action );

    fprintf( 'the overallreward is now: %d\n', overallreward );
    for iBase = 1: 1: nBaseStation
        fprintf('And for base %d, the true battery is %d, user is %d\n', ...
            iBase, batteryState(iBase), userState(iBase));
    end
    
    accessStation = 0;
    if action >= nBaseStation
        nAccess = nAccess + 1;
        accessStation = action - nBaseStation + 1;
        
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
    
    % calculate the forced drop
%     % calculate the forced drop
%     if oldUserState(infoStation) >= 1 && oldBatteryState(infoStation) >= 2 && ...
%             userState(infoStation) == 0 && action >= nBaseStation && drop(action - nBaseStation + 1) == 1
%         nForceDrop = nForceDrop + 1;
%     end
    
end

energyHarvested = PUreward;
collisionDropRate = nCollision / nAccess;
