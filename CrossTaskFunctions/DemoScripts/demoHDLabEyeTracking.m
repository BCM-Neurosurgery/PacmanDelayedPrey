%demonstration script showing how to use the EyeLink eye tracker
%written by Seth Konig 2/10/2020
subjID = '999';
saveEyeData = true;
recordTime = 100;%in seconds
startDir = pwd;

%% Setup Pscyh Toolbox
PsychDefaultSetup(1);
screenNumber=max(Screen('Screens'));
[screenWindow, wRect]=Screen('OpenWindow',screenNumber);
Screen('Preferences','DebugMakeTexture',0)
backgroundcolor=GrayIndex(screenWindow); % returns as default the mean gray value of screen

%initiate keyboard short cuts
KB = hdLabSetupKeyoard();

%% Connect to Eye Tracker
[eyeTrackerhHandle,edfFileName,eyeTracked] = setupHDLabEyeLink(screenWindow,saveEyeData,subjID);

%% Draw Fixation Point

fixSize = 50;
screenCenter = [wRect(3)/2 wRect(4)/2];
fixRect = [0 0 fixSize fixSize];
fixRect2 = CenterRectOnPoint(fixRect, screenCenter(1), screenCenter(2));


% Draw on Screen
Screen(screenWindow,'FillRect',255/2); %clear screen
Screen(screenWindow,'FillRect',[255 255 255],fixRect2)
Screen('Flip', screenWindow);

%% Draw on EyeLink
%Draw Fixation Window on EyeLink, must switch to "plot view" for this to work!
Eyelink('command', 'clear_screen %d', 0);
WaitSecs(0.002)
Eyelink('command', 'draw_cross %d %d 15',  screenCenter(1), screenCenter(2));
drawFixWindow(screenCenter, fixSize*2, 15,false) %draw fixation window

%% Get and Plot Eye Tracker Data

%estimate number of samples
numSamples = recordTime*1000; %sampled at 1000 Hz!

%time,x,y, & p by row
eyeSamples = NaN(4,numSamples);%10 seconds of data, will clean up later


%---Run Time loop to grab gaze data---%
dataIndex = 1;
timeStart = GetSecs();
eventTime = GetSecs()-timeStart;
while eventTime < recordTime
    
    % check keyboard/response pad input
    [keyIsDown, ~, keyCode] = KbCheck();
    
    %since self paced, need option of quitting mid decision
    if keyIsDown && keyCode(KB.quitKey)
        break;%exits while loop
    end
    
    %get new eye data samples
    eyeSamples(:,dataIndex) = sampleEye(eyeTracked);
    
    %update time and index
    WaitSecs(0.001);%so doesn't loop too fast
    dataIndex = dataIndex + 1;
    
    %check event time
    eventTime = GetSecs()-timeStart;
end

%% Close Pyschtoolbox Window
sca

%%  Plot Eye data

eyeTime = eyeSamples(1,:);
eyeTime = eyeTime-eyeTime(1); %subtract baseline timestamp
eyeTime = eyeTime/1e3; %convert from ms to seconds

figure
subplot(2,1,1)
plot(eyeTime,eyeSamples(2,:))
hold on
plot(eyeTime,eyeSamples(3,:))
hold off
xlabel('Time (sec)')
ylabel('Screen Location')
legend('X','Y')
ylim([-200 2000])
    
subplot(2,1,2)
plot(eyeTime,eyeSamples(4,:))
xlabel('Time (sec)')
ylabel('Pupil Area')

%% Shuttdown EyeLink and PsychToolbox
Eyelink('StopRecording');
Eyelink('closefile');
copyFileStatus = Eyelink('ReceiveFile',edfFileName,startDir, 1);%transfer file to current directory+
Eyelink('Shutdown');