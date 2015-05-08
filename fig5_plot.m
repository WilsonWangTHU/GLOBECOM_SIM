clear, clc
subplot(2,1,2)
nRunning = 10000;
load('fig5.mat')
arrivalRate = [0.125 * [1:16]];
WIDTH = 2;
% 1205
figure(1)

r = 209/255;
g = 73/255;
b = 78/255;
arrivalRate = [arrivalRate(1:4), arrivalRate(6:end)]
proposedReward = [proposedReward(1:4); proposedReward(6:end)]
energyReward = [energyReward(1:4); energyReward(6:end)]
randomReward = [randomReward(1:4); randomReward(6:end)]
myopicReward = [myopicReward(1:4); myopicReward(6:end)]
CSMAoverallreward = [CSMAoverallreward(1:4); CSMAoverallreward(6:end)]

plot(arrivalRate, proposedReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

axis([0.125, 2, 0, 0.55])
set(gca,'xtick',[0.125:0.125:2.5],'ytick',[-0:0.05:0.7])
box on;
hold on;
grid on;


xlabel('(a) The solar intensity normalized by reference intensity')
ylabel('The utility ratio')
r = 248/255;
g = 147/255;
b = 29/255;
plot(arrivalRate, energyReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 107/255;
g = 194/255;
b = 53/255;
plot(arrivalRate, randomReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

% 
% r = 0/255;
% g = 90/255;
% b = 171/255;
% plot(arrivalRate, myopicReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


r = 114/255;
g = 83/255;
b = 52/255;
plot(arrivalRate, CSMAoverallreward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


set(gca,'GridLineStyle','--')
legend('Proposed POMDP','EB Method','Random','CSMA/CA',30)
