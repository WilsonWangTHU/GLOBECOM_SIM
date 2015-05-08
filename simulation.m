function [proposedReward, proposedColiisionRate, proposedEnergyHarvest, ...
energyReward, energyColiisionRate, energyEnergyHarvest, ...
randomReward, randomColiisionRate, randomEnergyHarvest,...
myopicReward, myopicColiisionRate, myopicEnergyHarvest, ...
CSMAoverallreward, CSMAcollisionDropRate, CSMAenergyHarvested] = ... 
simulation( nBaseStation, nBatteryState, ...
    nUserState, vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, Voc, ...
    n, collisionConstraints )

% it is the transition Matrix, both the user and the actual world know it
% and use it. the P_Sample is the maximum definite power
[trMtrSen, trMtrAcs, powerMax, probQ] = transMatrixGet( ...
    nBaseStation, nBatteryState, nUserState, arrivalRate, ...
    leaveRate, powerStrategy, sunlightCoeff, ...
    Jsc, Voc, n, relativeEUnit );

% the user uses the stationary Probability
u_stationaryBelief = zeros(nUserState, nBatteryState, nBaseStation);
u_stationaryBelief(2, 2, :) = 1;

% it is the actual state, it is continuous battery state and discrete user
% state. Only the world knows it.
userState = ones( nBaseStation, 1 );
batteryState = ones( nBaseStation, 1 ) + 0.5;

% expected harvested energy of each battery state
expectedEnergy = zeros( 1, nBatteryState );
expectedEnergy(:) = [0: 1: nBatteryState - 1] * probQ;
probQ

% the energy-based algorithm
energyReward = 0, energyColiisionRate= 0 , energyEnergyHarvest =0, nAccess = 0
% the myopic algorithm
[myopicReward, myopicColiisionRate, myopicEnergyHarvest, nAccess] = myopicSimulation( ...
    trMtrSen, trMtrAcs, nBaseStation, nBatteryState, nUserState, ...
    vectorFileName, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, ...
    Voc, n, collisionConstraints, u_stationaryBelief, ...
    userState, batteryState, powerMax )

% the proposed algorithm
proposedReward = 0, proposedColiisionRate = 0, proposedEnergyHarvest = 0, nAccess = 0;

% the random algorithm
randomReward = 0, randomColiisionRate = 0, randomEnergyHarvest = 0, nAccess = 0

% sensed myopic one
CSMAoverallreward = 0, CSMAcollisionDropRate = 0, CSMAenergyHarvested = 0, nAccess = 0


proposedReward, proposedColiisionRate, proposedEnergyHarvest
energyReward, energyColiisionRate, energyEnergyHarvest
randomReward, randomColiisionRate, randomEnergyHarvest
myopicReward, myopicColiisionRate, myopicEnergyHarvest

pause(1)



% % the proposed-withFeedback algorithm
% [withFeedReward, withFeedColiisionRate, withFeedEnergyHarvest] = withFeedSimulation( trMtrSen, trMtrAcs, ...
% 	nBaseStation, nBatteryState, nUserState, vectorFileName, arrivalRate, ...
% 	leaveRate, sunlightCoeff, relativeEUnit, powerStrategy, discount, nRunning, Jsc, Voc, ...
%     n, forcedDropConstraints, u_stationaryBelief, userState, batteryState )
