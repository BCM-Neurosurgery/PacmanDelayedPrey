%Demo shows how to draw and justify text. It also demos how to draw simple
%shapes justified with the text.
%
% Written by Seth Konig 9/10/20 based on various demo scripts

% Clear the workspace and the screen
close all;
clearvars;
sca

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

%Set Text Font Size and Type
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Arial');


% Draw text in the middle of the screen in white
DrawFormattedText(window, 'Centered Text', 'center', 'center', white);


%Draw Dot in "corners"
dotSizePix = 20;
x1 = screenXpixels*0.25;
x2 = screenXpixels*0.75;
y1 = screenYpixels*0.25;
y2 = screenYpixels*0.75;

Screen('DrawDots', window, [x1 y1], dotSizePix, [1,0,0], [], 2);
Screen('DrawDots', window, [x2 y1], dotSizePix, [1,0,0], [], 2);
Screen('DrawDots', window, [x1 y2], dotSizePix, [1,0,0], [], 2);
Screen('DrawDots', window, [x2 y2], dotSizePix, [1,0,0], [], 2);


%Draw Open Squares around Dots
squareSize = 100;
r0 = [0 0 squareSize squareSize];
r1 = CenterRectOnPointd(r0, x1, y1);
r2 = CenterRectOnPointd(r0, x1, y2);
r3 = CenterRectOnPointd(r0, x2, y1);
r4 = CenterRectOnPointd(r0, x2, y2);

Screen('FrameRect',window, [0 1, 0], r1, 3);
Screen('FrameRect',window, [0, 1, 0], r2, 3);
Screen('FrameRect',window, [0 1, 0], r3, 3);
Screen('FrameRect',window, [0, 1, 0], r4, 3);


%Draw text at top of screen
Screen('DrawText', window, 'Top-Left aligned, max 60 chars wide, justified.', 0, 0, [255, 0, 0, 255]);


%Draw Uncentered Positional Text
value4String1 = 13;
DrawFormattedText(window, [num2str(value4String1,'%0.2f') ' is not Centered!'],x1,y1);


%draw first ime with mostly empty positions
myFirstText = 'This is mirroed text!';
DrawFormattedText(window, myFirstText, x2, y1, [1,0,0], [], [], [], [], 1, []);

% aligning of text to a box using DrawFormattedText2, which can be slow?
[scrX,scrY] = RectCenter(r2);
textString = 'Text centered\ninside a rect!';
DrawFormattedText2(textString,'win',window,'sx','center','sy','center','xalign','center','yalign','center','xlayout','center','winRect',r2,'baseColor',[0 0 255]);

%align text using DrawFormamtedText which should be faster
mytextJustified = 'This is max justified text!';
DrawFormattedText(window, mytextJustified, 'justifytomax', 40, 0, [], [], [], [], [], r3);

%draw one more time but with full DrawFormmatedTextOptions
myLastText = 'This is also\ncentered text!';
DrawFormattedText(window, myLastText, 'center', 'center', [1 1 1], [], [], [], [], 0, r4);

    
% Flip to the screen
Screen('Flip', window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
KbStrokeWait;

% Clear the screen
sca;