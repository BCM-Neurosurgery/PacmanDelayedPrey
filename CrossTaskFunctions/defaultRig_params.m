function rig = defaultRig_params()
%Setup the rig environment struct - used by all task functions
%Sets values for physical parameters of the rig that are shared across all
%tasks, but does not include eye tracker parameters because each task may use
%the eye tracker differently. 
%
%Turned into function by Seth Koenig, removed global, was defaultEnv.m
%
% Inputs: None
% 
% Outputs:
%   1) rig: structure containing all relevant rig information

rig = [];

%screen parameters
rig.screenNumber = max(Screen('Screens'));
rig.resolution = Screen('Resolution',rig.screenNumber);
rig.width = rig.resolution.width;%redundant but some scripts are formatted for this
rig.height = rig.resolution.height;%redundant but some scripts are formatted for this
rig.distance = 57; % in cm, ~participant distance from screen
rig.physicalWidth = 48.5; % in cm, width of the visible screen
rig.physcialHeight = 27.5;%in cm, height of visible screen
rig.colorDepth = 255;

%photodiode parameters
rig.usePhotoDiode = true;
rig.photoDiodeSize = 100; %pixels square width/height
rig.photoDiodeLocation = 3; %1: upper left, 2 for upper right, 3 for lower left, 4 for lower right

%Location, software versions, and computer name parameters
rig.rigID = 'BaylorEMU';
rig.neuralRecording = true;
rig.computerName = getenv('computername');
rig.matlabVersion = version;
rig.psychToolboxVersion = PsychtoolboxVersion;

%TTL hardware parameter
rig.ttlMode = 'BlackrockComment';%current options: USB2TTL8, USB-6501, Python, Plexon (not recommended), BlackrockComment or none
rig.ttlPort = 'COM4'; %for python this is '0x0278' in hex for LPT3, https://www.psychopy.org/api/parallel.html
rig.ttlDeviceNumber = 1;%if multiple devices need to specify which
rig.ttlNumBits = 8; %number of channels to write, currently only used by USB-6501 & Parallel Port
rig.ttlDuration = 1;%in milliseconds

%response pad and other hardware
rig.responsePadType = 'RB-740';
rig.responsePadPort = 'COM5';
rig.responsePad1 = 2; %offset by 1
rig.responsePad2 = 3; %offset by 1
rig.responsePad3 = 4; %offset by 1
rig.responsePadGreenKey = 5; %often for target/go (green)
rig.responsePadRedKey = 6; %often for non-target/no-go (red)
rig.responsePadYellowKey = 7; %often for other (yellow)
%rig.responsePad = 8;%currenlty unused key

end