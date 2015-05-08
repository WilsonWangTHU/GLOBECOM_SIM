function R = MDPvalueGenerator(nBatteryState, nUserState, arrivalRate, leaveRate,...
    powerStrategy, sunlightCoeff, E_Unit, discount)
% nBatteryState = 3;
% nUserState = 3;
% arrivalRate = 0.1;
% leaveRate = 0.1;
% powerStrategy = 1;
% sunlightCoeff = [1, 0.7];
% E_Unit = 1;
% discount = 0.9;
%  P(SxSxA) = transition matrix
%                P could be an array with 3 dimensions or
%                a cell array (1xA), each cell containing a matrix (SxS) possibly sparse
%     R(SxSxA) or (SxA) = reward matrix
%                R could be an array with 3 dimensions (SxSxA) or
%                a cell array (1xA), each cell containing a sparse matrix (SxS) or
%                a 2D array(SxA) possibly sparse
%     discount = discount rate, in ]0, 1[
%     policy0(S) = starting policy, optional
%     max_iter = maximum number of iteration to be done, upper than 0,
%                optional (default 1000)
%     eval_type = type of function used to evaluate policy:
%                0 for mdp_eval_policy_matrix, else mdp_eval_policy_iterative
%                optional (default 0)

% the user is always in the system, so there is a difference

% User = UserMax is not going to happen!

Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
q = 1.602176565e-19;
c = 1;
n = 2;
nKT_q = 0.0259 * n;  % VOLT

V = [0: 0.001: 0.7631];

J = Jsc - Jsc * (exp(V / nKT_q) - 1) / (exp(Voc / nKT_q) - 1);
P = (Jsc - Jsc * (exp(V / nKT_q) - 1) / (exp(Voc / nKT_q) - 1)) .* V;

% normalization the power so that the max harvesting is the
% average sunlight level of the sunlightCoeff
pathLength = length(P) / (nBatteryState);
P = P / max(P);

% plot(J, P);
P_Sample = P(round(0.5 * pathLength + ((1 : nBatteryState) - 1) * pathLength));

% calculate the probs of Q, given the battery state and the sunlight level
% which is a quasi - static processa

% note that Q = Q + 1 in the probQ
probQ = zeros(nBatteryState + 1 + powerStrategy, nBatteryState);
for batteryState = 1: 1: nBatteryState
    for Q = 0: 1: nBatteryState + powerStrategy
        if Q == 0
            probQ(Q + 1, batteryState) = quad( @(x)probIntegral1(x, sunlightCoeff(1),...
                sunlightCoeff(2), E_Unit, 0, P_Sample(batteryState)), 0, E_Unit );
        else
            probQ(Q + 1, batteryState) = quad( @(x)probIntegral1(x, sunlightCoeff(1),...
                sunlightCoeff(2), E_Unit, Q, P_Sample(batteryState)), Q * E_Unit, (Q + 1) * E_Unit ) + ...
                quad( @(x)probIntegral2(x, sunlightCoeff(1),...
                sunlightCoeff(2), E_Unit, Q - 1, P_Sample(batteryState)), (Q - 1) * E_Unit, Q * E_Unit );
        end
    end
    probQ(nBatteryState + 1 + powerStrategy, batteryState) = probQ(nBatteryState + 1 + powerStrategy, batteryState) + 1 - sum(probQ(:, batteryState));
end

% the probs
transitionMatrix = zeros(nBatteryState, nUserState, nBatteryState, nUserState);
for start_batteryState = 1: 1: nBatteryState
    for start_UserState = 1: 1: nUserState
        for end_batteryState = 1: 1: nBatteryState
            for end_UserState = 1: 1: nUserState
                
                % the battery change
                deltaBattery = end_batteryState - start_batteryState;
                Q = deltaBattery + powerStrategy * (start_batteryState > 1);
                
                % the battery transition
                if Q > nBatteryState + powerStrategy % impossible to harvest Q > nbattery
                    transitionMatrix(start_batteryState, start_UserState, ...
                        end_batteryState, end_UserState) = 0;
                else
                    if Q >= 0
                        if end_batteryState < nBatteryState
                            transitionMatrix(start_batteryState, start_UserState, ...
                                end_batteryState, end_UserState) = probQ(Q + 1, start_batteryState);
                        else
                            transitionMatrix(start_batteryState, start_UserState, ...
                                end_batteryState, end_UserState) = sum(probQ(Q + 1 : end, start_batteryState));
                        end
                    else
                        transitionMatrix(start_batteryState, start_UserState, ...
                            end_batteryState, end_UserState) = 0;
                    end
                end
                
                % the user transition
                if end_UserState == start_UserState + 1
                    transitionMatrix(start_batteryState, start_UserState, ...
                        end_batteryState, end_UserState) = arrivalRate * ...
                        (1 - (start_UserState - 1) * leaveRate) * ...
                        transitionMatrix(start_batteryState, start_UserState, ...
                        end_batteryState, end_UserState);
                else
                    if end_UserState == start_UserState - 1
                        transitionMatrix(start_batteryState, start_UserState, ...
                            end_batteryState, end_UserState) = (1 - arrivalRate) * ...
                            (start_UserState - 1) * leaveRate * ...
                            transitionMatrix(start_batteryState, start_UserState, ...
                            end_batteryState, end_UserState);
                    else
                        if end_UserState == start_UserState
                            userProb = 1 - ...
                                (start_UserState > 1) * (1 - arrivalRate) * leaveRate * (start_UserState - 1) - ...
                                (start_UserState < nUserState) * arrivalRate * (1 - leaveRate * (start_UserState - 1));
                            if userProb <= 0
                                userProb
                            end
                            transitionMatrix(start_batteryState, start_UserState, ...
                                end_batteryState, end_UserState) = userProb * ...
                                transitionMatrix(start_batteryState, start_UserState, ...
                                end_batteryState, end_UserState);
                        else
                            transitionMatrix(start_batteryState, start_UserState, ...
                                end_batteryState, end_UserState) = 0;
                        end
                    end
                end
            end
        end
    end
end


P = zeros((nBatteryState - 1) * (nUserState - 1) + 1, (nBatteryState - 1) * (nUserState - 1) + 1);
R = zeros((nBatteryState - 1) * (nUserState - 1) + 1, (nBatteryState - 1) * (nUserState - 1) + 1, 1);
% drop when 1. battery == 0(1), 2

for start_battery = 2: 1: nBatteryState
    for start_user = 1: 1: nUserState - 1
        for end_battery = 2: 1: nBatteryState
            for end_user = 1: 1: nUserState - 1
                startState = (start_battery - 2) * (nUserState - 1) + start_user;
                endState = (end_battery - 2) * (nUserState - 1) + end_user;
                P(startState, endState) = transitionMatrix(start_battery, start_user, end_battery, end_user);
                R(:, endState, :) = log ( 1 + powerStrategy / ((end_user - 1) * E_Unit + 1) );
            end
        end
    end
end

% P(startState, nBatteryState * (nUserState - 1) + 1) forced out of the
% netwrork

for start_battery = 2: 1: nBatteryState
    for start_user = 1: 1: nUserState - 1
        startState = (start_battery - 2) * (nUserState - 1) + start_user;
        
        for end_battery = 1: 1: nBatteryState
            for end_user = 1: 1: nUserState
                if end_battery == 1 || end_user == nUserState
                    P(startState, (nBatteryState - 1) * (nUserState - 1) + 1) = P(startState, (nBatteryState - 1) * (nUserState - 1) + 1) + ...
                        transitionMatrix(start_battery, start_user, end_battery, end_user);
                end
            end
        end
    end
end

P((nBatteryState - 1) * (nUserState - 1) + 1, :) = 0;
P((nBatteryState - 1) * (nUserState - 1) + 1, (nBatteryState - 1) * (nUserState - 1) + 1) = 1;

Pinput = zeros((nBatteryState - 1) * (nUserState - 1) + 1, (nBatteryState - 1) * (nUserState - 1) + 1, 2);
Pinput(:, :, 1) = P;
Pinput(:, :, 2) = P;

Rinput = zeros((nBatteryState - 1) * (nUserState - 1) + 1, (nBatteryState - 1) * (nUserState - 1) + 1, 2);
Rinput(:, :, 1) = R;
Rinput(:, :, 2) = R;

[R, Policy] = mdp_policy_iteration(Pinput,Rinput,discount);