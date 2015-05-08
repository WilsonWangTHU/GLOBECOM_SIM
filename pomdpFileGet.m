function returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
    Jsc, Voc, n, relativeEUnit, collisionConstraints )

% ---------------------------------------------------------------------- %
%
% Global POMDP input file generator for the pomdp-solve made by
% Dr. Cassandra
% This program is written by Tingwu Wang from Tsinghua University. It
% follows the GNU protocols, which is detailed in the license.
%
% function: Generate the POMDP input file needed to calculate the POMDP
%           GLOBAL MAX
% example:
%
% ---------------------------------------------------------------------- %

% nBaseStation = 2;
% nBatteryState = 2;
% nUserState = 2;
% filename = 'testOutputFile.POMDP';
% arrivalRate = [0.1, 0.1];
% leaveRate = [0.1, 0.1];
% sunlightCoeff = [1, 0.7];
% E_Unit = 1;
% powerStrategy = 1;
% discount = 0.9;
% 	Jsc = 13.364; % the statistic in our model
%	Voc = 0.7631; %
% 	n = 2;
% 	forcedDropConstraints = 0.1;
% % ---------------------- %

accessReward = 1;

penaltyReward = - (1 - collisionConstraints) / ...
    collisionConstraints * accessReward;

% how to denote a state? Here is the standard process just use the function 
% to transform

[trMtrSen, trMtrAcs, powerSample, probQ] = transMatrixGet( ...
    nBaseStation, nBatteryState, nUserState, ...
    arrivalRate, leaveRate, powerStrategy, ...
    sunlightCoeff, Jsc, Voc, n, relativeEUnit );

checkSum = transMatrixTest(nUserState, nBatteryState, ...
    nBaseStation, trMtrSen, trMtrAcs);

checkFlag = 1; % check that the transition matrix has good probability sum;
if checkSum == 0
    checkFlag = 0;
end

inputFile = fopen( filename, 'w' );

% the input prefix of the input file declare the basic input information
fprintf( inputFile, 'discount: %f\n', discount );
fprintf( inputFile, 'values: reward\n' );

% the number of states
singleState = 1 + (nBatteryState - 1) * nUserState;
nState = singleState ^ nBaseStation;
fprintf( inputFile, 'states: %d\n', nState );

% action 0 ~ 2 * nBaseStation - 1, action sense the i^th BS = i - 1, 
% access the i^th BS = i + nBaseStation - 1
fprintf( inputFile, 'actions: %d\n', 2 * nBaseStation );

% obeservation = 0, for draining (b = 1, u = 1), and others would be
% userState(1~nU) + (batteryState(2~nB) - 2) * nU
fprintf( inputFile, 'observations: %d\n\n', ...
    nUserState * (nBatteryState - 1) + 1 );

% --------------------------------------------------------------------------------- %
% state transition part: format T : <action> : <start-state> : <end-state> %f
% state transition when action == sense
for action = 0: 1: 2 * nBaseStation - 1
    if action <= nBaseStation - 1
        accessStation = 0;
    else
        accessStation = action - nBaseStation + 1;
    end
    
    for startState = 0: 1: nState - 1 % loop all the ordinary system state
        stateTransProb = zeros( nState, 1 );
        
        [startUser, startBattery] = state2UserBattery( ...
                startState, nUserState, nBatteryState, nBaseStation );
        
        for endState = 0: 1: nState - 1
            
            
            [endUser, endBattery] = state2UserBattery( ...
                endState, nUserState, nBatteryState, nBaseStation );
            
            stateTransProb(endState + 1) = 1; % initialize transition probs
            for iBaseStation = 1: 1: nBaseStation
                if iBaseStation == accessStation
                    stateTransProb(endState + 1) = ...
                        stateTransProb(endState + 1) * ...
                        trMtrAcs(startUser(iBaseStation) + 1, ...
                            startBattery(iBaseStation) + 1,...
                            endUser(iBaseStation) + 1, ...
                            endBattery(iBaseStation) + 1, iBaseStation);
                else
                    stateTransProb(endState + 1) = ...
                        stateTransProb(endState + 1) * ...
                        trMtrSen(startUser(iBaseStation) + 1, ...
                            startBattery(iBaseStation) + 1,...
                            endUser(iBaseStation) + 1, ...
                            endBattery(iBaseStation) + 1, iBaseStation);
                end
            end
            if stateTransProb(endState + 1) < 0
                stateTransProb(endState + 1)
            end
            fprintf(inputFile,'T : %d : %d : %d %f\n', ...
                action, startState, endState, stateTransProb(endState + 1));
        end
        checkSum = sum(stateTransProb);

        if abs(checkSum - 1) > 1e-7
            checkFlag = 0; % check for good probability sum;
            fprintf( 'Bad probability sum for start user %d, battery %d\n', ...
                startUser(iBaseStation), startUser(iBaseStation) );
            fprintf( 'Probability sum is %f\n\n', checkSum );

        end
    end
end


fprintf( inputFile, '\n');

if checkFlag ~= 1
    fprintf( 'Simulation fails\n' );
end
% observation model format O : <action> : <end-state> : <observation> %f
% This specifies a probability of observing each possible observation for
% a particular action and ending state. In our cases, we have a zero or one
% probability distribution. What matters is the action (which determines
% the BS we considers), and the endState (which determines what observation
% we will have)

% --------------------------------------------------------------------------------- %
% when action = sense / access
for action = 0 : 1 : 2 * nBaseStation - 1
    
    if action >= nBaseStation % the action is a access
        accessStation  = action - nBaseStation + 1;
    else accessStation = action + 1; % the action is a sensing
    end
    
    % the observation only tells about the full infomation of the target BS
    for endState = 0: 1: nState - 1  % looping all the possible observation
        % now we knew what observation we will receive, given the endstate
        % and the target BS, which is denoted as "accessStation"
        % obeservation = 0, for draining (b = 1, u = 1), and others would be
        % userState(1~nU) + (batteryState(2~nB) - 2) * nU
        [endUser, endBattery] = state2UserBattery( endState, nUserState, ...
            nBatteryState, nBaseStation );
        if endBattery(accessStation) + 1 == 1
            observation = 0;
        else
            observation = (endUser(accessStation) + 1) + ...
                (endBattery(accessStation) + 1 - 2) * nUserState;
        end
        fprintf( inputFile, 'O : %d : %d : %d %f\n', ...
            action, endState, observation, 1 );
        % fprintf( 'O : %d : %d : %d %f\n', action, endState, observation, 1 );
    end
end

fprintf( inputFile, '\n');

% reward definition
% --------------------------------------------------------------------------------- %
% format R : <action> : <start-state> : <end-state> : <observation> %f

% action = sense
for action = 0: 1: nBaseStation - 1
    fprintf( inputFile,'R : %d : * : * : * %f\n', action, 0 );
end

% action = access
for action = nBaseStation : 2 * nBaseStation - 1
    accessStation = action + 1 - nBaseStation;
    for startState = 0: 1: nState - 1
        for endState = 0: 1: nState - 1
            [startUser, startBattery] = state2UserBattery( ...
                startState, nUserState, nBatteryState, nBaseStation );
            [endUser, endBattery] = state2UserBattery( ...
                endState, nUserState, nBatteryState, nBaseStation );
            
            if startBattery(accessStation) <= startUser(accessStation) || ...
                startBattery(accessStation) == 1 && startUser(accessStation) == 0
                % not enough battery, access fails
                reward = 0;
            else
                if startUser == nUserState - 1  % it is a confliction
                    reward = penaltyReward;
                else
                    reward = accessReward;
                end
            end
            
            
            fprintf( inputFile,'R : %d : %d : %d : * %f\n', ...
                action, startState, endState, reward );
        end
    end
end

returnFlag = 1; % the writing of files succeeds

fclose(inputFile);