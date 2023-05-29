

warning('off','fuzzy:general:warnDeprecation_Evalfis');
warning('off','fuzzy:general:warnEvalfis_NoRuleFired');
%% Input



Np = 1500;

pos = zeros(Np,3);
sensorP = zeros(16);

dx = zeros(Np);
dy = zeros(Np);

tol = 0.2;

dt = 0.05;

h1 = 1;
w1=0.075;
n = 15;
wall = zeros(n,3);

%% Conexão com o coppelia

    disp('Program started');

    clientID = RemoteAPIClient();
    sim = clientID.getObject('sim');
    
    disp('Connected to remote API server');
    
    % Enabling the synchronous mode on the client
    clientID.setStepping(true);
    
    % Getting object handles
    rob=sim.getObject('/PioneerP3DX');
    goal=sim.getObject('/Goal');
    
    leftMotor=sim.getObject('/PioneerP3DX/leftMotor');
    rightMotor=sim.getObject('/PioneerP3DX/rightMotor');
   

    
   
%%    
    for i = 1:16
    sensorP(i)=sim.getObject(['/PioneerP3DX/visible/ultrasonicSensor['+string(i-1)+']']);
    end
   
    % Simulation time step
    eR=zeros(Np, 1);
    alphaR=zeros(Np, 1);
    t=zeros(Np, 1);
    uR=zeros(Np,1);
    wR=zeros(Np,1);
    t=zeros(Np, 1);
    posR=zeros(Np,3);
    R = 0.0975;
    L = 0.331/2;
    
    %% Start the simulation CoppeliaSim
    sim.startSimulation();
    
    % Get Initial Conditions
    posI=sim.getObjectPosition(rob,-1);
    oriI=sim.getObjectOrientation(rob,-1);
    
    posR(1,:) = [posI{1,1},posI{1,2},oriI{1,3}];
        
    LeftVel=0;
    RightVel=0;

    resL=sim.setJointTargetVelocity(leftMotor,LeftVel);
    resR=sim.setJointTargetVelocity(rightMotor,RightVel);
    GS = readfis('Control_u_w/Goal_seeking');
    OA = readfis('Control_u_w/Obtacle_avoidance');
    TR = readfis('Control_u_w/Tranking');
    DLo = readfis('Control_u_w/DeadLoak');
    distanceS = zeros(16);
    posG=sim.getObjectPosition(goal,-1);
    posA = [posG{1,1}, posG{1,2}, 0];
%%
    for i=1:Np
        
        clientID.step();
        
        for j = 1:16
        [o,distanceS(j)]=sim.readProximitySensor(sensorP(j));
        if(o==0), distanceS(j) = 3; end
        end
        
        DL = (distanceS(1));
        DF = min(distanceS(4:5));
        DR = (distanceS(8));
        DB = min(distanceS(12:13));
        
        
        dx = posA(1)-posR(i,1);
        dy = posA(2)-posR(i,2);
        

        distance_alvo = sqrt((dx)^2+(dy)^2);
        angle_alvo = atan2(dy,dx)-posR(i,3);
        angle_alvo = atan2(sin(angle_alvo),cos(angle_alvo));
        angle_alvo = rad2deg(angle_alvo);
        
        
        if (DL<0.5) && (DF<0.5) && (DR<0.5) && (DB>2)
            
            a = evalfis([DF DR DL DB angle_alvo],DLo);
            
            u = a(1);
            w = -a(2);
            
            b="dead_loak";
        
        elseif ((DL<1.5) || (DR<1.5)) && (DF<1)
            
            a = evalfis([DF DR DL],OA);
            
            u = a(1)/2;
            w = -a(2)/4;
            
            b="Obstacle1";
        
        elseif (DL>2)&&(DR>2)&&(DF<1.5)
            
            a = evalfis([DF DR DL],OA);
            
            u = a(1);
            w = -a(2)/2;
            
            b="Obstacle2";

        elseif (DL<2) && ((DF>=2)) && (DR<2) 
            a = evalfis([DF DR DL angle_alvo],TR);
            
            u = a(1);
            w = a(2);
            
            b="Tracking"; 
            
        elseif ((DL<2)||(DR<2)) && (DF>=2)  
            
            a = evalfis([DF DR DL  angle_alvo],TR);
            
            u = a(1);
            w = a(2);
            
            b = "Tracking";
           
        else%if (DL>1.5) && ((DF>1.5)) && (DR>1.5)
            
        a = evalfis([distance_alvo angle_alvo],GS);
        u = a(1);
        w = a(2)/2;
   
        b="Goal";
        
            
        
        end
            
         if distance_alvo < tol
            
            u = 0;
            w = 0;
            Np=i;
            
            posR=posR(1:Np,:);
            uR = uR(1:Np);
            wR = wR(1:Np);
            t=t(1:Np);
           
            break;
           end
        
        disp(b)
        velR = (2*u+w*L)/(2*R);
        velL = (2*u-w*L)/(2*R);
       
        resL=sim.setJointTargetVelocity(leftMotor,velL);
        resR=sim.setJointTargetVelocity(rightMotor,velR);
       
        posP=sim.getObjectPosition(rob,-1);
        oriP=sim.getObjectOrientation(rob,-1);
        
        t(i)=(i-1)*dt;
        posR(i+1,1)=posP{1,1};
        posR(i+1,2)=posP{1,2};
        posR(i+1,3)=oriP{1,3};
        eR(i) = distance_alvo;
        uR(i) = u;
        wR(i) = w;
        alphaR(i) = sqrt(angle_alvo^2);
     
    end
    % Stop the simulation
   sim.stopSimulation();
   
%% Plot

% t = linspace(0,dt*Np,Np);
% figure(1)
% hold on
% h=plot(posR(1:Np,1),posR(1:Np,2),"k");
% set(h,{'LineWidth'},{2});
% axis equal
% grid
% for i=1:round(length(posR(1:Np,1))/20):length(posR(1:Np,1))
%     drawRobot(posR(i,1),posR(i,2),posR(i,3),0.06);
% end
% legend('Posição Coppelia')
% xlabel('x(m)')
% ylabel('y(m)')
% 
% for i=1:size(wall,1)
%     xc = w1*cos(wall(i,3))+h1*abs(sin(wall(i,3)));
%     yc = h1*cos(wall(i,3))+w1*abs(sin(wall(i,3)));
%     rectangle('Position',[wall(i,1)-xc wall(i,2)-yc 2*xc 2*yc],'FaceColor',"k")
% end
% 
% hold off
% 
% figure(2)
% error = plot(t(1:Np),eR(1:Np));
% grid
% set(error,{'LineWidth'},{2});
% legend('Erro distancia(m)')
% xlabel('t(s)')
% ylabel('Erro distancia(m)')
% 
% figure(3)
% error = plot(t(1:Np),alphaR(1:Np));
% grid
% set(error,{'LineWidth'},{2});
% legend('Erro angulação(rad)')
% xlabel('t(s)')
% ylabel('Erro orientação(rad)')
% 
% 
% figure(4)
% error = plot(t(1:Np),uR(1:Np));
% grid
% set(error,{'LineWidth'},{2});
% legend('Velocidade Linear' )
% xlabel('t(s)')
% ylabel('velocidade(m/s)')
% 
