function createAndFlipPhotoDiodeRect(visEnviro,doFlip,forceColor)
%function creats and flips a black or white recetangle for use with a photodiode
%for tracking the timing of serious task events in addition to or as an alterative to
%TTLs.
%
% Inputs:
%   1) visEnviro: visual environment structure
%   2) doFlip (optional): whether to flip screen here or not. Most of the
%   time you should leave this to the behavior code.
%   3) forceColor (optional): force folor 1 for white, 0 for black
%
%written by Seth Koenig 2/28/22


%---Create Colors and Persistent Variables---%
%persitent variables
persistent lastColor
persistent photoRect

%color parameters for full white and full black
whiteColor = [255 255 255];
blackColor = [0 0 0];


%---Parse Inputs---%
%check inputs
if nargin == 3
    if forceColor
        lastColor = whiteColor;
    else
        lastColor = blackColor;
    end
end
if nargin < 2
    doFlip = false;
end

%create Persistent color
if isempty(lastColor)
    lastColor = blackColor;
end

%check if we even want to flash a square
if ~visEnviro.rig.usePhotoDiode
    return
end

%create a recetangle
if isempty(photoRect)
    photoRect = [0 0 visEnviro.rig.photoDiodeSize visEnviro.rig.photoDiodeSize];
    if visEnviro.rig.photoDiodeLocation == 1 %upper left
        photoRect = CenterRectOnPointd(photoRect,visEnviro.rig.photoDiodeSize/2,visEnviro.rig.photoDiodeSize/2);
    elseif visEnviro.rig.photoDiodeLocation == 2 %upper right
        photoRect = CenterRectOnPointd(photoRect,visEnviro.rig.resolution.width-visEnviro.rig.photoDiodeSize/2,visEnviro.rig.photoDiodeSize/2);
    elseif visEnviro.rig.photoDiodeLocation == 3 %lower left
        photoRect = CenterRectOnPointd(photoRect,visEnviro.rig.photoDiodeSize/2,visEnviro.rig.resolution.height-visEnviro.rig.photoDiodeSize/2);
    elseif visEnviro.rig.photoDiodeLocation == 4 %lower right
        photoRect = CenterRectOnPointd(photoRect,visEnviro.rig.resolution.width-visEnviro.rig.photoDiodeSize/2,visEnviro.rig.resolution.height-visEnviro.rig.photoDiodeSize/2);
    else
        error('need code here. Location not recognized')
    end
end


%---Draw PhotoDiode Rectangle---%
%draw/update rectangle
Screen(visEnviro.screen.window,'FillRect',lastColor,photoRect)

%update rectangle color so switches next time
if all(lastColor == whiteColor)
    lastColor = blackColor;
else
    lastColor = whiteColor;
end

%flip screen
if doFlip
    Screen(visEnviro.screen.window,'Flip');
end

end