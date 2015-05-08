function nu_Belief = userBeliefUpdate(transitionMatrix,...
    u_Belief, nUserState, nBatteryState, nBaseStation)

nu_Belief = zeros(nUserState, nBatteryState, nBaseStation);

for station = 1: 1: nBaseStation
    
    for start_user = 1: 1: nUserState
        for start_battery = 1: 1: nBatteryState
            
            % renew the user probs
            tempMatrix = zeros(nUserState, nBatteryState);
            tempMatrix(:,:) = transitionMatrix(start_user,...
                start_battery, :, :, station);
            tempU_belief = zeros(nUserState, nBatteryState);
            tempU_belief(:,:) = u_Belief(start_user, start_battery, station);
            
            nu_Belief(:, :, station) = nu_Belief(:, :, station) + ...
                tempMatrix .* tempU_belief;
            
        end
    end
    
    % in case numerical error happens
    nu_Belief(:, :, station) = nu_Belief(:, :, station) / ...
        sum(sum(nu_Belief(:, :, station)));
end