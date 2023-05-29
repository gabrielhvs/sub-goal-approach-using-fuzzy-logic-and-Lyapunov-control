function p3dxUltrasonic(block)

setup(block);

%%
function setup(block)

% Register number of ports
block.NumInputPorts = 0;
block.NumOutputPorts = 1;

% Override output port properties
block.OutputPort(1).Dimensions       = 16;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
block.SampleTimes = [0.05 0];

block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

%%
function InitializeConditions(block)

obj = evalin('base','obj');
obj.sensor = zeros(1,16);
for i = 1:16
    obj.sensor(i) = obj.sim.getObject(...
        ['/PioneerP3DX/visible/ultrasonicSensor[',num2str(i-1),']']);
end

set_param(block.blockHandle,'UserData',obj);

%%
function Outputs(block)

obj = get_param(block.BlockHandle, 'UserData');

distance = zeros(1,16);
for i = 1:16
    [flag, d] = obj.sim.readProximitySensor(obj.sensor(i));
    if(flag)
        distance(i) = double(d);
    else
        distance(i) = 3;
    end
end

block.OutputPort(1).Data = distance;

%%
function Terminate(block)
