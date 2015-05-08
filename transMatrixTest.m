function checkSum = transMatrixTest(nUserState, nBatteryState, ...
    nBaseStation, trMtrSen, trMtrAcs)

checkSum = 1;
for iB = 1: 1: nBatteryState
    for iU = 1: 1: nUserState
        % check the transition matrix for sum == 1
        for iS = 1: 1: nBaseStation
           
            % check the transition matrix for sum == 1
            vec = trMtrSen(iU, iB, :, :, iS);
            sumResult = sum(vec(:));
            
            if abs(sumResult - 1) > 1e-6
                checkSum = 0;
                fprintf('the sum is wrong (%f) for iB = %d, iU = %d\n', ...
                    sumResult, iB, iU);
            end
            
            vec = trMtrAcs(iU, iB, :, :, iS);
            sumResult = sum(vec(:));
            
            if abs(sumResult - 1) > 1e-6
                checkSum = 0;
                fprintf('the sum is wrong (%f) for iB = %d, iU = %d\n', ...
                    sumResult, iB, iU);
            end
            
            
            
            % check the transition matrix that no state goes to states that
            % do not exist 
            if any(trMtrSen(iU, iB, 2 : end, 1, iS)) || ...
                    any(trMtrAcs(iU, iB, 2 : end, 1, iS))
                checkSum = 0;
                fprintf('state %d, %d goes to states that do not exist \n', ...
                    iB, iU);
            end
            if any(any((trMtrAcs(iU, iB, :, :, iS) < 0))) || ...
                    any(any((trMtrSen(iU, iB, :, :, iS) < 0)))
                checkSum = 0;
                fprintf('negative probability\n')
            end
            
        end
    end
end

if checkSum == 1
    fprintf('The transition matrix for all the base station is safe\n');
end