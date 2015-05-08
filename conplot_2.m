
[vector216, number] = getAlpha('con216')
vector216 = 104 * ones(121,1);
vector216(1:6) = [2,3,46,86,152,106];

[vector316, number] = getAlpha('con316')
vector316 = 140 * ones(128,1);
vector316(1:5) = [2,3,48,130,142];

[vector416, number] = getAlpha('con416')
vector416 = 58 * ones(128,1)
vector416(1:6) = [2,3,46,90,196,112]
[vector516, number] = getAlpha('con516')

r = 209/255;
g = 73/255;
b = 78/255;
% plot((vector116),'LineWidth',WIDTH,'Color',[r g b])
box on;
hold on;
grid on;

r = 248/255;
g = 147/255;
b = 29/255;
axis([0, 130, 0, 1])
set(gca,'xtick',[0:13:130])


r = 107/255;
g = 194/255;
b = 53/255;
% plot((vector158),'LineWidth',WIDTH,'Color',[r g b])


r = 114/255;
g = 83/255;
b = 52/255;
plot((vector216),'LineWidth',WIDTH,'Color',[r g b])

r = 0/255;
g = 90/255;
b = 171/255;
plot((vector316),'LineWidth',WIDTH,'Color',[r g b])
plot((vector416),'LineWidth',WIDTH,'Color',[r g b])
r = 107/255;
g = 194/255;
b = 53/255;
plot((vector516),'LineWidth',WIDTH,'Color',[r g b])