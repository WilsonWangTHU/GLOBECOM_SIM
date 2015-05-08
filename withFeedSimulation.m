function [overallreward, forcedDropRate, energyHarvested] = withFeedSimulation( ...
	trMtrSen, trMtrAcs, BaseStation, nBatteryState, nUserState, ...  
	set_vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
	relativeEUnit, powerStrategy, discount, nRunning, Jsc, ...
	Voc, n, forcedDropConstraints, u_stationaryBelief, ...
	userState, batteryState ) 

% use this to record the reward of each loop
energyHarvested = 0;
overallreward = 0;
userBelief(:, :, :) = u_stationaryBelief;

% it is the belief of state the user knows
userBelief = zeros( nUserState, nBatteryState, nBaseStation );

% get the needed information from the alpha vector from the POMDP
% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;

lastSet = 1;
lastSetDropRate = -1;
currentSet = 1;
currentSetDropRate = -1;

% the bigger the set, the loose the constraints
[vector, nVector] = getBeliefVector( set_vectorFileName(currentSet), 2 * nBaseStation, nState );

% initializing belief
userBelief(:, :, :) = u_stationaryBelief;
nForceDrop = 0;

for iRunning = 1: 1: nRunning * 10
	immediateReward = 0;
	
    % the changing of state
	if mod( iRunning, nRunning ) == 0
				
	end


	fprintf('\n'); fprintf('the running is now: %dth one\n', iRunning);
    % the decision Process
    action = findBestAction(userBelief, vector, nVector, ...
        nState, nUserState, nBatteryState, nBaseStation);
    fprintf('the action is now: %d\n', action);
    
    accessStation = 0;
	% record the first one when necessary
	oldUserState = userState;
	oldBatteryState = batteryState;

	% calculate the immediate reward
	infoStation = mod( action, nBaseStation) + 1;
    if action >= nBaseStation
        accessStation = action - nBaseStation + 1;
		if (batteryState >= 1 && userState == 0) || batteryState >=2
			immediateReward = 1;
		end
	end
    
    % the world changed
    for iBase = 1: 1: nBaseStation
        if iBase == accessStation
            [userState(iBase), batteryState(iBase), chargeBattery] = renewWorldState( ...
                1, trMtrAcs, userState(iBase), batteryState(iBase), sunlightCoeff, ...
                nUserState, nBatteryState, powerStrategy, arrivalRate(Base), ...
                leaveRate(Base), Jsc, Voc, n);
        else
            [userState(iBase), batteryState(iBase), chargeBattery] = renewWorldState( ...
                0, trMtrSen, userState(iBase), batteryState(iBase), sunlightCoeff, ...
                nUserState, nBatteryState, powerStrategy, arrivalRate(Base), ...
                leaveRate(Base), Jsc, Voc, n);
        end
		energyHarvested = energyHarvested + chargeBattery;
    end
	
	% calculate the forced drop
	if oldUserState >= 1 && oldBatteryState >= 2 && userState == 0
		forceDrop = forceDrop + 1;
	end
	
	userBelief = userBeliefUpdate( trMtrAcs, trMtrSen, accessStation, userBelief, ...
        nUserState, nBatteryState, nBaseStation );

    % and the user know the real situation of the BS he senses
    userBelief(:, :, infoStation) = 0;
    userSenseBattery = floor( batteryState(infoStation) );
    userBelief(userState(infoStation) + 1, userSenseBattery + 1, accessStation) = 1;
    

	reward = reward + immediateReward;
end

overallreward = reward;
forcedDropRate = forcedDropRate / nRunning;
