function visEnviro = hdLabSetupScreen()
%function sets up screen for multiple tasks & loads default visual settings
%written by Seth Konig 2/17/2020
% 
% Inputs:
%   none)
%
% Outputs:
%   1) visEnviro: structure containing information about screen

visEnviro = struct();

%load default visual environment settings e.g. physcial screen size
visEnviro.rig = defaultRig_params();

sca;%clear/close screen if currently open
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'ConserveVRAM', 64);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0); %Hides PTB Warnings

% Create new window and record size
% ref_rate = Screen('framerate', visEnviro.screen); % For temporary check of the monitor display rate.
[visEnviro.screen.window, visEnviro.screen.windowRect] = Screen('OpenWindow', visEnviro.rig.screenNumber); %, color_opt.background, [], [], [], [], 1 );
[visEnviro.screen.screenWidth, visEnviro.screen.screenHeight] = Screen( 'WindowSize', visEnviro.screen.window );
[visEnviro.screen.xCenter, visEnviro.screen.yCenter] = RectCenter(visEnviro.screen.windowRect);

[visEnviro.screen.displayWidth, visEnviro.screen.displayHeight] = Screen('DisplaySize', visEnviro.rig.screenNumber); %GK insertion

% Define origin of screen
visEnviro.screen.origin = [(visEnviro.screen.windowRect(3) - visEnviro.screen.windowRect(1))/2 ...
    (visEnviro.screen.windowRect(4) - visEnviro.screen.windowRect(2))/2];

%give a moment to initiate before doing other potentially heavy things
WaitSecs(0.5);

end