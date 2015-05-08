clear, clc
subplot(2,1,1)
nRunning = 10000;
load('fig4.mat')
leaveRate = [0.125 * [1:16]];
WIDTH = 2;

r = 209/255;
g = 73/255;
b = 78/255;
plot(leaveRate, proposedReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

box on;
hold on;
grid on;


axis([0.125, 1.75, 0, 0.4])
set(gca,'xtick',[0.125:0.125:1.75],'ytick',[-0:0.05:0.4])

xlabel('(b) The solar intensity normalized by reference intensity')
ylabel('The utility ratio')
r = 248/255;
g = 147/255;
b = 29/255;
plot(leaveRate, energyReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 107/255;
g = 194/255;
b = 53/255;
plot(leaveRate, randomReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 114/255;
g = 83/255;
b = 52/255;
plot(leaveRate, CSMAoverallreward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


set(gca,'GridLineStyle','--')
legend('Proposed POMDP','EB Method','Random','CSMA/CA',30)
