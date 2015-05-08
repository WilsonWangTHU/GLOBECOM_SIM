function [transitionMatrix, Pmax] = transMatrixGenerator(nBaseStation, nBatteryState, nUserState, arrivalRate, leaveRate,...
    powerStrategy, sunlightCoeff, E_Unit)

% example input:	
%	nBaseStation = 2;
% 	nBatteryState = 2;
% 	nUserState = 2;
% 	arrivalRate = [0.1, 0.1];
% 	leaveRate = [0.1, 0.1];
% 	powerStrategy = 1;
% 	sunlightCoeff = [1, 0.7];
% 	E_Unit = 1;

% Output is in the form of transitionMatrix(u, b, u', b')

% E_Unit means how much one unit of energy is, when compared
% with the

% sunlightCoeff means that the average sunlight could provide
% how many unit of E_Unit energy

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
Pmax= max(P);
P = P / max(P);

% plot(J, P);
P_Sample = P(round(0.5 * pathLength + ((1 : nBatteryState) - 1) * pathLength));

% calculate the probs of Q, given the battery state and the sunlight level
% which is a quasi - static processa

% note the difference of  Q and Q + 1 in the probQ, as in matlab, the index starts from 1
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
    probQ(nBatteryState + 1 + powerStrategy, batteryState) = probQ(nBatteryState + 1 + ...
		powerStrategy, batteryState) + 1 - sum(probQ(:, batteryState));
end

% the probs of transition
transitionMatrix = zeros(nUserState, nBatteryState, nUserState, nBatteryState, nBaseStation);
for Station = 1: 1: nBaseStation % the starting station
    for start_batteryState = 1: 1: nBatteryState
        for start_UserState = 1: 1: nUserState
            for end_batteryState = 1: 1: nBatteryState
                for end_UserState = 1: 1: nUserState
                    if start_batteryState == 1 && start_UserState == 2 && end_batteryState == 1 && end_UserState == 1 && Station == 1
						% for debug?
					end

                    % the battery change is deltaBattery change
                    deltaBattery = end_batteryState - start_batteryState;
					% Q is the actual 
                    Q = deltaBattery + powerStrategy * (start_UserState > 1) * (start_batteryState > 1);
                    
                    % the battery transition
                    if Q > nBatteryState + powerStrategy % impossible to harvest Q > nbattery
                        transitionMatrix(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, Station) = 0;
                    else
                        if Q >= 0
                            if end_batteryState < nBatteryState
                                transitionMatrix(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, Station) = probQ(Q + 1, start_batteryState);
                            else
                                transitionMatrix(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, Station) = sum(probQ(Q + 1 : end, start_batteryState));
                            end
                        else                            
                            transitionMatrix(start_UserState, start_batteryState, ...
                                end_UserState, end_batteryState, Station) = 0;
                        end
                    end
                    
                    % the user transition
                    if end_UserState == start_UserState + 1
                        transitionMatrix(start_UserState, start_batteryState, ...
                           end_UserState,  end_batteryState, Station) = arrivalRate(Station) * ...
                            (1 - (start_UserState - 1) * leaveRate(Station)) * ...
                            transitionMatrix(start_UserState, start_batteryState, ...
                            end_UserState, end_batteryState, Station);
                    else
                        if end_UserState == start_UserState - 1
                            transitionMatrix(start_UserState, start_batteryState, ...
                                end_UserState, end_batteryState, Station) = (1 - arrivalRate(Station)) * ...
                                (start_UserState - 1) * leaveRate(Station) * ...
                                transitionMatrix(start_UserState, start_batteryState, ...
                                end_UserState, end_batteryState, Station);
                        else
                            if end_UserState == start_UserState
                                userProb = 1 - ...
                                    (start_UserState > 1) * (1 - arrivalRate(Station)) * leaveRate(Station) * (start_UserState - 1) - ...
                                    (start_UserState < nUserState) * arrivalRate(Station) * (1 - leaveRate(Station) * (start_UserState - 1));
                                if userProb <= 0
                                    userProb
                                end
                                transitionMatrix(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, Station) = userProb * ...
                                    transitionMatrix(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, Station);
                            else
                                transitionMatrix(start_UserState, start_batteryState, ...
                                    end_UserState, end_batteryState, Station) = 0;
                            end
                        end
                    end
                end
            end
        end
    end
end

