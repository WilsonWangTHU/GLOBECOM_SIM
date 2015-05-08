function [trMtrSen, trMtrAcs, powerMax, probQ] = transMatrixGet( ...
    nBaseStation, nBatteryState, nUserState, arrivalRate, leaveRate, ...
    powerStrategy, sunlightCoeff, Jsc, Voc, n, relativeEUnit)

% the probs of transition
trMtrSen = zeros(nUserState, nBatteryState, nUserState, nBatteryState, ...
    nBaseStation);
trMtrAcs = zeros(nUserState, nBatteryState, nUserState, nBatteryState, ...
    nBaseStation);

nKT_q = 0.0259 * n;  % VOLT
V = [0: 0.001: Voc];
P = (Jsc - Jsc * (exp(V / nKT_q) - 1) / (exp(Voc / nKT_q) - 1)) .* V;

% normalization the power so that the max harvesting is the average sunlight
% level of the sunlightCoeff
pathLength = length(P) / (nBatteryState);
powerMax= max(P);
P = P / max(P);

powerSample = P(round(0.5 * pathLength + ((1 : nBatteryState) - 1) * ...
    pathLength));
powerSample(:) = 1;

% calculate the probs of Q, given the battery state and the sunlight level
% which is a quasi - static process

% note the difference of Q and Q + 1 in the probQ, as in matlab, the index
% starts from 1
probQ = zeros(nBatteryState, nBatteryState);
for batteryState = 1: 1: nBatteryState
    for Q = 0: 1: nBatteryState - batteryState
        if Q == 0
            probQ(Q + 1, batteryState) = quad( @(x)probIntegral1( x, ...
                sunlightCoeff(1), sunlightCoeff(2), relativeEUnit, 0, ...
                powerSample(batteryState)), 0, relativeEUnit );
        else
            probQ(Q + 1, batteryState) = ...
                quad( @(x)probIntegral1( x, sunlightCoeff(1), ...
                sunlightCoeff(2), relativeEUnit, Q, ...
                powerSample(batteryState)), Q * relativeEUnit, ...
                (Q + 1) * relativeEUnit ) + ...
                quad( @(x)probIntegral2( x, sunlightCoeff(1), ...
                sunlightCoeff(2), relativeEUnit, Q - 1, ...
                powerSample(batteryState)), (Q - 1) * relativeEUnit, ...
                Q * relativeEUnit );
        end
    end
    probQ(:, batteryState) = ...
        probQ(:, batteryState) / sum( probQ(:, batteryState));
end

% if the user is not accessing, simply sensing (or no movement)
for iStation = 1: 1: nBaseStation % the starting station
    for start_batteryState = 1: 1: nBatteryState
        for start_UserState = 1: 1: nUserState
            for end_batteryState = 1: 1: nBatteryState
                for end_UserState = 1: 1: nUserState
                    
                    % the battery change is deltaBattery change
                    if start_UserState == 1 || start_batteryState == 1
                        % no energy consumption
                        Q = end_batteryState - start_batteryState;
                    else
                        if start_UserState - 1 > start_batteryState - 1
                            % when more battery was needed, all battery is used
                            % up, and the harvested was from the battery state
                            % 1
                            Q = end_batteryState - 1;
                        else
                            % Q is the actual  harvesting energy quantity, ...
                            % transmission only when there is user and battery at
                            % the same time
                            deltaBattery = end_batteryState - ...
                                start_batteryState;
                            Q = deltaBattery + powerStrategy * ...
                                (start_UserState - 1);
                            % Q = deltaBattery + powerStrategy * ...
                            % (start_UserState - 1);
                        end
                    end
                    
                    % the battery transition
                    if Q >= nBatteryState    % impossible to harvest Q > nbattery
                        trMtrSen(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, iStation) = 0;
                    else
                        if Q >= 0
                            if end_batteryState < nBatteryState
                                trMtrSen(start_UserState, ...
                                    start_batteryState, end_UserState, ...
                                    end_batteryState, iStation) = ...
                                    probQ( Q + 1, start_batteryState);
                            else
                                trMtrSen(start_UserState, ...
                                    start_batteryState, end_UserState, ...
                                    end_batteryState, iStation) = ...
                                    sum( probQ(Q + 1 : end, ...
                                    start_batteryState) );
                            end
                        else
                            trMtrSen(start_UserState, start_batteryState, ...
                                end_UserState, end_batteryState, iStation) = 0;
                        end
                    end
                    
                    % the user transition
                    
                    % situation where no user drops
                    if end_UserState == start_UserState + 1
                        trMtrSen(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, iStation) = ...
                            arrivalRate(iStation) * trMtrSen( ...
                            start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, iStation);
                    else
                        if end_UserState == start_UserState - 1
                            trMtrSen(start_UserState, start_batteryState, ...
                                end_UserState, end_batteryState, iStation) ...
                                = (start_UserState - 1) * leaveRate(iStation)...
                                * trMtrSen(start_UserState, ...
                                start_batteryState, end_UserState, ...
                                end_batteryState, iStation);
                        else
                            if end_UserState == start_UserState
                                userProb = 1 - arrivalRate(iStation) * (end_UserState ~= nUserState) - leaveRate(iStation) * (end_UserState - 1);
                                trMtrSen(start_UserState, start_batteryState, end_UserState, end_batteryState, iStation) = userProb * ...
                                    trMtrSen(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, iStation);
                            else
                                trMtrSen(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, iStation) = 0;
                            end
                        end
                    end
                    
                end
            end
        end
    end
end

% if the user is accessing, note that the decision maker could still access
% the base station and use energy even if the number of user is full, as
% long as the battery is enough... but it is not a successful attemp.
for iStation = 1: 1: nBaseStation % the starting station
    for start_batteryState = 1: 1: nBatteryState
        for start_UserState = 1: 1: nUserState
            for end_batteryState = 1: 1: nBatteryState
                for end_UserState = 1: 1: nUserState
                    
                    % considers the situation where the SU could not access 
                    % the basestation
                    if start_batteryState == 1 ...
                            || start_UserState >= start_batteryState ...
                            || start_batteryState == 2 && start_UserState == 0
% --------------------------------------------------------------------------------- %
                        % the access is a failure, the same as the original 
                        % one
                        trMtrAcs(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, iStation) = ...
                            trMtrSen(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, iStation);
                    else
                        % the decision maker could access the base station
                        % Q is the actual  harvesting energy quantity, ...
                        % transmission only when there is user and battery at
                        % the same time
                        deltaBattery = end_batteryState - start_batteryState;
                        Q = deltaBattery + powerStrategy * ...
                            (start_UserState - 1 + 1);
             
                        if Q >= nBatteryState % impossible to harvest Q > nbattery
                            trMtrAcs(start_UserState, start_batteryState, end_UserState, ...
                                end_batteryState, iStation) = 0;
                        else
                            if Q >= 0
                                if end_batteryState < nBatteryState
                                    trMtrAcs(start_UserState, start_batteryState, ...
                                        end_UserState, end_batteryState, iStation) = ...
                                        probQ(Q + 1, start_batteryState);
                                else
                                    trMtrAcs(start_UserState, start_batteryState, ...
                                        end_UserState, end_batteryState, iStation) = ...
                                        sum(probQ(Q + 1 : end, start_batteryState));
                                end
                            else
                                trMtrAcs(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, iStation) = 0;
                            end
                        end
                        
                        % situation where no user drops
                        if end_UserState == start_UserState + 1
                            trMtrAcs(start_UserState, start_batteryState, ...
                                end_UserState,  end_batteryState, iStation) = arrivalRate(iStation) * ...
                                trMtrAcs(start_UserState, start_batteryState, end_UserState, ...
                                end_batteryState, iStation);
                        else
                            if end_UserState == start_UserState - 1
                                trMtrAcs(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, iStation) = (start_UserState - 1) *...
                                    leaveRate(iStation) * trMtrAcs(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, iStation);
                            else
                                if end_UserState == start_UserState
                                    userProb = 1 - arrivalRate(iStation) * (end_UserState ~= nUserState) - leaveRate(iStation) * (end_UserState - 1);
                                    trMtrAcs(start_UserState, start_batteryState, end_UserState, end_batteryState,...
                                        iStation) = userProb * trMtrAcs(start_UserState, start_batteryState, ...
                                        end_UserState, end_batteryState, iStation);
                                else
                                    trMtrAcs(start_UserState, start_batteryState, ...
                                        end_UserState, end_batteryState, iStation) = 0;
                                end
                            end
                        end
                        
                        
                    end
                    
                end
                
                
            end
        end
    end
end

% note that when end_B = 1, the transition goes to b =
% 1, u = 1, no matter what the original u is
for iStation = 1: 1: nBaseStation % the starting station
    for start_batteryState = 1: 1: nBatteryState
        for start_UserState = 1: 1: nUserState
            
            trMtrSen(start_UserState, start_batteryState, 1,  1, iStation) = ...
                sum(trMtrSen(start_UserState, start_batteryState, 1 : end, ...
                1, iStation));
            trMtrSen(start_UserState, start_batteryState, 2 : end, 1, ...
                iStation) = trMtrSen(start_UserState, start_batteryState, ...
                2 : end, 1, iStation) .* 0;
            
            trMtrAcs(start_UserState, start_batteryState, 1,  1, iStation) = ...
                sum(trMtrAcs(start_UserState, start_batteryState, 1 : end, ...
                1, iStation));
            trMtrAcs(start_UserState, start_batteryState, 2 : end, 1, ...
                iStation) = trMtrAcs(start_UserState, start_batteryState, ...
                2 : end, 1, iStation) .* 0;
        end
    end
end
checkSum = transMatrixTest(nUserState, nBatteryState, ...
    nBaseStation, trMtrSen, trMtrAcs);
end
