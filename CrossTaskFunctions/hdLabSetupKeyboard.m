function KB = hdLabSetupKeyboard()
% Setups up unified keyboard structure across tasks and OS's. 
% Switch KbName into unified mode: It will use the names of the OS-X
% platform on all platforms in order to make this script portable.
%
% Inputs:
%   none)
% 
% Outputs:
%   1) KB: structure containing keybaord mappings


KbName('UnifyKeyNames');

%keyboard keys
KB = [];
KB.space = KbName('SPACE');
KB.right = KbName('RightArrow');
KB.left = KbName('LeftArrow');
KB.up = KbName('UpArrow');
KB.down = KbName('DownArrow');
KB.shift = KbName('RightShift');
KB.onekey = KbName('1!');
KB.twokey = KbName('2@');
KB.threekey = KbName('3#');

%keys that modify the task
KB.pauseKey = KbName('p'); %pauses tasks
KB.unpauseKey = KbName('u'); %resumes task, don't want multiple press
KB.recalibrateKey = KbName('r');
KB.quitKey = KbName('Q');%don't use escape since calibration uses this

end