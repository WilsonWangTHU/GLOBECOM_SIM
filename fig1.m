
clc, clear;
% consider different arrive rate

nBaseStation = 1;
nBatteryState = 8;
nUserState = 4;
 
for iArrival = 1: 1: 16
    
arrivalRate = [0.025 * iArrival];
leaveRate = [0.05];
sunlightCoeff = [1, 0.5];


relativeEUnit = 1;
powerStrategy = 1;

discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;
collisionConstraints = 1;

filename = [num2str(iArrival) 'fig1arrivalRate.POMDP'];
    
returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
    filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
    Jsc, Voc, n, relativeEUnit, collisionConstraints );

end

% a possible table, good reward feedback
% 
% clc, clear;
% % consider different arrive rate
% 
% nBaseStation = 1;
% nBatteryState = 8;
% nUserState = 4;
%  
% for iArrival = 1: 1: 8
%     
% arrivalRate = [0.05 * iArrival];
% leaveRate = [0.05];
% sunlightCoeff = [1, 0.5];
% 
% 
% relativeEUnit = 1;
% powerStrategy = 1;
% 
% discount = 0.9;
% Jsc = 13.364; % the statistic in our model
% Voc = 0.7631; %
% n = 2;
% collisionConstraints = 1;
% 
% filename = [num2str(iArrival) 'arrivalRate.POMDP'];
%     
% returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
%     filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
%     Jsc, Voc, n, relativeEUnit, collisionConstraints );
% 
% end


% good collision feedback
% for iArrival = 1: 1: 8
%     
% arrivalRate = [0.05 * iArrival];
% leaveRate = [0.05];
% sunlightCoeff = [2, 1];
% 
% 
% relativeEUnit = 1;
% powerStrategy = 1;
% 
% discount = 0.9;
% Jsc = 13.364; % the statistic in our model
% Voc = 0.7631; %
% n = 2;
% collisionConstraints = 0.01;
% 
% filename = [num2str(iArrival) 'arrivalRate.POMDP'];
%     
% returnFlag = pomdpFileGet( nBaseStation, nBatteryState, nUserState, ...
%     filename, arrivalRate, leaveRate, sunlightCoeff, powerStrategy, discount, ...
%     Jsc, Voc, n, relativeEUnit, collisionConstraints );
% 
% end