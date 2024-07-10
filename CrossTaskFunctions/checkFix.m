function fixed = checkFix(Testing, inputPosition, objectPosition, tolerance, key)
% checkFix.m
% Checks if fixation, ohter input such as mouse, or key press (TESTING only)
% moved inside fixation window defined by tolerance parameter. 
% updated by Seth Konig 2/18/20; removed globals and made a few other
% changes
%
% Inputs: 
%   1) Testing: flag for keyboard input for testing without input device
%   2) inputPosition: gaze/mouse position of input device 
%   3) objectPosition: desired fixation location of item
%   4) tolerance: fixation window size
%   5) key: keyboard input key for testing mode
% 
% Output:
%   1) fixed: true/false value if objectPosition was fixated

fixed = false;

if Testing
    
    [keyIsDown,~,keyCode] = KbCheck;
    
    % Key pressed -> fixation acquired
    if keyIsDown && keyCode(key)
        fixed = true;
    else
        fixed = false;
    end
    
else %use mouse/eye tracker input
    if (abs(inputPosition(1)-objectPosition(1)) < tolerance && abs(inputPosition(2)-objectPosition(2)) < tolerance)
        fixed = true;
    else
        fixed = false;
    end
end

end