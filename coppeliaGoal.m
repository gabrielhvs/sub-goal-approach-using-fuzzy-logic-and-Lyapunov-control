function coppeliaGoal(block)

setup(block);

%%
function setup(block)

% Register number of ports
block.NumInputPorts = 0;
block.NumOutputPorts = 1;

% Override output port properties
block.OutputPort(1).Dimensions       = 2;
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
obj.goal = obj.sim.getObject('/Goal');

set_param(block.blockHandle,'UserData',obj);

%%
function Outputs(block)

obj = get_param(block.BlockHandle, 'UserData');

pos = obj.sim.getObjectPosition(obj.goal,-1);
[xg,yg,~] = pos{:};

block.OutputPort(1).Data = double([xg,yg]);

%%
function Terminate(block)
