close all, clear all, clc
%% Parâmetros
R = 0.195/2; L = 0.331;

emin = 0.5;
u_max = 1.2;
omega_max = (pi/180)*300;

gamma = 0.3; k = 1; % Parâmetros do controlador não-linear (Lyapunov)

%% Controlador Fuzzy
Tracking = readfis('Tracking');
Obstacle = readfis('Obstacle2');

%% Simulação
out = sim('model_R2019b');
