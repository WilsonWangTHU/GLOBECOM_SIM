figure(1)
   
box on;
close
hold on;
grid on;
load('fig1.mat')
for i = 1:1 :16

r = 209/255;
g = 73/255;
b = 78/255;
c = [r,g,b]
    scatter(energyEnergyHarvest(i), energyReward(i),20,c);
end
%     
    

axis([0, 20000, 0, 2e4])