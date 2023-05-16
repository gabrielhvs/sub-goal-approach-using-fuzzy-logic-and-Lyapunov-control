close all, clear all, clc
%%

fis = readfis('fuzzyArticle');

fig = figure('Position',[50,50,900,600]);
for i = 1:3
    subplot(2,2,i);
    plotmf(fis,'input',i);
end
subplot(2,2,4); plotmf(fis,'input',6)
saveas(fig,'Images/fisArticleInputs.png');
%%
fig = figure('Position',[50,50,500,600]);
for i = 1:2
    subplot(2,1,i);
    plotmf(fis,'output',i);
end
saveas(fig,'Images/fisArticleOutputs.png');
%%
showrule(fis,'Format','symbolic')

%%
fis = readfis('fuzzyModified');

fig = figure('Position',[50,50,600,800]);
for i = 1:3
    subplot(3,1,i);
    plotmf(fis,'input',i);
end
saveas(fig,'Images/fisModifiedInputs.png');
%%
fig = figure('Position',[50,50,500,600]);
for i = 1:2
    subplot(2,1,i);
    plotmf(fis,'output',i);
end
saveas(fig,'Images/fisModifiedOutputs.png');
%%
showrule(fis,'Format','symbolic')
