subplot(2,1,1)

nRunning = 10000;
arrivalRate = [0.025 * [1:16]];
load('fig1.mat')
figure(1);
% 'proposedReward', 'proposedEnergyHarvest',...
%     'energyReward', 'energyEnergyHarvest',...
%     'randomReward', 'randomEnergyHarvest',...
%     'myopicReward', 'myopicEnergyHarvest',...
%     'CSMAoverallreward', 'CSMAenergyHarvested')
WIDTH = 2;

r = 209/255;
g = 73/255;
b = 78/255;
plot(arrivalRate, proposedReward ./ nRunning, '^-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


xlabel('The arrival rate of the SUs in the BS, \(N_A = 2\)')
ylabel('The utility ratio')
box on;
hold on;
grid on;


r = 248/255;
g = 147/255;
b = 29/255;
plot(arrivalRate, energyReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 107/255;
g = 194/255;
b = 53/255;
plot(arrivalRate, randomReward ./ nRunning, '*-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',10);


r = 0/255;
g = 90/255;
b = 171/255;
plot(arrivalRate, myopicReward ./ nRunning, 'x-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',10);


r = 114/255;
g = 83/255;
b = 52/255;
plot(arrivalRate, CSMAoverallreward ./ nRunning, 'v-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


set(gca,'GridLineStyle','--')
legend('POMDP','EB Method','Random','CSMA/CD','CSMA/CA',30)
