close all, clear all, clc
warning('off','fuzzy:dialogs:warnEvalfis_NoRuleFired')

%% Parâmetros
R = 0.195/2; L = 0.331;

emin = 0.05;
u_max = 1.2;
omega_max = (pi/180)*300;

gamma = 0.3; k = 1; % Parâmetros do controlador não-linear (Lyapunov)

%% Controlador Fuzzy
Tracking = readfis('Tracking');
Obstacle = readfis('Obstacle');
DeadLock = readfis('DeadLock');
Fuzzy_Behavior = readfis('Fuzzy_Behavior');
%% Simulação
out = sim('model_backward');
plotMap

figname = input("Figure name (map): ","s");
saveas(fig,['Images/',figname,'.jpg']);
