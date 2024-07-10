function pixels = deg2px(degrees,screenSpecs)
% converts degrees of visual angle into pixel coordinates
%
% Inputs:
%   1) degrees: position in degrees of visual angle
%   2) screenSpecs: structure containing phsyical description of screen
%
% Outputs:
%   1) pixels: position in pixel coordinates

rads = deg2rad(degrees);

stimCm = tan(rads)*screenSpecs.distance;
convF = screenSpecs.width./screenSpecs.physicalWidth;
pixels = stimCm * convF;

end

function outputDegrees = deg2rad(inputRadians)
outputDegrees = inputRadians*(pi/180);
end