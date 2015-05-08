function finalReward = simulation(nBaseStation, nBatteryState, nUserState, ...
	filename, vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
	E_Unit, powerStrategy, discount, nRunning, senseCost, accessFail)
% sun light and energy is continuous variable user is a discrete variable

% the number of basestation, battery state, and the number of users in 
% eahc base station
% nBaseStation = 2;
% nBatteryState = 2;
% nUserState = 2;

% the results of the POMDP-SOLVE
% filename = 'testOutputFile.POMDP';
% vectorFileName = 'pomdpOutputFile.alpha';

% the parameter of the Base station
% arrivalRate = [0.1, 0.1];
% leaveRate = [0.1, 0.1];
% sunlightCoeff = [1, 0.7];

% E_Unit = 1;
% powerStrategy = 1;
% discount = 0.9;
% nRunning = 20;

% senseCost = - 0.1;
% accessFail = - 1;

% it is the actual state, it is continuous battery state and discrete user
% state. Only the world knows it.
userState = ones(nBaseStation, 1);
batteryState = ones(nBaseStation, 1);

% it is the belief of state the user knows
u_Belief = zeros(nUserState, nBatteryState, nBaseStation);

% get the needed information from the alpha vector from the POMDP
[vector, nVector] = getBeliefVector(vectorFileName, 2 * nBaseStation + 1, ...
    (nBatteryState * nUserState) ^nBaseStation + 1);

% it is the transition Matrix, both the user and the actual world know it
% and use it. the P_Sample is the maximum definite power
[transitionMatrix, P_Sample] = transMatrixGenerator(nBaseStation, nBatteryState, ...
    nUserState, arrivalRate, leaveRate, powerStrategy, sunlightCoeff, E_Unit);

% initial the actual state, running for a random number of time.
initialRunning = ceil( 10000 * rand(1) );
for temp = 1: 1: initialRunning
    % change the battery State
    for Base = 1: 1: nBaseStation
        [userState(Base), batteryState(Base)] = renewWorldState(...
            transitionMatrix, userState(Base), batteryState(Base), 0, sunlightCoeff, ...
            nUserState, nBatteryState, powerStrategy, arrivalRate(Base), leaveRate(Base));
    end
    % if min(batteryState) < 1
    %     batteryState
    % end
end

% the user uses the stationary Probability
u_stationaryBelief = getStaionaryProb(transitionMatrix, ...
    nUserState, nBatteryState, nBaseStation);

% use this to record the reward of each loop
Reward = zeros(nRunning, 1);
u_Belief(:, :, :) = u_stationaryBelief;
for RunningLoop = 1: 1: nRunning
    fprintf('\n');
    fprintf('the running is now: %d\n', RunningLoop);
    % initializing!
    initialRunning = ceil( 10 * rand(1) );
    
    for temp = 1: 1: initialRunning
        % change the battery State
        for Base = 1: 1: nBaseStation
            [userState(Base), batteryState(Base)] = renewWorldState(...
                transitionMatrix, userState(Base), batteryState(Base), 0, sunlightCoeff, ...
                nUserState, nBatteryState, powerStrategy, arrivalRate(Base), leaveRate(Base));
        end
        u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
            nUserState, nBatteryState, nBaseStation);
    end
    
    if RunningLoop == 1
        % the initial belief
        u_Belief(:, :, :) = u_stationaryBelief;
    end
    
    Reward(RunningLoop) = 0;
    
    % this denotes whether the user is in the system
    UserIn = 0;
    AccessBS = 0;
    
    % the decision Process
    while 1
        if UserIn == 0 % the user is not in any of the BSs
            % decide what to do now
            action = findBestAction(u_Belief, vector, nVector, ...
                (nBatteryState * nUserState) ^nBaseStation + 1, nUserState,...
                nBatteryState, nBaseStation);
            u_Belief;
            fprintf('the action is now: %d\n', action);
            % the world changed
            for Base = 1: 1: nBaseStation
                [userState(Base), batteryState(Base)] = renewWorldState( ...
                    transitionMatrix, userState(Base), batteryState(Base ), 0, sunlightCoeff, ...
                    nUserState, nBatteryState, powerStrategy, arrivalRate(Base), leaveRate(Base));
            end
            
            
            if action <= nBaseStation
                % the action is the sensing
                u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                    nUserState, nBatteryState, nBaseStation);
                
                % and the user know the real situation of the BS he senses
                u_Belief(:, :, action) = 0;
                userSenseBattery = ceil( batteryState(action) );
                u_Belief(userState(action), userSenseBattery, action) = 1;

                Reward(RunningLoop) = Reward(RunningLoop) + senseCost;
            else
                
                % the action is accessing
                if action <= 2 * nBaseStation
                    UserIn = 1;
                    
                    if userState(action - nBaseStation) == nUserState || batteryState(action - nBaseStation) == 1
                        % unable to get in, huge access fail cost
                        Reward(RunningLoop) = Reward(RunningLoop) + accessFail;
                        UserIn = 0;
                        
                        
                        fprintf('the accessing of %d failed\n', action);
                        
                        u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                            nUserState, nBatteryState, nBaseStation);
                        
                        % get the information of the BS that failed
                        userSenseBattery = ceil( batteryState(action - nBaseStation) );
                        
                        % updating the infomation
                        u_Belief(:, :, action - nBaseStation) = 0;
                        u_Belief(userState(action - nBaseStation), ...
                            userSenseBattery, action - nBaseStation) = 1;
                        
                        Reward(RunningLoop) = Reward(RunningLoop) + senseCost;
                    else
                        % we need to count the first One when the access
                        % succeed
                        
                        u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                            nUserState, nBatteryState, nBaseStation);
                        
                        userState(action - nBaseStation) = userState(action - nBaseStation) + 1;
                        Reward(RunningLoop) = Reward(RunningLoop) + ...
                            log ( 1 + powerStrategy / ((userState(action - nBaseStation) - 2) * E_Unit + 1) );
                        
                        AccessBS = action - nBaseStation;
                        
                        
                        % get the information
                        userSenseBattery = ceil( batteryState(action - nBaseStation) );
                        % updating the infomation
                        u_Belief(:, :, action - nBaseStation) = 0;
                        u_Belief(userState(action - nBaseStation), ...
                            userSenseBattery, action - nBaseStation) = 1;
                    end
                    
                else
                    % the user choose to sleep he will end this round
                    
                    u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                        nUserState, nBatteryState, nBaseStation);
                    break
                end
                
            end
            
            
        else
            % the user is already in a BS
            
            % the world changed
            % the userIn is 1 now
            drop = zeros(3, 1);
            for Base = 1: 1: nBaseStation
                [userState(Base), batteryState(Base), drop(Base)] = renewWorldState( ...
                    transitionMatrix, userState(Base), batteryState(Base), ...
                    1 * (AccessBS == Base), sunlightCoeff, nUserState, ...
                    nBatteryState, powerStrategy, arrivalRate(Base), leaveRate(Base));
            end
            
            if any(drop) % the user is out! sad!
                
                % get the information updated
                
                u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                    nUserState, nBatteryState, nBaseStation);
                
                userSenseBattery = ceil( batteryState(AccessBS) );
                % updating the infomation
                u_Belief(:, :, AccessBS) = 0;
                u_Belief(userState(AccessBS), ...
                    userSenseBattery, AccessBS) = 1;
                
                break
            else
                x = rand(1);
                if discount < x
                    % the user choose to leave
                    
                    u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                        nUserState, nBatteryState, nBaseStation);
                    break
                else
                    Reward(RunningLoop) = Reward(RunningLoop) + ...
                        log ( 1 + powerStrategy / ((userState(AccessBS) - 2) * E_Unit + 1) );
                    
                    % no need to update the BS the user's in, could do it
                    % when it leaves it.
                    u_Belief = userBeliefUpdate(transitionMatrix, u_Belief, ...
                        nUserState, nBatteryState, nBaseStation);
                end
            end
            
        end
    end
end
finalReward = sum(Reward)
