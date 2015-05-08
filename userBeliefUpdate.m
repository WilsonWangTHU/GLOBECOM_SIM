function nu_Belief = userBeliefUpdate(trMtrAcs, trMtrSen, accessStation, ...
    u_Belief, nUserState, nBatteryState, nBaseStation)

nu_Belief = zeros(nUserState, nBatteryState, nBaseStation);


for station = 1: 1: nBaseStation
    if accessStation == station % the accessing transition
        
        for start_user = 1: 1: nUserState
            for start_battery = 1: 1: nBatteryState
                nu_Belief(:, :, station) = nu_Belief(:, :, station) + ...
                    squeeze( trMtrAcs(start_user, start_battery, :, :, station) ) * ...
                    u_Belief(start_user, start_battery, station);
            end
        end
    else
        for start_user = 1: 1: nUserState
            for start_battery = 1: 1: nBatteryState
                
                nu_Belief(:, :, station) = nu_Belief(:, :, station) + ...
                    squeeze( trMtrSen(start_user, start_battery, :, :, station) ) * ...
                    u_Belief(start_user, start_battery, station);
                
            end
        end
        
    end
    
    % in case numerical error happens
    nu_Belief(:, :, station) = nu_Belief(:, :, station) / ...
        sum(sum(nu_Belief(:, :, station)));
end
