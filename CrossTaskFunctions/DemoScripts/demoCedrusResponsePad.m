%Demo script shows you how to use Cedrus Rb-740 response pad.
%This demo is loosely based on demo from Psychtoolbox called CedrusResponseBoxTest
%but their demo doesn't work so created own veresion.
%See http://psychtoolbox.org/docs/CedrusResponseBox for function list.
%written by Seth Konig 6/16/20

clear, clc, close all

%---Important Settings---%
numDesiredPresses = 10; %number of desired presses 
maxRunTime = 60;%in seconds maximum time program will run for
cedrusPort = 'COM3';%look at device manager for listing of ports


%---Setup Cedrus Device--%
fprintf('\n\nThe following (Cedrus serial cedrusPort) device will be used for testing: %s\n\n', cedrusPort);

% Try to open and init the box, return handle 'h' to it:
try
    hCedrus = CedrusResponseBox('Open', cedrusPort);
    devinfo = CedrusResponseBox('GetDeviceInfo',hCedrus);
catch
    error('was not able to open port')
end

% Diplay detected device info:
fprintf('Device info from box:\n\n');
fprintf('Device name and vendor: %s.\n\n', devinfo.Name);

% Flush the box for a start: do on start of every new trial
status = CedrusResponseBox('FlushEvents', hCedrus); %‘status’, which will return the current status of all buttons
if ~all(status(:) == 0)
    error('Why are some keys pressed?')
end

%set current mode to ReflectiveSinglePulse, only triggers when key is pressed but not release
CedrusResponseBox('SetConnectorMode', hCedrus, 'ReflectiveSinglePulse');
WaitSecs(1);


%---Run Loop to Get Key Pad Presses---%
fprintf('You may now begin pressing Buttons!');
runTimeStart = GetSecs();
numPadPresses = 0;
cedrusPsychRTDiff = NaN(1,numPadPresses); %track timing difference between cedrus and psycthoolbox
while numPadPresses < numDesiredPresses && GetSecs()-runTimeStart < maxRunTime
    %---Clear Any Remaning Info---%
    preFlushTime = GetSecs();
    CedrusResponseBox('FlushEvents', hCedrus);
    postFlushTime = GetSecs();
    fprintf('\n\nFlushing took: %0.3f seconds\n\n', postFlushTime-preFlushTime);
    
    % Ok start of pseudo-trial: Reset box reaction time timer. 'basetime'
    % is our best GetSecs estimate of when timer started with value zero:
    basetime = CedrusResponseBox('ResetRTTimer', hCedrus);
    loopStart = GetSecs();
    
    % Wait for the box to return an event:
    keyNotPressed = true;
    while keyNotPressed 
        % evt = CedrusResponseBox('WaitButtonPress', h);
        evt = CedrusResponseBox('GetButtons', hCedrus);
        if ~isempty(evt) && evt.action == 1 %key pressed
            keyPressedTime = GetSecs();
            keyNotPressed = false;
            numPadPresses = numPadPresses+1;
            cedrusPsychRTDiff(numPadPresses) = evt.rawtime-(keyPressedTime-loopStart);
            
            %display event info
            fprintf('\n\nKeypress #%d:\n', numPadPresses);
            fprintf('\tButton #%d\n', evt.button);
            fprintf('\tRT from Cedrus: %.3f, RT from Psychtoolbox, %0.3f\n', evt.rawtime,keyPressedTime-loopStart);
            fprintf('\tRT from Cedrus-Psychtoolbox RT: %.3f', cedrusPsychRTDiff(numPadPresses));
        elseif ~isempty(evt) && evt.action == 0 %key released
            error('Registered key being released')
        end
        WaitSecs(0.001);
    end
    
    %to keep from pressing too quickly
    WaitSecs(1);
end


%---Close out everything---%
CedrusResponseBox('Close', hCedrus);%alternatively CedrusResponseBox('CloseAll');
fprintf('\n\nAverage Cedrus/PsychToolbox Timing Difference: %0.3f',nanmean(cedrusPsychRTDiff));
fprintf('\n\nTest finished, bye!\n\n');