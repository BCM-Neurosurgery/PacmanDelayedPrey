function [eyeTrackerhHandle,visEnviro,pacmanOpts,ttlStruct] = pacmanOpenTask(pacmanOpts)
%function setups all of the psychtoolbox things needed to run the task, the
%eye tracker, etc. Pretty generic but could vary some by task
%modified very slightly for pacman task from bandit version by Seth Konig 5/14/20

% set the correct modes, NOT based on user input
ListenChar(2);

%% Initialize screen & audio settings
visEnviro = hdLabSetupScreen();
Screen('TextSize',visEnviro.screen.window, pacmanOpts.feedbackParams.fontSize);


%% Setup Audio
%setup audio handle
visEnviro.soundParams = [];
[visEnviro.soundParams.audioOutHandle,visEnviro.soundParams.speakerFrequency] = setupOutputAudioHandle();

%make reward sounds
[visEnviro.soundParams.sf,visEnviro.soundParams.rwdSound,visEnviro.soundParams.norwdSound] = makeAudioFeedback(visEnviro.soundParams.speakerFrequency);


%% Initialize keyboard functions
pacmanOpts.KB = hdLabSetupKeyboard();%initiate keyboard short cuts


%% Initialize Eye Tracker
% Connection with Eyelink if using eye tracking
try
    if ~strcmpi(pacmanOpts.eyeParams.eyeTrackingMode,'none')
        [eyeTrackerhHandle,~,pacmanOpts.eyeParams.eyeTracked] = setupHDLabEyeLink(....
            visEnviro.screen.window,pacmanOpts.fileParams.createEDFFile,pacmanOpts.fileParams.fileBaseName(1:4));
    else
        eyeTrackerhHandle = [];
    end
    
    %check if eye tracker connected afterwards
    if Eyelink('IsConnected')
        pacmanOpts.eyeParams.eyeTrackerConnected = true;
    else
        pacmanOpts.eyeParams.eyeTrackerConnected = false;
    end
catch
    %check if you wanted to really try to connect to the eye tracker
    if ~strcmpi(pacmanOpts.eyeParams.eyeTrackingMode,'none')
        disp('Trouble connecting with the eye tracker')
        text = ['Eye tracker failed to connection despite you trying to connect to it! \n'....
            'Press Space to continue without the eye tracker, and \n'...
            'Press Q to quit!'];
        DrawFormattedText(visEnviro.screen.window, text,'center', 'center');
        DrawFormattedText(visEnviro.screen.window, text,'center', 'center');
        Screen('Flip',visEnviro.screen.window);
        
        waitForKeyPress = true;
        while waitForKeyPress
            [~, ~, keyCode] = KbCheck;
            if keyCode(pacmanOpts.KB.space)
                waitForKeyPress = false;
                eyeTrackerhHandle = [];
                pacmanOpts.eyeParams.eyeTrackerConnected = false;
            elseif keyCode(pacmanOpts.KB.quitKey)
                waitForKeyPress = false;
                error('Failed to connect to the eye tracker!')
            end
            WaitSecs(0.001); %so doesn't loop too fast
        end
        
        %clear screen and give program a momenet to reset
        Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
        Screen('Flip',visEnviro.screen.window);
        WaitSecs(0.5);
        
    else
        eyeTrackerhHandle = [];
        pacmanOpts.eyeParams.eyeTrackerConnected = false;
    end
end

%% Initialize TTL Port
ttlStruct = hdLabSetupTTLDevice(visEnviro.rig);
markEvent('taskStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);

end