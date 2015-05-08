function returnFlag = inputfile(nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, E_Unit, powerStrategy,...
    discount, senseCost, accessFail, accessGain )
% 
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
% % ---------------------- %
% senseCost = - 0.1;
% accessFail = - 1;
% accessGain = zeros(nUserState, nBatteryState, nBaseStation);

for station = 1: 1: nBaseStation
    
    R = MDPvalueGenerator(nBatteryState, nUserState, arrivalRate(station), leaveRate(station),...
        powerStrategy, sunlightCoeff, E_Unit, discount);
    
    for user = 1: 1: nUserState
        for battery = 1: 1: nBatteryState
            if battery == 1 || user == nUserState
                accessGain(user, battery, station) = 0;
            else
                % the format used in MDPvalueGenerator is like below
                % startState = (start_battery - 2) * (nUserState - 1) + start_user;
                % note that there are accessGain that we will not use
                R_State = (battery - 2) * (nUserState - 1) + user;
                accessGain(user, battery, station) = R(R_State);
            end
        end
    end
end
[transitionMatrix, P_Sample] = transMatrixGenerator(nBaseStation, nBatteryState, nUserState, arrivalRate, leaveRate,...
    powerStrategy, sunlightCoeff, E_Unit);
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

inputFile = fopen( filename,'w' );

% the input prefix of the input file declare the basic input information
fprintf( inputFile, 'discount: %f\n', discount );
fprintf( inputFile, 'values: reward\n' );

% the states number of s(m_i, n_i) = \sigma ((m_i - 1) * nBatteryState +
% n_i) * (nUser * nBattery) ^ (nBaseStation - i)
nState = (nUserState * nBatteryState) ^nBaseStation;
fprintf( inputFile, 'states: %d\n', nState + 1 );

% action sense the i^th BS = i, access the i^th BS = i + nBaseStation
% action sleep = 2 * nBaseStation + 1
fprintf( inputFile, 'actions: %d\n', 2 * nBaseStation + 1 );

% obeservation = (m - 1) * nBatteryState + n
fprintf( inputFile, 'observations: %d\n\n', nUserState * nBatteryState );

% state transition part:
% format T : <action> : <start-state> : <end-state> %f

% state transition when action == sense
for action = 1: 1: nBaseStation
    
    for start_state = 1: 1: nState % loop all the ordinary system state
        % the special nState + 1 is different
        start_state;
        for end_state = 1: 1: nState
            
            % distract the states of each BS
            start_BatteryState = zeros( nBaseStation, 1 );
            start_UserState = zeros( nBaseStation, 1 );
            
            end_BatteryState = zeros( nBaseStation, 1 );
            end_UserState = zeros( nBaseStation, 1 );
            
            transProb = zeros( nBaseStation, 1 ); % the state transition
            % prob is the times of all the transProb of each Base station
            stateTransProb = 1;
            for count = 1: 1: nBaseStation % distract the index of each
                % states of BS
                
                % calculate the corresponding start, end state of each BS
                % it is for the convenience of calculation the start state
                temp = floor( (start_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
                temp = mod( temp, (nUserState * nBatteryState) );
                
                start_BatteryState(count) = mod( temp, nBatteryState );
                start_UserState(count) = (temp - start_BatteryState(count)) / nBatteryState + 1;
                start_BatteryState(count) = start_BatteryState(count) + 1;
                % the end state
                temp = floor( (end_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
                temp = mod( temp, (nUserState * nBatteryState) );
                
                end_BatteryState(count) = mod( temp, nBatteryState );
                end_UserState(count) = (temp - end_BatteryState(count)) / nBatteryState + 1;
                end_BatteryState(count) = end_BatteryState(count) + 1;
                
                
                % sensing doesn't affect the transition just use the raw
                % transition Matrix to calculate the transition probability
                transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count),...
                    end_UserState(count), end_BatteryState(count), count );
                
                % state Transition probability is the product of the
                % transition probability of each BS separately, meaning P =
                % p_1 * p_2 * ... * p_nBaseStation
                stateTransProb = stateTransProb * transProb(count);
            end
            
            if start_state == 25 && action == 1
                
                stateTransProb
            end
            fprintf(inputFile,'T : %d : %d : %d %f\n', action - 1, start_state - 1, end_state - 1, stateTransProb);
         end
%         
%         start_UserState(1)
%         start_BatteryState(1),
%         start_UserState(2)
%         start_BatteryState(2),
        if start_state == 25
        
        end
        fprintf(inputFile,'T : %d : %d : %d %f\n', action - 1, start_state - 1, nState + 1 - 1, 0);
    end
end

% when "started" with the nState + 1 state, whatever action or end_state is
% meaningless, as it is an absorbing state with no reward.
for end_state = 1: 1: nState + 1
    if end_state ~= nState + 1
        fprintf(inputFile,'T : * : %d : %d %f\n', nState + 1 - 1, end_state - 1, 0);
    else
        fprintf(inputFile,'T : * : %d : %d %f\n', nState + 1 - 1, nState + 1 - 1, 1);
    end
end

% state transition when action == access
for action = 1 + nBaseStation: 1: 2 * nBaseStation
    
    % the transition probability when start_state = nState + 1 is already
    % declare in the above code
    
    % note that a user cannot do anything when in state = nState + 1 for it
    % is an absorbing state. Below we consider the normal state = [1: 1:
    % nState]
    for start_state = 1: 1: nState % making a access decision in normal state
        start_BatteryState = zeros( nBaseStation, 1 );
        start_UserState = zeros( nBaseStation, 1 );
        
        for count = 1: 1: nBaseStation % distract the index of each states
            % of BS count denotes which BS we are
            % considering in the program
            
            
            % distract the BS's state of each BS
            temp = floor( (start_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
            temp = mod( temp, (nUserState * nBatteryState) );
            start_BatteryState(count) = mod( temp, nBatteryState );
            start_UserState(count) = (temp - start_BatteryState(count)) / nBatteryState + 1;
            start_BatteryState(count) = start_BatteryState(count) + 1;
        end
        
        % failure Probability is the collection of the situation when the
        % access is denied because of too many user (UserState > nUserState)
        % or too less battery volumn, namly BatteryState = 1, which is no
        % battery left in this case. We cummulate the failure probs to get
        % the success prob
        failureProbability = 0;
        
        for end_state = 1: 1: nState % the access is a failure, lets calcu-
            % late its probs
            
            end_BatteryState = zeros( nBaseStation, 1 );
            end_UserState = zeros( nBaseStation, 1 );
            
            transProb = zeros( nBaseStation, 1 );
            stateTransProb = 1;
            
            for count = 1: 1: nBaseStation % distract the index of each
                % states of BS
                
                temp = floor( (end_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
                temp = mod( temp, (nUserState * nBatteryState) );
                end_BatteryState(count) = mod( temp, nBatteryState );
                end_UserState(count) = (temp - end_BatteryState(count)) / nBatteryState + 1;
                
                end_BatteryState(count) = end_BatteryState(count) + 1;
                
                % If we are considering a BS that is not the BS we accessd
                % just use the raw transition Matrix to get the transProb
                if (action - nBaseStation) ~= count
                    transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                        end_UserState(count), end_BatteryState(count), count);
                else
                    % If we are considering the BS, which we are accessing
                    % the prob when failure accurs in this BS
                    
                    % note that only when User are full can we expect a
                    % fail access and return to the normal state
                    % (when access succeed, we get the special 'nState + 1')
                    
                    if start_UserState(count) == nUserState - 1
                        % it will fail when another user access and no
                        % original users choose to leave.
                        % note that if end_user is not nUserState the access
                        % fail situation will never happen! it will be
                        % either impossible, or simply succeed and be
                        % considered as a "nState + 1" state (eg, end_user
                        % = nUserState - 1 will be considerd as success and
                        % regarded as "nState + 1")
                        if end_UserState(count) == nUserState
                            % regardless of the battery, just the people
                            % too much we use the transition Matrix
                            transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                                end_UserState(count), end_BatteryState(count), count);
                            
                        else
                            % it is not going to fail because of the user
                            % but possible because of the battery
                            if end_BatteryState(count) == 1
                                % the battery is going to fail!
                                transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                                    end_UserState(count), end_BatteryState(count), count);
                            else
                                % it is not going to fail!
                                transProb(count) = 0;
                            end
                        end
                        
                    else if start_UserState(count) == nUserState
                            % the situation is similar, success when no new
                            % user arrives and one users choose to leave
                            
                            if end_UserState(count) == nUserState
                                % regardless of the battery, just the people
                                % too much we use the transition Matrix
                                transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                                    end_UserState(count), end_BatteryState(count), count);
                                
                            else
                                % it is not going to fail because of the user
                                % but possible because of the battery
                                if end_BatteryState(count) == 1
                                    % the battery is going to fail!
                                    transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                                        end_UserState(count), end_BatteryState(count), count);
                                else
                                    % it is not going to fail!
                                    transProb(count) = 0;
                                end
                            end
                            
                        else
                            % if start_user < nUserState - 1
                            % it is always a success access!
                            if end_BatteryState(count) == 1
                                % the battery is going to fail!
                                transProb(count) = transitionMatrix( start_UserState(count), start_BatteryState(count), ...
                                    end_UserState(count), end_BatteryState(count), count);
                            else
                                % it is not going to fail!
                                transProb(count) = 0;
                            end
                        end
                    end
                end
                
                % times it into the state transtion probability
                stateTransProb = stateTransProb * transProb(count);
            end
            
            fprintf(inputFile,'T : %d : %d : %d %f\n', action - 1, start_state - 1, end_state - 1, stateTransProb);
            failureProbability = failureProbability + stateTransProb;
        end
        
        % transition probability when the access is a success, we use
        % 1 - failure probability to calculate its value
        fprintf(inputFile,'T : %d : %d : %d %f\n', action - 1, start_state - 1, nState + 1 - 1, 1 - failureProbability);
        
        %         % probs when success
        %         if start_UserState(action - nBaseStation) == nUserState - 1;
        %             PSuccess = 1 - arrivalRate(count) * (1 - (start_UserState(count) - 1) * leaveRate(count));
        %         else if start_UserState(action - nBaseStation) == nUserState;
        %                 PSuccess = ((start_UserState(count) - 1) * leaveRate(count)) * (1 - arrivalRate);
        %             else
        %                 PSuccess = 1;
        %             end
        %         end
        %         fprintf(inputFile,'T : %d : %d : %d %f\n', action, start_state, nState + 1, 0);
    end
end

% when access = sleep
% there seems to a covering...
for end_state = 1: 1: nState + 1
    for start_state = 1: 1: nState
        if end_state ~= nState + 1
            fprintf( inputFile,'T : %d : %d : %d %f\n', 1 + 2 * nBaseStation - 1, start_state - 1, end_state - 1, 0 );
        else
            fprintf( inputFile,'T : %d : %d : %d %f\n', 1 + 2 * nBaseStation - 1, start_state - 1, end_state - 1, 1 );
        end
    end
end
fprintf(inputFile, '\n');

% observation model format O : <action> : <end-state> : <observation> %f
% This specifies a probability of observing each possible observation for
% a particular action and ending state. In our cases, we have a zero or one
% probability distribution. What matters is the action (which determines
% the BS we considers), and the end_state (which determines what observation
% we will have)

% when action = sense / access
for action = 1 : 1 : 2 * nBaseStation
    
    end_BatteryState = zeros( nBaseStation, 1 );
    end_UserState = zeros( nBaseStation, 1 );
    stateTransProb = 1;
    
    if action > nBaseStation % the action is a access
        station_Notation  = action - nBaseStation;
    else station_Notation = action; % the action is a sensing
    end
    
    % the observation only tells about the full infomation of the target BS
    for end_state = 1: 1: nState + 1 % looping all the possible observation
        if end_state ~= nState + 1 % the normal states
            
            for count = 1: 1: nBaseStation % distract the index of each states of BS
                temp = floor( (end_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
                temp = mod( temp, (nUserState * nBatteryState) );
                end_BatteryState(count) = mod( temp, nBatteryState );
                end_UserState(count) = (temp - end_BatteryState(count)) / nBatteryState + 1;
                end_BatteryState(count) = end_BatteryState(count) + 1;
            end
            
        else
            % in the absorbing state, the observation is not important
            % let's just assume that they are all ones
            end_BatteryState(:) = 1;
            end_UserState(:) = 1;
        end
        
        % now we knew what observation we will receive, given the endstate
        % and the target BS, which is denoted as "station_Notation"
        % obeservation = (m - 1) * nBatteryState + n
        observation = (end_UserState(station_Notation) - 1) * nBatteryState + end_BatteryState(station_Notation);
        if end_state == 25 && action == 1
            observation
        end
        for observe = 1: 1: nUserState * nBatteryState
            if observe == observation
                fprintf( inputFile, 'O : %d : %d : %d %f\n', action - 1, end_state - 1, observation - 1, 1 );
                % fprintf( 'O : %d : %d : %d %f\n', action - 1, end_state - 1, observation - 1, 1 );
            else
                fprintf( inputFile, 'O : %d : %d : %d %f\n', action - 1, end_state - 1, observe - 1, 0 );
                % fprintf( 'O : %d : %d : %d %f\n', action - 1, end_state - 1, observe - 1, 0 );
            end
        end
    end
end

% when action = sleep, similarily, we don't care what the observations are,
% as sleeping leads into the absorbing state "nState + 1"
for end_state = 1: 1: nState + 1
    for observe = 1: 1: nUserState * nBaseStation
        if observe == 1
            fprintf( inputFile, 'O : %d : %d : %d %f\n', 2 * nBaseStation + 1 - 1, end_state - 1, observe - 1, 1 );
        else
            fprintf( inputFile, 'O : %d : %d : %d %f\n', 2 * nBaseStation + 1 - 1, end_state - 1, observe - 1, 0 );
        end
    end
end

fprintf(inputFile, '\n');

% reward definition
% format R : <action> : <start-state> : <end-state> : <observation> %f

% action = sense
for action = 1: 1: nBaseStation
    fprintf( inputFile,'R : %d : * : * : * %f\n', action - 1, senseCost );
end
% action = sleep
fprintf( inputFile,'R : %d : * : * : * %f\n', 2 * nBaseStation + 1 - 1, 0 );

% action = access
for action = nBaseStation + 1: 2 * nBaseStation
    
    for end_state = 1: 1: nState % this happens when the access is a failure
        fprintf( inputFile,'R : %d : * : %d : * %f\n', action - 1, end_state - 1, accessFail );
    end
    
    end_state = nState + 1; % success! It is a conditional probability dis-
    % tribution
    fprintf( inputFile,'R : %d : %d : %d : * %f\n', action - 1, nState + 1 - 1, end_state - 1, 0 );
    
    for start_state = 1: 1: nState
        
        Reward = 0; % initializting the reward as 0
        
        % from the same start_state, there are different situations where
        % the access is a success, the reward is a mix reward of pure
        % situation.
        
        for count = 1: 1: nBaseStation % distract the index of each states of BS
            temp = floor( (start_state - 1) / (nUserState * nBatteryState) ^(nBaseStation - count) );
            temp = mod( temp, (nUserState * nBatteryState) );
            start_BatteryState(count) = mod( temp, nBatteryState );
            start_UserState(count) = (temp - start_BatteryState(count)) / nBatteryState + 1;
            start_BatteryState(count) = start_BatteryState(count) + 1;
        end
        
        % note that the reward is only related to the BS that we accessd
        User = start_UserState(action - nBaseStation);
        Battery = start_BatteryState(action - nBaseStation);
        % --------------------------------------------------------------- %
        % calculate the reward
        % calculate the prob sum, in order to get the conditional probs
        probabilitySum = 0;
        
        for end_UserState = 1: 1: nUserState
            for end_BatteryState = 1: 1: nBatteryState
                if end_UserState ~= nUserState && end_BatteryState ~= 1
                    % the access is a success when using the trans Matrix
                    % we simply add it up to the reward and add up the
                    % conditional probability Sum
                    Reward = transitionMatrix(start_UserState(action - nBaseStation), start_BatteryState(action - nBaseStation),...
                        end_UserState, end_BatteryState, action - nBaseStation) * ...
                        accessGain(end_UserState, end_BatteryState, action - nBaseStation);
                    probabilitySum = probabilitySum + transitionMatrix(start_UserState(action - nBaseStation), start_BatteryState(action - nBaseStation),...
                        end_UserState, end_BatteryState, action - nBaseStation);
                end
            end
        end
        probabilitySum;
        % it is a conditional distribution!
        Reward = Reward / probabilitySum;
        
        fprintf( inputFile,'R : %d : %d : %d : * %f\n', action - 1, start_state - 1, end_state - 1, Reward * discount );
    end
end

returnFlag = 1; % the writing of files succeeds

fclose(inputFile);