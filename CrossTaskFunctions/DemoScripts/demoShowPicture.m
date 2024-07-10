%Demo script shows how to display an image in PsychToolbox
%% Setup Pscyh Toolbox
PsychDefaultSetup(1);
screenNumber=max(Screen('Screens'));
[screenWindow, wRect]=Screen('OpenWindow',screenNumber);
Screen('Preferences','DebugMakeTexture',0)
backgroundcolor=GrayIndex(screenWindow); % returns as default the mean gray value of screen

%% Show A picture in Native Size
aPicture = imread('ngc6543a.jpg'); %from matlab stock
pictureTexture = Screen('MakeTexture',screenWindow,aPicture);
Screen('DrawTexture', screenWindow, pictureTexture);
Screen('Flip',screenWindow)
WaitSecs(5);

%---Then close screen---%
sca