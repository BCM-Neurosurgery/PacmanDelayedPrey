function pacmanOpts = hPacman_params(subjID,rewardStructType, nTrials, emuNum)
%function sets generate parameters for task, this is the only place you
%should have to do this.
%written 5/14/2020 based on hpacman_params

pacmanOpts = struct;

%---File & Directory parameters---%
mainFolderName = 'Pacman humanECoG';
thisPath = mfilename('fullpath');
mainFolderStart = strfind(thisPath,mainFolderName);
pacmanFolder = thisPath(1:mainFolderStart+length(mainFolderName));
cd(pacmanFolder)

pacmanOpts.fileParams.pacmanFolder = pacmanFolder;
pacmanOpts.fileParams.createEDFFile = true;
pacmanOpts.fileParams.subjID = subjID;
pacmanOpts.fileParams.taskName = 'Pacman';
[pacmanOpts.fileParams.fileBaseName,pacmanOpts.fileParams.subjectDir,pacmanOpts.fileParams.dataDirectory] = ...
    hdLabSetFileNames(subjID,pacmanOpts.fileParams.taskName);
pacmanOpts.fileParams.eyeDataFolder = [pacmanOpts.fileParams.dataDirectory 'eyeData' filesep];
% Added by JA & RM to create a Neural Recording Filename that matches
% Baylor EMU naming conventions. EB added EmuNum (was 0 before)
time = regexp(pacmanOpts.fileParams.fileBaseName,'\d{8}_\d{6}','match');
pacmanOpts.fileParams.neuralRecFilename = sprintf('EMU-%.3d_subj-%s_task-%s_time-%s',emuNum,pacmanOpts.fileParams.subjID,pacmanOpts.fileParams.taskName,time{:});


%---Trial Parameters---%
pacmanOpts.trialParams.ntrials = nTrials;
pacmanOpts.trialParams.rewardStructType = rewardStructType;


%---Position Parameters---%
%for ecocentric grid of 8 points
pacmanOpts.positions.numPositions = 8; %current options: <= 8 & 24 (which produces a grid)
pacmanOpts.positions.eccentricity = 400;%in pixels, suggested 400, for <= 8 case

%---Chase parameters---%
%default values are 1.0
pacmanOpts.chase.collisionRadiusFactor = 1.0; %multiplier of collision radius, larger easier, smaller harder
pacmanOpts.chase.preySpeedFactor = 2.0; %speed multiplier of prey, smaller makes easier larger makes harder
pacmanOpts.chase.predatorSpeedFactor = 2.0; %speed multiplier of predator, smaller makes easier larger makes harder


%---Joystick Parameters---%
pacmanOpts.joystickParams.playerSpeed = 10;
pacmanOpts.joystickParams.joystickThreshold = 0.05; %threshold for determining when the joystick has moved
pacmanOpts.joystickParams.maxVal = 1.0009; %joystick inputs ranges from -1 to 1.0019
pacmanOpts.joystickParams.sensitivity = pacmanOpts.joystickParams.playerSpeed/pacmanOpts.joystickParams.maxVal; % determines player velocity (pixels/frame); this number is multiplied by joystick value


%---Timing Parameters---%
% Inter-trial interval bounds (s)
pacmanOpts.timingParams.iti = [0.5, 0.75]; %same as bandit

%all values in seconds
%pacmanOpts.timingParams.drawTime = @(x) min(x) + (range(x) .* rand(1,1));
pacmanOpts.timingParams.drawTime = @(x) min(x) + ((max(x)-min(x)) .* rand(1,1));

% pre-chase period wait
pacmanOpts.timingParams.waitTime = [0.75 1];%time between stimuli appearing and chase begin

% task timing parameters (s)
pacmanOpts.timingParams.timeout = 20;%maximum length of chase period

%Timing for feedback
%if choice2feedbackDuration == 0, then this period is skipped
pacmanOpts.timingParams.choice2feedbackDuration = 0.35;%time stimuli appear on the screen until feedback period starts
pacmanOpts.timingParams.feedbackTextDuration = 1.5;% feedback duration


%---Feedback Parameters---%
pacmanOpts.feedbackParams.fontSize = 40;
pacmanOpts.feedbackParams.fdbkShift = [40 40 -40 -40];
pacmanOpts.feedbackParams.errorSize = 8;
pacmanOpts.feedbackParams.errorColor = [0 0 0];%[0 128 0];


%---Eye tracker parameters---%
pacmanOpts.eyeParams.eyeTrackingMode = 'none';%'passive' else 'none', there is no active tracking in this task
pacmanOpts.eyeParams.eyeTrackerConnected = false; %this is for Matlab to change, keep at false


%---Debug Parameters---%
pacmanOpts.debugMode = false; %flags extra print functions, displays, etc. in mutliple locations

%cheater modes are autoplayers with different perofmances i.e. accurancy and speed
%cheater mode is activated by setting subject ID to one of the cheater names
pacmanOpts.cheaterMode.cheaterNames = {'Cheater','Naive','Troll'};%acceptable autoplayer names, don't modify without modifying code
pacmanOpts.cheaterMode.cheaterNames = cellfun(@lower, pacmanOpts.cheaterMode.cheaterNames,'UniformOutput',false);%lower all

end