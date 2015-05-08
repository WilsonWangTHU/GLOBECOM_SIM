
subplot(2,1,1)
xlabel('The arriving rate of the SUs')
ylabel('The utility rate')

arrivalRate = [0.025 * [1:16]+ 0.2];
load('fig2.mat')

WIDTH = 2;
nRunning = 10000;
r = 209/255;
g = 73/255;
b = 78/255;
Y = [proposedReward';energyReward';CSMAoverallreward';randomReward';myopicReward']'/nRunning;

bar1 = bar(arrivalRate(6:11),Y(6:11,:))

set(gca,'xtick',[0.35:0.025:0.475],'ytick',[0:0.05:0.4])
axis([0.325, 0.525, 0, 0.4])
xlabel('The arrival rate of the users')
ylabel('The utility ratio')
r = 209/255;
g = 73/255;
b = 78/255;


r = 248/255;
g = 147/255;
b = 29/255;

r = 107/255;
g = 194/255;
b = 53/255;

r = 0/255;
g = 90/255;
b = 171/255;


r = 114/255;
g = 83/255;
b = 52/255;



set(gca,'GridLineStyle','--')
legend('POMDP','EB Method','CSMA/CD','Random','CSMA/CA',30)






leaveRate = [0.01 * [1:16] + 0.09];
load('fig3.mat')

Y = [proposedReward';energyReward';CSMAoverallreward';randomReward';myopicReward']'/nRunning;
subplot(2,1,2)
bar(leaveRate(1:6),Y(1:6,:))

set(gca,'xtick',[0.1:0.01:0.15],'ytick',[0:0.05:0.4])
axis([0.09, 0.17, 0, 0.4])
xlabel('The leaving rate of the users')
ylabel('The utility ratio')
set(gca,'GridLineStyle','--')
legend('POMDP','EB Method','CSMA/CA','Random','CSMA/CD',30)
