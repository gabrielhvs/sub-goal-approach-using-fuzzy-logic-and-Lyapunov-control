close all, clear all, clc
%%

d = {'dNO','dNE','dES','dSE','dSO','dSW','dWE','dNW'};

fis = mamfis('Name','fuzzyModified');

eGMF = {'N','M','F'};
fis = addVar(fis,"input",'eG',[0 13],eGMF);

alphaGMF = {'SOn','SE','ES','NE','NO','NW','WE','SW','SOp'};
fis = addVar(fis,"input",'alphaG',[-pi,pi],alphaGMF);

eMF = {'S','M','B'};
fis = addVar(fis,'output','e',[0 3],eMF);

alphaMF = {'SOn','SE','ES','NE','NO','NW','WE','SW','SOp'};
fis = addVar(fis,"output",'alpha',[-pi,pi],alphaMF);

for i = 1:numel(d)
    fis = addInput(fis,[0 1],'Name',d{i});
    fis = addMF(fis,d{i},'trapmf',[-0.5,0,0.5,1],'Name','S');
    fis = addMF(fis,d{i},'trapmf',[-0.5,0,0.8,1],'Name','O');
end

% Ir ao objetivo:
goalSeeking = [
    [(1:3)',zeros(3,1),-and(ones(3,8),[1 0 0 0 1 0 0 0]),(1:3)',zeros(3,1),ones(3,1),ones(3,1)];
    [zeros(9,1),(1:9)',-and(ones(9,8),[1 0 0 0 1 0 0 0]),zeros(9,1),(1:9)',ones(9,1),ones(9,1)];
];

% Desviar de obstáculos:
obstacleAvoidance = [
    [0,0,[1 1 0 1 1 1 0 1],1,0,1,2];
    [zeros(7,3),eye(7),zeros(7,1),(8:-1:2)',[.8;.5;.8;1;.8;.5;.8],ones(7,1)];
    [0,0,1,0,2,0,0,0,0,0,0,9,1,1];
    [0,0,1,0,0,0,0,0,2,0,0,1,1,1];
    [0,0,1,0,-2,0,0,0,-2,0,0,1,1,1];
];

% Tracking:
tracking = [
    [zeros(3,1),(2:4)',-ones(3,1),ones(3,3),zeros(3,4),2*ones(3,1),5*ones(3,1),ones(3,1),ones(3,1)];
    [zeros(3,1),(6:8)',-ones(3,1),zeros(3,4),ones(3,3),2*ones(3,1),5*ones(3,1),ones(3,1),ones(3,1)];
];

rules = [goalSeeking;obstacleAvoidance;tracking];

fis = addRule(fis,rules);
writeFIS(fis,'fuzzyModified');

%%
function fisOut = addVar(fisIn,type,name,range,MF)
    if type == "input"
        fisOut = addInput(fisIn,range,'Name',name);
    elseif type == "output"
        fisOut = addOutput(fisIn,range,'Name',name);
    end
    
    for i = 1:numel(MF)
        params = (i - [2,1,0])*diff(range)/(numel(MF)-1) + range(1);
        fisOut = addMF(fisOut,name,'trimf',params,'Name',MF{i});
    end
end
%%