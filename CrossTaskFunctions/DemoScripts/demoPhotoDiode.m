function [screenFlipTimes,screenFlipTimes2] = demoPhotoDiode()
%Demo function shows how to test photodiode timing

%% Setup Screen & TTL
visEnviro = hdLabSetupScreen();
WaitSecs(0.5)
ttlStruct = hdLabSetupTTLDevice(visEnviro.rig);
HideCursor();

%% Generate Full Black/White Images & Setup image Parameters

%timing parameters
numReps = 100;
imageTime = [0.5 1.5];%seconds
drawTime = @(x) min(x) + (range(x) .* rand(1,1));

%black and white image
blackImage = zeros(visEnviro.screen.screenHeight,visEnviro.screen.screenWidth,3);
whiteImage = 255*ones(visEnviro.screen.screenHeight,visEnviro.screen.screenWidth,3);

blackTexture = Screen('MakeTexture',visEnviro.screen.window,blackImage);
whiteTexture = Screen('MakeTexture',visEnviro.screen.window,whiteImage);

%box to draw as black and white
pixelSize = 200;
photoDiodeBox = CenterRectOnPointd([0 0 pixelSize pixelSize], visEnviro.screen.screenWidth-pixelSize/2, visEnviro.screen.screenHeight-pixelSize/2);


%% Start with Gray generic background
WaitSecs(1);
Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
DrawFormattedText(visEnviro.screen.window, 'Will now begin Full Screen Test!', 'center', 'center');
markEvent('taskStart',NaN,ttlStruct,visEnviro.screen.window,0,0);
Screen(visEnviro.screen.window,'Flip');
WaitSecs(2);

%% Show Full Screen Test

blackDur = NaN(1,numReps);
whiteDur = NaN(1,numReps);
screenFlipTimes = NaN(2,numReps);
for rep = 1:numReps
    %draw black
    blackDur(rep) = drawTime(imageTime);
    Screen('DrawTexture', visEnviro.screen.window, blackTexture);
    screenFlipTimes(1,rep) = markEvent('trialStart',NaN,ttlStruct,visEnviro.screen.window,0,1);
    WaitSecs(blackDur(rep));
    
    %draw white
    whiteDur(rep) = drawTime(imageTime);
    Screen('DrawTexture', visEnviro.screen.window, whiteTexture);
    screenFlipTimes(2,rep) = markEvent('itiStart',NaN,ttlStruct,visEnviro.screen.window,0,1);
    WaitSecs(whiteDur(rep));
end

%% Return to Gray generic background
WaitSecs(1);
Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
DrawFormattedText(visEnviro.screen.window, 'Will now begin Square Test!', 'center', 'center');
Screen(visEnviro.screen.window,'Flip');
WaitSecs(1);

%% Show Small Squares
blackDur2 = NaN(1,numReps);
whiteDur2 = NaN(1,numReps);
screenFlipTimes2 = NaN(2,numReps);
for rep = 1:numReps
    %draw black
    blackDur2(rep) = drawTime(imageTime);
    Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
    Screen('FillRect',visEnviro.screen.window, 0, photoDiodeBox, 1); %draw small black box
    screenFlipTimes2(1,rep) = markEvent('choiceStart',NaN,ttlStruct,visEnviro.screen.window,0,1);
    WaitSecs(blackDur2(rep));
    
    %draw white
    whiteDur2(rep) = drawTime(imageTime);
    Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
    Screen('FillRect',visEnviro.screen.window, 255, photoDiodeBox, 1); %draw small black box
    screenFlipTimes2(2,rep) = markEvent('feedBackStart',NaN,ttlStruct,visEnviro.screen.window,0,1);
    WaitSecs(whiteDur2(rep));
end

%%
%---Close Everything Out---%
Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
Screen(visEnviro.screen.window,'Flip');

WaitSecs(0.5);
markEvent('taskEnd',NaN,ttlStruct,visEnviro.screen.window,0,0);
closeTask(ttlStruct);


end