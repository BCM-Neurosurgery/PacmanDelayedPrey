function [isPaused, quitTask, recalibrate, inputTime] = checkKeyBoardInput(kBShortCuts,wasPaused, wasQuit, wasRecalibrated)
%function processes user keyboard input and allows for pausing (when task)
%appropriate i.e. during ITI), calibration, and task quitting.
%
%based on esc_check, but made more generalizable and removed globals
%Seth Konig 2/20/20
% 
% Inputs: 
%   1) kBShortCuts: structure containing keyboard mappings
%   2) wasPaused: true/false flag for whether task was already [flagged for] paused
%   3) wasQuit: true/false flag for whether task was already [flagged for] quitting
%   3) wasRecalibrated: true/false flag for whether task was already [flagged for] recalibrating
%
% Outputs:
%   1) isPaused: true/false flag determining if task will be paused
%   2) quitTask: true/false flag determining if task will be quit
%   3) recalibrate: true/false flag determining if eyes will be recalibrated
%   4) inputTime: time of key press

%default to what already was set, update only if new key pressed
isPaused = wasPaused; %need to return old value in case was puased
quitTask = wasQuit; %don't quit if no keyboard input
recalibrate = wasRecalibrated; %don't recalibrate if no keyboard input


[keyIsDown, inputTime, keyCode] = KbCheck();
if keyIsDown %if key was pressed
    if keyCode(kBShortCuts.quitKey)
        quitTask = true;
        
        if ~wasQuit
            disp('Escape key pressed, quitting task!')
        end
    elseif keyCode(kBShortCuts.unpauseKey)
        if wasPaused %if already paused resume task
            isPaused = false;
            disp('Pause key pressed, resuming task!')
        end
    elseif keyCode(kBShortCuts.pauseKey)
        if ~wasPaused
            isPaused = true;
            disp('Pause key pressed, passing task at next convienence!')
        end
    elseif keyCode(kBShortCuts.recalibrateKey)
        recalibrate = true;
        disp('Recalibration key pressed, recalibrating at next convience!')
    end
end

end