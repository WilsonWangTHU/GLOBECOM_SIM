clc, clear;
nBaseStation = 1;
nBatteryState = 8;
nUserState = 4;
nIArrival = 16;

nRunning = 10000;
proposedReward = zeros(nIArrival, 1);
energyReward = zeros(nIArrival, 1);
randomReward = zeros(nIArrival, 1);
myopicReward = zeros(nIArrival, 1);

CSMAoverallreward = zeros(nIArrival, 1);

relativeEUnit = 1;
powerStrategy = 1;

discount = 0.9;
Jsc = 13.364; % the statistic in our model
Voc = 0.7631; %
n = 2;
collisionConstraints = 1;

for iArrival = 5: 1: 5
    
arrivalRate = [0.4];
leaveRate = [0.1];

sunlightCoeff = [0.125 * iArrival, 0.125/2 * iArrival ];


filename = [num2str(iArrival) 'fig5lightRateResult.alpha'];

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

load chirp
sound(y,Fs)


arrivalRate = [0.125 * [1:16]];
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