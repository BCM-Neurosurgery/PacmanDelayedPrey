function pacmanRunTrial(pacmanOpts,visEnviro,pacmanTaskSpecs,eyeTrackerhHandle,ttlStruct)
%script runs trials of pacman task, based on pacman task's runTrial
%note task looks for keyboard input during all trial periods, but pausing
%only works during ITI period and recalibration only works during ITI and
%central cue period! Quitting happens during same periods so no actions are going on.
%
%written by Seth Konig 5/14/2020\

% We need this for future checks
has_delay = contains(pacmanOpts.trialParams.rewardStructType, '50plusDelay'); % GK insertion

%---Set Multi-trial (i.e.session) Variables---%
sessionVars = [];
sessionVars.trialNum = 0;%0; %trial number, always goes up
sessionVars.blockNum = 0; %pseudo block for TTL pulses
sessionVars.rewards = 0;
sessionVars.pauseFlag = false;
sessionVars.quitTask = false;
sessionVars.recalibrate = false;

%do string cat here so not time consuming later
pauseText = ['Paused \n \n Press "' char(pacmanOpts.KB.unpauseKey) '" to resume task!'];

%superstition but I think this helps, SDK
WaitSecs(0.5);
%Screen(visEnviro.screen.window,'Flip');
Screen('Flip',visEnviro.screen.window);

while (sessionVars.trialNum < pacmanOpts.trialParams.ntrials) && ~sessionVars.quitTask
    
    try
        %parameters for data index
        dataIndex = 1; %tracks index of gaze and mouse mosition because memory is pre-allocated
        
        disp("Step 1")
        %---Initiate Trial---%
        sessionVars.trialNum = sessionVars.trialNum + 1;% Increment trialnum
        sessionVars.blockNum = floor(sessionVars.trialNum/100)+1;%psuedo block for tracking with TTL pulses
        if pacmanOpts.debugMode
            disp(['Initiating Trial number: ' num2str(sessionVars.trialNum) ', in pseudo block ' num2str(sessionVars.blockNum)])
        end

        trialData = pacmanInitiateTrial(pacmanOpts,pacmanTaskSpecs,sessionVars,visEnviro);
        
        disp("Step 2")
        %send trial start TTL pulses, send after initiate cuz that opens/closes eye tracker fils
        trialData.trialStart = markEvent('trialStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        markEvent('trialNumber',sessionVars.trialNum,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        markEvent('blockNumber',sessionVars.blockNum,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);

        %parameters for tracking time in event periods, placed here for debugging since explicit call makes debugging easier
        itiEventTime = NaN; %for tracking duration in while loop in ITI period
        waitEventTime = NaN; %for tracking wait duration in while loop in wait period
        chaseEventTime = NaN; %for tracking time to choice selection in while loop in choice period
        choice2feedbackEventTime = NaN;%for tracking time in choice to feedback period
        feedbackEventTime = NaN; %for tracking feedback duration during feedback period (period following errors only)
        
       
        %---ITI Period----%
        if pacmanOpts.debugMode
            disp('ITI Period Start')
        end
        
        needToDrawPauseText = true;
        
        disp("Step 3")
        trialData.itiStart = markEvent('itiStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
        itiEventTime = GetSecs() - trialData.itiStart;%explicit call makes debuging much easier
        while itiEventTime < trialData.iti
            
            %get eye position
            if pacmanOpts.eyeParams.eyeTrackerConnected
                % Get eye position
                trialData.eyeSamples(:,dataIndex) = sampleEye(pacmanOpts.eyeParams.eyeTracked);
            end
            dataIndex = dataIndex + 1;
            
            disp("Step 4")
            %check for keyboard input
            [sessionVars.pauseFlag, sessionVars.quitTask, sessionVars.recalibrate, ~] = ...
                checkKeyBoardInput(pacmanOpts.KB,sessionVars.pauseFlag,sessionVars.quitTask,sessionVars.recalibrate);
            if sessionVars.pauseFlag && needToDrawPauseText
                Screen(visEnviro.screen.window,'FillRect',pacmanTaskSpecs.colorOpts.background); %clear screen
                DrawFormattedText(visEnviro.screen.window,pauseText,'center', 'center');
                trialData.paused = markEvent('taskPaused',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = false;
            elseif ~sessionVars.pauseFlag && ~needToDrawPauseText
                Screen(visEnviro.screen.window,'FillRect',pacmanTaskSpecs.colorOpts.background); %clear screen
                trialData.resume = markEvent('taskResume',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = true;
            elseif sessionVars.recalibrate
                trialData.recalibrating = markEvent('recalibrateStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
                EyelinkDoTrackerSetup(eyeTrackerhHandle);
                trialData.doneCalibrating = markEvent('recalibrateEnd',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
                sessionVars.recalibrate = false;
            elseif sessionVars.quitTask
                break;%exits while loop, break does not?
            end
            
            WaitSecs(0.001);%so doesn't loop too fast
            
            disp("Step 5")
            if sessionVars.pauseFlag
                itiEventTime = 0; %while paused continually reset ITI time
            else
                itiEventTime = GetSecs() - trialData.itiStart; %update time since event start
            end
        end
        trialData.itiEnd = markEvent('itiEnd',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        
        
        disp("Step 6")
        %---Wait Period---%
        %coded as central cue period
        if pacmanOpts.debugMode
            disp('Wait Period Start')
            disp(['ITI duration was ' num2str(itiEventTime)])
        end
        
        needToDrawPauseText = true;
        
        % Code insertion GK - Prey Removal
        % If there are more than one prey, alert the code to hide one of them
        if has_delay
            % Prey removal
            hideNpc = false;
            trialData.NpcWaitTime = NaN;
            trialData.npcHideEndFrame = NaN;
            trialData.npcHideEndSecs = NaN ;
            preyNum = sum(trialData.npcType(:) == 1);
            % isnan(pacmanOpts.npcHideTimeTable)
            playerWaitZone = [trialData.playerStartPosition,trialData.playerSize(1)/2]; %The place the player needs to leave for the NPC wait countdown to begin [x, y, radius]
            playerWaitZone(1:2) = playerWaitZone(1:2) + playerWaitZone(3);
            disp(playerWaitZone);
            % error('Showcase end- delete line when not debugging');
            if preyNum > 1
                % Retrieve the next available value from the time table
                trialData.NpcWaitTime = pacmanOpts.npcHideTimeTable(trialData.trialNum);

                if trialData.NpcWaitTime > 0; hideNpc = true; end

                % trialData.playerColor(2) = 255; % DEBUG
            end
            npcWaitStart = GetSecs();
        end       
        [trialData.chaseEndSecs, trialData.chaseEndFrame] = deal(NaN);
        % Code insertion GK end
        
        
        disp("Step 7")
        %draw objects on screen
        Screen(visEnviro.screen.window,'FillRect',pacmanTaskSpecs.colorOpts.background); %clear screen
        visualize_NPCs(visEnviro.screen.window, trialData.playerStartPosition, 0, trialData.playerColor, trialData.playerSize); %player
        for npc = 1:trialData.numNpcs
            if trialData.npcType(npc) == 1 %prey
                % Code insertion GK - Hide the NPC when needed
                if has_delay && hideNpc && npc > 1; continue; end
                % Code insertion GK end
                visualize_NPCs(visEnviro.screen.window, trialData.startingPositions{npc},1, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
            elseif trialData.npcType(npc) == -1 %predator
                visualize_NPCs(visEnviro.screen.window, trialData.startingPositions{npc},pacmanTaskSpecs.gameOpts.predatorType, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
            end
        end
        WaitSecs(0.001);
        
        disp("Step 8")
        %draw starting positions
        if pacmanOpts.debugMode
            for pt = 1:size(pacmanTaskSpecs.taskData.startingPositions,2)
                zone = [pacmanTaskSpecs.taskData.startingPositions(1,pt)-2,pacmanTaskSpecs.taskData.startingPositions(2,pt)-2,...
                    pacmanTaskSpecs.taskData.startingPositions(1,pt)+2,pacmanTaskSpecs.taskData.startingPositions(2,pt)+2];
                Screen('FillOval', visEnviro.screen.window, pacmanTaskSpecs.colorOpts.white, zone);
            end
            WaitSecs(0.001);
        end
        
        disp("Step 9")
        trialData.waitStart = markEvent('centralCueStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
        waitEventTime = GetSecs() - trialData.waitStart;%explicit call makes debuging much easier
        while (waitEventTime < trialData.waitTime)
            
            %set joystick position to center of screen, where player is tho they can't move it
            trialData.joystickPosition(1,dataIndex) = trialData.playerStartPosition(1);
            trialData.joystickPosition(2,dataIndex) = trialData.playerStartPosition(2);
            trialData.joystickPosition(3,dataIndex) = GetSecs();
            
            %get eye position
            if pacmanOpts.eyeParams.eyeTrackerConnected
                trialData.eyeSamples(:,dataIndex) = sampleEye(pacmanOpts.eyeParams.eyeTracked);
            end
            
            %get npc position(s)
            for npc = 1:trialData.numNpcs
                trialData.npcPositionX(npc,dataIndex) = trialData.startingPositions{npc}(1);
                trialData.npcPositionY(npc,dataIndex) = trialData.startingPositions{npc}(2);
            end
            
            %check for keyboard input
            [sessionVars.pauseFlag, sessionVars.quitTask, sessionVars.recalibrate, ~] = ...
                checkKeyBoardInput(pacmanOpts.KB,sessionVars.pauseFlag,sessionVars.quitTask,sessionVars.recalibrate);
            if sessionVars.pauseFlag && needToDrawPauseText
                Screen(visEnviro.screen.window,'FillRect',pacmanTaskSpecs.colorOpts.background); %clear screen
                DrawFormattedText(visEnviro.screen.window,pauseText,'center', 'center');
                trialData.paused = markEvent('taskPaused',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = false;
            elseif ~sessionVars.pauseFlag && ~needToDrawPauseText
                %draw objects on screen
                Screen(visEnviro.screen.window,'FillRect',pacmanTaskSpecs.colorOpts.background); %clear screen
                visualize_NPCs(visEnviro.screen.window, trialData.playerStartPosition, 0, trialData.playerColor, trialData.playerSize); %player
                for npc = 1:trialData.numNpcs
                    if trialData.npcType(npc) == 1 %prey
                        % Code insertion GK - Hide the NPC when needed
                        if has_delay && hideNpc && npc > 1; continue; end
                        % Code insertion GK end
                        visualize_NPCs(visEnviro.screen.window, trialData.startingPositions{npc},1, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
                    elseif trialData.npcType(npc) == -1 %predator
                        visualize_NPCs(visEnviro.screen.window, trialData.startingPositions{npc},pacmanTaskSpecs.gameOpts.predatorType, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
                    end
                end
                WaitSecs(0.001);
                trialData.resume = markEvent('taskResume',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = true;
            elseif sessionVars.recalibrate
                trialData.recalibrating = taskData.remarkEvent('recalibrateStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
                EyelinkDoTrackerSetup(eyeTrackerhHandle);
                trialData.doneCalibrating = markEvent('recalibrateEnd',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
                sessionVars.recalibrate = false;
            elseif sessionVars.quitTask
                break;%exits while loop, break does not?
            end
            
            %update time and index
            WaitSecs(0.001);%so doesn't loop too fast
            dataIndex = dataIndex + 1;
            
            if sessionVars.pauseFlag
                waitEventTime = 0; %while paused continually reset event time
            else
                waitEventTime = GetSecs() - trialData.waitStart; %update time since event start
            end
        end
        
        
        disp("Step 10")
        %---Chase Period---%
        %coded as choice period
        if pacmanOpts.debugMode
            disp('Chase Period Start')
            disp(['Wait duration was ' num2str(feedbackEventTime)])
        end
        
        disp("Step 10.1")
        trialData.choiceStart = markEvent('choiceStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        choiceEventTime = GetSecs() - trialData.choiceStart;%explicit call makes debuging much easier
        
        scoreModifier = 1; % GK addition

        while (choiceEventTime < pacmanOpts.timingParams.timeout) && isnan(trialData.choiceMade)
            disp("Step 10.2")
            %get joystick position
            if any(contains(pacmanOpts.cheaterMode.cheaterNames,pacmanOpts.fileParams.subjID))
                %check if subject is a cheater?, and if yes move input position to central cue location
                cheaterID = contains(pacmanOpts.cheaterMode.cheaterNames,pacmanOpts.fileParams.subjID);
                trialData.joystickPosition(:,dataIndex) = updatePacmanCheaterPosition(trialData.joystickPosition(1:2,dataIndex-1),...
                    trialData.npcPositionX(:,dataIndex-1),trialData.npcPositionY(:,dataIndex-1),...
                    pacmanOpts.joystickParams.sensitivity,trialData.npcValue,pacmanOpts.cheaterMode.cheaterNames{cheaterID});
            else
                trialData.joystickPosition(:,dataIndex) = updateJoystick(trialData.joystickPosition(1:2,dataIndex-1),...
                    pacmanOpts.joystickParams.sensitivity,pacmanTaskSpecs.sizeOpts.playerLimits,pacmanOpts.joystickParams.joystickThreshold,false,...
                    pacmanOpts.adjustSpeedByRes);
            end

            %Code insertion - GK determine whether the player has moved or not   
            if has_delay
                playerCenter = [trialData.joystickPosition(1,dataIndex)+playerWaitZone(3),...
                    trialData.joystickPosition(2,dataIndex)+playerWaitZone(3)];

                playerFromStart = sqrt((playerCenter(1) - playerWaitZone(1))^2 + (playerCenter(2) - playerWaitZone(2))^2);

                % if the distance traveled is less than the radius, delay the reveal
                if playerFromStart < playerWaitZone(3)
                    npcWaitStart = GetSecs();
                end
            end
            % Code insertion GK end

            disp("Step 10.3")
            %get eye position
            if pacmanOpts.eyeParams.eyeTrackerConnected
                trialData.eyeSamples(:,dataIndex) = sampleEye(pacmanOpts.eyeParams.eyeTracked);
            end
            
            disp("Step 10.4")
            %move npc(s)
            [trialData.npcPositionX(:,dataIndex),trialData.npcPositionY(:,dataIndex), trialData.choiceMade] = moveNPCs(...
                [trialData.npcPositionX(:,dataIndex-1),trialData.npcPositionY(:,dataIndex-1)],...
                trialData.npcPositionX(:,dataIndex-pacmanTaskSpecs.costOpts.momentumFrames:dataIndex-2),trialData.npcPositionY(:,dataIndex-pacmanTaskSpecs.costOpts.momentumFrames:dataIndex-2),...
                trialData.joystickPosition(:,dataIndex), trialData.npcVelocity, trialData.npcType,pacmanTaskSpecs, pacmanOpts.adjustSpeedByRes);
            
            % 01/04/2024
            % Code insertion GK - Determine whether or not the NPC needs to be hidden
            % If we are past the time for the Npc to be hidden, alert the code to disable the hiding     
            if has_delay
                if GetSecs() - npcWaitStart > trialData.NpcWaitTime && hideNpc
                    hideNpc = false;
                    trialData.npcHideEndFrame = dataIndex;
                    trialData.npcHideEndSecs = GetSecs() - trialData.choiceStart;
                end

                % If we still need to hide the NPC, and the player has collided with it, simply ignore
                if hideNpc && trialData.choiceMade > 1
                    trialData.choiceMade = NaN;
                end

                if ~isnan(trialData.choiceMade)
                    trialData.chaseEndSecs = GetSecs();
                    trialData.chaseEndFrame = dataIndex;
                end
            end
            % Code insertion GK end 

            disp("Step 10.5")
            disp(trialData.trialNum);
            %draw objects on screen
            Screen( 'FillRect', visEnviro.screen.window, pacmanTaskSpecs.colorOpts.zoneWall, pacmanTaskSpecs.sizeOpts.boundaries');
            visualize_NPCs(visEnviro.screen.window, trialData.joystickPosition(1:2,dataIndex-1), 0, trialData.playerColor, trialData.playerSize); %player
            for npc = 1:trialData.numNpcs
                if trialData.npcType(npc) == 1 %prey
                    % Code insertion GK - Hide the NPC when needed
                    if has_delay && hideNpc && npc > 1; continue; end
                    % Code insertion GK end
                    visualize_NPCs(visEnviro.screen.window, [trialData.npcPositionX(npc,dataIndex-1),trialData.npcPositionY(npc,dataIndex-1)],1, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
                elseif trialData.npcType(npc) == -1 %predator
                    visualize_NPCs(visEnviro.screen.window, [trialData.npcPositionX(npc,dataIndex-1),trialData.npcPositionY(npc,dataIndex-1)],pacmanTaskSpecs.gameOpts.predatorType, trialData.npcColors(npc,:), trialData.npcSize(npc,:));
                end
            end
            % GK code insertion
            disp("Step 10.5.5")
            timePercent = 1 - choiceEventTime/pacmanOpts.timingParams.timeout;
            if timePercent <= 0; timePercent = 0.002; end
            timeBarColor = [min(255*2*(1-timePercent),255),...
                            min(round(255*2*timePercent),255), 0];
            timeBarLength = visEnviro.screen.screenWidth * timePercent;
            timeRect = [0, 0, timeBarLength, pacmanTaskSpecs.sizeOpts.playerLimits(2,1)];
            Screen('FillRect', visEnviro.screen.window, timeBarColor, timeRect);
            % GK code insertion end

            disp("Step 10.6")
            %update visuals every frame &  update time and index
            WaitSecs(0.001);%so doesn't loop too fast
            disp("Step 10.6.1")
            %Screen(visEnviro.screen.window,'Flip');
            Screen('Flip',visEnviro.screen.window);
            disp("Step 10.6.2")
            choiceEventTime = GetSecs() - trialData.choiceStart; %update time since event start

            
            
            % if choiceEventTime < 5
            %     scoreModifier = 1;
            % else
            %     scoreModifier = 1 - choiceEventTime/pacmanOpts.timingParams.timeout;
            %     if scoreModifier < 0.05; scoreModifier = 0.05; end
            % end
            dataIndex = dataIndex + 1;
        end
        
        
        disp("Step 11")
        %---Choice2Feedback Period---%
        if pacmanOpts.timingParams.choice2feedbackDuration > 0 %skip if this value is zero
            trialData.choice2feedbackStart = markEvent('choice2FeedbackStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
            choice2feedbackEventTime = GetSecs() - trialData.choice2feedbackStart;%explicit call makes debuging much easier
            while choice2feedbackEventTime < pacmanOpts.timingParams.choice2feedbackDuration
                
                %get joystick position, this doesn't move the player, just
                %looking for post task movement of subject
                trialData.joystickPosition(:,dataIndex) = updateJoystick(trialData.joystickPosition(1:2,dataIndex-1),...
                    pacmanOpts.joystickParams.sensitivity,pacmanTaskSpecs.sizeOpts.playerLimits,pacmanOpts.joystickParams.joystickThreshold,false,...
                    pacmanOpts.adjustSpeedByRes);
                
                %get eye position
                if pacmanOpts.eyeParams.eyeTrackerConnected
                    % Get eye position
                    trialData.eyeSamples(:,dataIndex) = sampleEye(pacmanOpts.eyeParams.eyeTracked);
                end
                dataIndex = dataIndex + 1;
                
                WaitSecs(0.001);%so doesn't loop too fast
                choice2feedbackEventTime = GetSecs() - trialData.choice2feedbackStart; %update time since event start
            end
        end
        
        
        disp("Step 12")
        %---Feedback Period---%
        if pacmanOpts.debugMode
            disp('Feedback Period Start')
            disp(['Chase duration was ' num2str(choiceEventTime)])
        end
        
        %setup reward text, value, and sound
        if isnan(trialData.choiceMade)
            trialData.rewardValue = pacmanTaskSpecs.gameOpts.timeOutCost;
        else
            trialData.rewardValue = trialData.npcValue(trialData.choiceMade)*scoreModifier;
        end
        if  trialData.rewardValue >= 0.05
            trialData.rewarded = 1;
            rewardText = strcat(['Win! \n \n + ' round(num2str(trialData.rewardValue)*100)/100 ' points \n \n' ]);
            
            %fill buffer and then play audio
            PsychPortAudio('FillBuffer',visEnviro.soundParams.audioOutHandle,[visEnviro.soundParams.rwdSound; visEnviro.soundParams.rwdSound]);
            PsychPortAudio('Start', visEnviro.soundParams.audioOutHandle, 1, 0, 0);
            markEvent('reward',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        elseif trialData.rewardValue < 0
            trialData.rewarded = -1;
            rewardText = strcat(['Lose! \n \n ' num2str(trialData.rewardValue) ' points \n \n' ]);
            
            %fill buffer and then play audio
            PsychPortAudio('FillBuffer',visEnviro.soundParams.audioOutHandle,[visEnviro.soundParams.norwdSound; visEnviro.soundParams.norwdSound]);
            PsychPortAudio('Start', visEnviro.soundParams.audioOutHandle, 1, 0, 0);
            markEvent('unrewarded',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        else
            trialData.rewarded = 0;
            if trialData.rewardValue == 0
                rewardText = strcat(['Trial timed out \n \n' ]);
            else
                rewardText = strcat(['Trial timed out. Loose! \n \n - ' num2str(trialData.rewardValue) ' points \n \n' ]);
            end
            
            %fill buffer and then play audio
            PsychPortAudio('FillBuffer',visEnviro.soundParams.audioOutHandle,[visEnviro.soundParams.norwdSound; visEnviro.soundParams.norwdSound]);
            PsychPortAudio('Start', visEnviro.soundParams.audioOutHandle, 1, 0, 0);
            markEvent('unrewarded',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        end
        
        sessionVars.rewards = sessionVars.rewards+trialData.rewardValue;
        
        %draw feedback
        rewardText2 = strcat(rewardText,'Total: ',round(num2str(sessionVars.rewards)*100)/100);
        DrawFormattedText(visEnviro.screen.window,rewardText2 ,'center', 'center',pacmanTaskSpecs.colorOpts.white);
        trialData.feedbackStart = markEvent('feedbackStart',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,1);

        %do feedback period loop
        feedbackEventTime = GetSecs() - trialData.feedbackStart; %explicit call makdes debugging easier
        while feedbackEventTime < pacmanOpts.timingParams.feedbackTextDuration
            
            %get joystick position, this doesn't move the player, just
            %looking for post task movement of subject
            trialData.joystickPosition(:,dataIndex) = updateJoystick(trialData.joystickPosition(1:2,dataIndex-1),...
                pacmanOpts.joystickParams.sensitivity,pacmanTaskSpecs.sizeOpts.playerLimits,pacmanOpts.joystickParams.joystickThreshold,false,...
                pacmanOpts.adjustSpeedByRes);
            
            %get eye position
            if pacmanOpts.eyeParams.eyeTrackerConnected
                trialData.eyeSamples(:,dataIndex) = sampleEye(pacmanOpts.eyeParams.eyeTracked);
            end
            dataIndex = dataIndex + 1;
            
            %check for keyboard input
            [sessionVars.pauseFlag, sessionVars.quitTask, sessionVars.recalibrate, ~] = ...
                checkKeyBoardInput(pacmanOpts.KB,sessionVars.pauseFlag,sessionVars.quitTask,sessionVars.recalibrate);
            
            WaitSecs(0.001);%so doesn't loop too fast
            feedbackEventTime = GetSecs() - trialData.feedbackStart;
        end

        
        %---Save and Close Trial---%
        if pacmanOpts.debugMode
            disp('Trial End')
            disp(['Feedback duration was ' num2str(feedbackEventTime)])
            disp(' ') %to create new line
        end
        
        %stop any audio device from playing
        PsychPortAudio('Stop', visEnviro.soundParams.audioOutHandle, 0, 0);
        
        %remvoe excess NaNs
        if dataIndex < size(trialData.eyeSamples,2)
            trialData.eyeSamples(:,dataIndex:end) = [];
            trialData.joystickPosition(:,dataIndex:end) = [];
        end
        
        trialData.trialStop =  markEvent('trialEnd',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
        pacmanTaskSpecs = hpacman_closetrial(pacmanOpts,visEnviro,trialData,sessionVars,pacmanTaskSpecs);
        
        
        
    catch ME
        disp(ME)
        disp('Unable to complete a trial!....trying to save existing data');
        
        try  %to save data else close task
            hpacman_closetrial(pacmanOpts,visEnviro,trialData,sessionVars,pacmanTaskSpecs);
            closeTask(ttlStruct,visEnviro);
        catch ME2
            closeTask(ttlStruct,visEnviro);
            rethrow(ME2)
        end
    end
    
end


%---Close Out task---%
%save last trial data
if sessionVars.quitTask %means quit task, try to save data else close task
    trialData.quit = markEvent('taskQuit',NaN,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
    hpacman_closetrial(pacmanOpts,visEnviro,trialData,sessionVars,pacmanTaskSpecs);
elseif sessionVars.trialNum >= pacmanOpts.trialParams.ntrials
    markEvent('taskStop',0,ttlStruct,visEnviro.screen.window,pacmanOpts.eyeParams.eyeTrackerConnected,0);
    hpacman_closetrial(pacmanOpts,visEnviro,trialData,sessionVars,pacmanTaskSpecs);
end
% sessionVars
%save sessionVars just cuz it's nicer to
save([pacmanOpts.fileParams.dataDirectory pacmanOpts.fileParams.fileBaseName '_sessionVars.mat'],'sessionVars');

end

function [trialData] = pacmanInitiateTrial(pacmanOpts,pacmanTaskSpecs,sessionVars,visEnviro)
%does everything needed to initite each trial
%was hpacman_opentrial.m but turned into own subfunction by Seth Konig 2/17/2020

%---Initializes a new trial structure---%
disp("Step 2.1")
trialData = [];

trialData.trialNum = sessionVars.trialNum;
trialData.blockNum = sessionVars.blockNum;

% Significant Keyboard events
trialData.paused = NaN;
trialData.resume = NaN;
trialData.recalibrating = NaN;
trialData.doneCalibrating = NaN;
trialData.quit = NaN;

disp("Step 2.2")
% Trial timing vars
trialData.trialStart = NaN;   % start of the trial
trialData.itiStart = NaN; % start of ITI
trialData.itiEnd = NaN;   % end of ITI
trialData.waitStart = NaN;    % fixation point appearance/i.e. central cue
trialData.choiceStart = NaN;  %chase start
trialData.choice2feedbackStart = NaN; %choice to feebback start
trialData.feedbackStart = NaN;%feedback period start

disp("Step 2.2.1")
% Choice vars
trialData.choiceMade = NaN;   % prey/predator index, NaN if timedout
trialData.rewarded = NaN; %whether subject was rewarded or punished for trial, +/-1
trialData.rewardValue = NaN;%value of reward

disp("Step 2.2.2")
disp(pacmanOpts.timingParams.iti)
% Selected Event Durations
trialData.iti = pacmanOpts.timingParams.drawTime(pacmanOpts.timingParams.iti);
trialData.waitTime = pacmanOpts.timingParams.drawTime(pacmanOpts.timingParams.waitTime);

disp("Step 2.2.3")
% Create Sample Data arrays to speed up by pre-allocating space
trialData.joystickPosition = NaN(3,1500);%[X, Y, Ti time is last cuz works better with other code
trialData.npcPositionX = NaN(3,1500);%X position for up to 3 npc including prey/predatorme],
trialData.npcPositionY = NaN(3,1500);%Y position for up to 3 npc including prey/predator

disp("Step 2.2.4")
%player data
trialData.playerColor = pacmanTaskSpecs.colorOpts.player;
trialData.playerSize = [pacmanTaskSpecs.sizeOpts.playerWidth, pacmanTaskSpecs.sizeOpts.playerHeight];

disp("Step 2.2.5")
%npc data
trialData.npcColors = NaN(3,3);
trialData.npcType = NaN(1,3);
trialData.npcSize = NaN(3,2);
trialData.npcValue = NaN(1,3);
trialData.npcVelocity = NaN(1,3);
trialData.numNpcs = pacmanTaskSpecs.taskData.numNPCs(sessionVars.trialNum);
trialData.npcIndex = pacmanTaskSpecs.taskData.npcIndex(:,sessionVars.trialNum);

disp("Step 2.2.6")
for npc = 1:trialData.numNpcs
    if trialData.npcIndex(npc) > 0 %prey
        trialData.npcSize(npc,:) = [pacmanTaskSpecs.sizeOpts.preyWidth pacmanTaskSpecs.sizeOpts.preyHeight];
        trialData.npcColors(npc,:) = pacmanTaskSpecs.colorOpts.prey(trialData.npcIndex(npc),:);
        trialData.npcVelocity(npc) = pacmanTaskSpecs.gameOpts.preyVelocity(trialData.npcIndex(npc));
        trialData.npcValue(npc) = pacmanTaskSpecs.gameOpts.preyValue(trialData.npcIndex(npc));
        trialData.npcType(npc) = 1;
    else %predator
        trialData.npcSize(npc,:) = [pacmanTaskSpecs.sizeOpts.predatorWidth pacmanTaskSpecs.sizeOpts.predatorHeight];
        trialData.npcColors(npc,:) = pacmanTaskSpecs.colorOpts.predator(-trialData.npcIndex(npc),:);
        trialData.npcVelocity(npc) = pacmanTaskSpecs.gameOpts.predatorVelocity(-trialData.npcIndex(npc));
        trialData.npcValue(npc) = pacmanTaskSpecs.gameOpts.predatorValue(-trialData.npcIndex(npc));
        trialData.npcType(npc) = -1;
    end
end

disp("Step 2.3")
%get initial starting positiosn and do correction for shape to center them
trialData.startingPositions = pacmanTaskSpecs.taskData.startingPosition(:,sessionVars.trialNum);
for npc = 1:trialData.numNpcs
    if trialData.npcType(npc) == 1 %prey
        trialData.startingPositions{npc} = trialData.startingPositions{npc}' +...
            correctPosition4Shape(trialData.npcType(npc),trialData.npcSize(npc,:));
    elseif trialData.npcType(npc) == -1 %predator
        trialData.startingPositions{npc} = trialData.startingPositions{npc}' +...
            correctPosition4Shape(pacmanTaskSpecs.gameOpts.predatorType,trialData.npcSize(npc,:));
    end
end

trialData.playerStartPosition = [visEnviro.screen.origin(1) visEnviro.screen.origin(2)] + ...
    correctPosition4Shape(0,trialData.playerSize);

disp("Step 2.4")
%---Setup the Eye tracker for a new Trial---%
if pacmanOpts.eyeParams.eyeTrackerConnected
    trialData.eyeSamples = NaN(4,10000);%10 seconds of data, will clean up later
    
    closeLastTrialEyeTrackerFile(sessionVars.trialNum,pacmanOpts.fileParams);
    openNewTrialEyeTrackerFile(sessionVars.trialNum,pacmanOpts.fileParams.fileBaseName);
else
    trialData.eyeSamples = [];
end
end

function pacmanTaskSpecs = hpacman_closetrial(pacmanOpts,visEnviro,trialData,sessionVars,pacmanTaskSpecs)
%Seth Konig 2/18/2020 turned into own function
% Closes the trial and stores all the trial data
%simplified since pre-formatted data at opening of trial

if pacmanOpts.eyeParams.eyeTrackerConnected
    try
        r = Eyelink('RequestTime');
        if r == 0
            WaitSecs(0.1); %superstition
            beforeTime = GetSecs();
            trackerTime = Eyelink('ReadTime'); % in ms
            afterTime = GetSecs();
            
            pcTime = mean([beforeTime,afterTime]); % in s
            trialData.pcTime = pcTime;
            trialData.trackerTime = trackerTime;
            trialData.trackerOffset = pcTime - (trackerTime./1000);
            % would make legit time = (eyeTimestamp/1000)+offset
        end
    catch
        disp(['Unable to Request Eye Tracker Time on trial#' num2str(sessionVars.trialNum)])
    end
    
    %if last trial don't forget to move over file
    if sessionVars.trialNum == pacmanOpts.trialParams.ntrials || sessionVars.quitTask
        %must add 1 to trialNum since it's usually for the last trial
        closeLastTrialEyeTrackerFile(sessionVars.trialNum+1,pacmanOpts.fileParams);
    end
end

%save trial data
save([pacmanOpts.fileParams.dataDirectory pacmanOpts.fileParams.fileBaseName '_' num2str(sessionVars.trialNum) '.mat'],'trialData');

% Cleanup screen
Screen(visEnviro.screen.window,'FillRect', pacmanTaskSpecs.colorOpts.background);
Screen(visEnviro.screen.window,'Flip');
end