function coppeliaScene(block)

setup(block);

%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Override input port properties
for i = 1:2
    block.InputPort(i).Dimensions        = 1;
    block.InputPort(i).DatatypeID  = 0;  % double
    block.InputPort(i).Complexity  = 'Real';
    block.InputPort(i).DirectFeedthrough = true;
    block.InputPort(i).SamplingMode = 'Sample';
end

% Override output port properties
block.OutputPort(1).Dimensions       = 3;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
block.SampleTimes = [0.05 0];

block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

%%
function Start(block)

obj.client = RemoteAPIClient();
obj.sim = obj.client.getObject('sim');

obj.client.setStepping(true);
obj.robot = obj.sim.getObject('/PioneerP3DX');
obj.leftMotor = obj.sim.getObject('/PioneerP3DX/leftMotor');
obj.rightMotor = obj.sim.getObject('/PioneerP3DX/rightMotor');

assignin('base','obj',obj);
set_param(block.BlockHandle, 'UserData', obj);

%%
function InitializeConditions(block)

obj = get_param(block.BlockHandle, 'UserData');

obj.sim.startSimulation();

%%
function Outputs(block)

obj = get_param(block.BlockHandle, 'UserData');

u = block.InputPort(1).Data;
omega = block.InputPort(2).Data;

wr = (2*u + 0.331*omega)/0.195;
wl = (2*u - 0.331*omega)/0.195;

obj.sim.setJointTargetVelocity(obj.rightMotor,wr);
obj.sim.setJointTargetVelocity(obj.leftMotor,wl);

obj.client.step();

pos = obj.sim.getObjectPosition(obj.robot,-1);
ori = obj.sim.getObjectOrientation(obj.robot,-1);
[x,y,~] = pos{:}; [~,~,phi] = ori{:}; pose = [x,y,phi];

block.OutputPort(1).Data = double(pose);

%%
function Terminate(block)

obj = get_param(block.blockHandle, 'UserData');

obj.sim.stopSimulation();
