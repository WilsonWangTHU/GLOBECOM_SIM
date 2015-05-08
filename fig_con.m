
[vector116, number] = getAlpha('con116')

[vector158, number] = getAlpha('con158')

[vector216, number] = getAlpha('con216')

[vector316, number] = getAlpha('con316')

[vector416, number] = getAlpha('con416')

[vector516, number] = getAlpha('con516')

r = 209/255;
g = 73/255;
b = 78/255;
plot((vector116),'LineWidth',WIDTH,'Color',[r g b])
box on;
hold on;
grid on;

xlabel('The number of iterating epoch')
ylabel('The convergence of bellman iteration')

axis([0, 60, 0, 1])
set(gca,'xtick',[0:13:130])


r = 0/255;
g = 50/255;
b = 104/255;

plot((vector158),'LineWidth',WIDTH,'Color',[r g b])

r = 114/255;
g = 83/255;
b = 52/255;
plot((vector216),'LineWidth',WIDTH,'Color',[r g b])

r = 0/255;
g = 90/255;
b = 171/255;
plot((vector316),'LineWidth',WIDTH,'Color',[r g b])
r = 248/255;
g = 147/255;
b = 29/255;
plot((vector416),'LineWidth',WIDTH,'Color',[r g b])
r = 107/255;
g = 194/255;
b = 53/255;
plot((vector516),'LineWidth',WIDTH,'Color',[r g b])


legend('\(N_A=1, \lambda = 0.4, \mu = 0.05, \mu_S = 1\mathcal{W}_e, \sigma_S = 0.5\mathcal{W}_e\)', ...
    '\(N_A=1, \lambda = 0.3, \mu = 0.08, \mu_S = 1\mathcal{W}_e, \sigma_S = 0.5\mathcal{W}_e\)', ...
    '\(N_A=2, \lambda = 0.4, \mu = 0.1, \mu_S = 1\mathcal{W}_e, \sigma_S = 0.5\mathcal{W}_e\)',...
    '\(N_A=2, \lambda = 0.4, \mu = 0.25, \mu_S = 1\mathcal{W}_e, \sigma_S = 0.5\mathcal{W}_e\)',...
    '\(N_A=2, \lambda = 0.4, \mu = 0.1, \mu_S = 0.2\mathcal{W}_e, \sigma_S = 0.1\mathcal{W}_e\)',...
    '\(N_A=1, \lambda = 0.4, \mu = 0.1, \mu_S = 0.2\mathcal{W}_e, \sigma_S = 0.1\mathcal{W}_e\)',...
    30)