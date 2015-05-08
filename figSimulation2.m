clc, clear;
nBaseStation = 2;
nBatteryState = 3;
nUserState = 2;
nIArrival = 16;

nRunning = 10000;
proposedReward = zeros(nIArrival, 1);
energyReward = zeros(nIArrival, 1);
randomReward = zeros(nIArrival, 1);
myopicReward = zeros(nIArrival, 1);
CSMAoverallreward = zeros(nIArrival, 1);
sunlightCoeff = [1, 0.5];

relativeEUnit = 1;
powerStrategy = 1;

discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;
collisionConstraints = 1;

for iArrival = 1: 1: nIArrival
    
arrivalRate = [0.025 * iArrival + 0.2, 0.025 * iArrival + 0.2];
leaveRate = [0.1, 0.1];


filename = [num2str(iArrival) 'fig2arrivalRateResult.alpha'];

[proposedReward(iArrival), proposedColiisionRate(iArrival), proposedEnergyHarvest(iArrival), ...
    energyReward(iArrival), energyColiisionRate(iArrival), energyEnergyHarvest(iArrival), ...
    randomReward(iArrival), randomColiisionRate(iArrival), randomEnergyHarvest(iArrival),...
    myopicReward(iArrival), myopicColiisionRate(iArrival), myopicEnergyHarvest(iArrival),...
    CSMAoverallreward(iArrival), CSMAcollisionDropRate(iArrival), CSMAenergyHarvested(iArrival)] = ...
    simulation( nBaseStation, nBatteryState, ...
    nUserState, filename, arrivalRate, leaveRate, sunlightCoeff, ...
    relativeEUnit, powerStrategy, discount, nRunning, Jsc, Voc, ...
    n, collisionConstraints )

end
arrivalRate = [0.025 * [1:16] + 0.2];
save('fig2.mat','proposedReward', 'proposedEnergyHarvest',...
    'energyReward', 'energyEnergyHarvest',...
    'randomReward', 'randomEnergyHarvest',...
    'myopicReward', 'myopicEnergyHarvest',...
    'CSMAoverallreward', 'CSMAenergyHarvested')
WIDTH = 2;

r = 112/255;
g = 160/255;
b = 37/255;
plot(arrivalRate, proposedReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);
box on;
hold on;
grid on;


r = 83/255;
g = 23/255;
b = 71/255;
plot(arrivalRate, energyReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 23/255;
g = 53/255;
b = 201/255;
plot(arrivalRate, randomReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


r = 237/255;
g = 125/255;
b = 49/255;
plot(arrivalRate, myopicReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


r = 20/255;
g = 125/255;
b = 237/255;
plot(arrivalRate, CSMAoverallreward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


set(gca,'GridLineStyle','--')
legend('proposed','energy','random','myopic','CSMA',30)
