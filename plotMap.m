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

figure('Name','Map');
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
axis equal; xlim([0 10]); ylim([0 10]); grid off;