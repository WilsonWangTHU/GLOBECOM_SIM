function [newUserState, newBatteryState, drop] = renewWorldState(...
    transitionMatrix, userState, batteryState, UserIn, sunlightCoeff, ...
    nUserState, nBatteryState, powerStrategy, arrivalRate, leaveRate)

% initializing output variable
drop = 0;


% the system parameters
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
q = 1.602176565e-19;
c = 1;
n = 2;
nKT_q = 0.0259 * n;  % VOLT

V = [0: 0.001: 0.7631];
v = batteryState / nBatteryState * Voc;

P = (Jsc - Jsc * (exp(v / nKT_q) - 1) / (exp(Voc / nKT_q) - 1)) .* v;

ChargeBattery = P * normrnd( sunlightCoeff(1), sunlightCoeff(2) );
if ChargeBattery < 0
    ChargeBattery = 0;
end

newBatteryState = ChargeBattery + batteryState - powerStrategy * ...
    (batteryState > 1 && userState > 1);

if newBatteryState >= nBatteryState
    newBatteryState = nBatteryState;
end

if newBatteryState <= 1 && UserIn == 1
    % the battery is too low! the BS shut down
    drop = 1;
end

if UserIn == 1 % means the user is in the system already
    % first we take out the decision maker (imaginarily)
    userState = userState - 1;
    
    % the user is in the system, we take him out first for calculation
    oneMore = 0;
    oneLess = 0;
    
    switch userState
        case 1
            oneMore = (1 - (userState - 1) * leaveRate) * arrivalRate;
        case nUserState
            oneLess = (userState - 1) * leaveRate * (1 - arrivalRate);
        otherwise
            oneLess = (userState - 1) * leaveRate * (1 - arrivalRate);
            oneMore = (1 - (userState - 1) * leaveRate) * arrivalRate;
    end
    
    % generate the userChange
    seed = rand(1);
    userChange = (seed < oneMore) * 1 + ...
        (seed > oneMore && seed < oneMore + oneLess) * (-1) + ...
        (seed > oneMore + oneLess) * 0;
    
    newUserState = userState + userChange;
    if newUserState == nUserState
        % now the user is droped!
        drop = 1;
    else
        % the user is not dropped
        drop = 0;
        newUserState = newUserState + 1;
    end
else
    % the user is not in the system
    % PoneUserMore = (1 - (UserIn - 1) * leaveRate) * arrivalRate;
    
    oneMore = 0;
    oneLess = 0;
    
    switch userState
        case 1
            oneMore = (1 - (userState - 1) * leaveRate) * arrivalRate;
        case nUserState
            oneLess = (userState - 1) * leaveRate * (1 - arrivalRate);
        otherwise
            oneLess = (userState - 1) * leaveRate * (1 - arrivalRate);
            oneMore = (1 - (userState - 1) * leaveRate) * arrivalRate;
    end
    
    % generate the userChange
    seed = rand(1);
    userChange = (seed < oneMore) * 1 + ...
        (seed > oneMore && seed < oneMore + oneLess) * (-1) + ...
        (seed > oneMore + oneLess) * 0;
    
    newUserState = userState + userChange;
end
