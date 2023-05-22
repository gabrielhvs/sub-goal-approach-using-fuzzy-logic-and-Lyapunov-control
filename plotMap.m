close all
%%
client = RemoteAPIClient();
sim = client.getObject('sim');

wall = []; i = 0;
while true
    options.index = i; options.noError = true;
    handle = sim.getObject('/Cuboid',options);
    if handle < 0
        break;
    end
    wall = [wall,handle]; i = i + 1;
end

fig = figure('Name','Map',Position=[50,20,850,850]);
for i = 1:numel(wall)
    pos = sim.getObjectPosition(wall(i),-1);
    ori = sim.getObjectOrientation(wall(i),-1);
    [~,~,geo] = sim.getShapeGeomInfo(wall(i));

    [x,y,~] = pos{:}; phi = ori{3}; [lx,ly,~] = geo{:};
    polygon = polyshape(lx*[-.5,-.5,.5,.5],ly*[.5,-.5,-.5,.5]);
    polygon = rotate(polygon,(180/pi)*phi,[0 0]);
    polygon = translate(polygon,[x,y]);
    plot(polygon,FaceColor='k',EdgeColor='none'); hold on;
end

plotTraj(fig,out.poseR,'r');
axis equal; xlim([0 10]); ylim([0 10]); grid off;

%%
function plotTraj(fig,poseR_list,color)

x = poseR_list.Data(:,1);
y = poseR_list.Data(:,2);
phi = poseR_list.Data(:,3);

persistent ax;

if isempty(ax) || ~isvalid(ax) || isempty(fig.CurrentAxes)
    ax = fig.CurrentAxes;
    if isempty(ax)
        ax = axes(fig);
    end
    
    axis(ax,'equal'); grid(ax,'on'); hold(ax,'on');
    title(ax,'Trajetória',FontName='Times');
    xlabel(ax,'$x(m)$',Interpreter='latex');
    ylabel(ax,'$y(m)$',Interpreter='latex');
end

plot(ax,x,y,'--',Color=color);
plot(ax,x(1),y(1),'ko',MarkerFaceColor='k',MarkerSize=10);
plot(ax,x(end),y(end),'ko',MarkerFaceColor='g',MarkerSize=10);

r = polyshape([-0.1 -0.1 0.13],[-0.1 0.1 0]);
L = length(x);

for i = 1:floor(L/10):L
    if sqrt((x(1)-x(i))^2 + (y(1)-y(i))^2) > 0.15 &&...
            sqrt((x(end)-x(i))^2 + (y(end)-y(i))^2) > 0.15
        r1 = translate(rotate(r,(180/pi)*phi(i)),[x(i), y(i)]);
        plot(ax,r1,FaceColor=color);
    end
end
end
