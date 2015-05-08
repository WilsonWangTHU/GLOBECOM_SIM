load('fig10.mat')
WIDTH = 2;
nRunning = 10000;
leaveRate = [0.125 * [1:16]];
myopicReward = sort(myopicReward)
WIDTH = 2;
box on;
hold on;
grid on;

xlabel('The solar intensity normalized by reference intensity')
ylabel('The utility ratio')

axis([0.125, 1.75, 0, 0.8])
set(gca,'xtick',[0:0.125:2],'ytick',[-0:0.1:0.8])

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
legend('EB Method','Random','CSMA/DA', 'CSMA/CA',30)
