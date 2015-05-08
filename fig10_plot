load('fig3.mat')
WIDTH = 2;
nRunning = 10000;
leaveRate = [0.01 * [1:16] + 0.09];

WIDTH = 2;
r = 209/255;
g = 73/255;
b = 78/255;
plot(leaveRate, proposedReward ./ nRunning, '^-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

box on;
hold on;
grid on;

xlabel('The death rate \mu of the SUs')
ylabel('The utility rate')

r = 248/255;
g = 147/255;
b = 29/255;
plot(leaveRate, energyReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);

r = 107/255;
g = 194/255;
b = 53/255;
plot(leaveRate, randomReward ./ nRunning, '*-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


r = 0/255;
g = 90/255;
b = 171/255;
 plot(leaveRate, myopicReward ./ nRunning, 's-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


r = 114/255;
g = 83/255;
b = 52/255;
plot(leaveRate, CSMAoverallreward ./ nRunning, 'v-','LineWidth',WIDTH,'Color',[r g b],'MarkerSize',7);


set(gca,'GridLineStyle','--')
legend('POMDP','EB Method','Random','CSMA/CA',30)
