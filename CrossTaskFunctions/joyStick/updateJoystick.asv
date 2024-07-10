function newPos = updateJoystick(prevPos,xySensitivity,xyLimits,joystickThreshold,debugFlag, speedAdjust)
%modified slighlty to to be more generalizable and got rid of globals. Based on
%update_joystick_pacman. Written by Seth Koenig 5/14/202
%
% Inputs: 
%   1) prevPos: horizontal (x), vertical (y), and time value of previous joystick position
%   2) xySensitivity: movement sensitivity for horizontal (x) and vertical (y) position
%   3) xyLimits: minimum/maximum horizontal (x) and vertical (y) positions allowable
%   4) joystickThreshold: miniumum joystick movement necessary to result in
%   movement to avoid drift and other artifacts caused by joystick stickiness
%   5) debugFlag: if true prints out joystick movement information
%   6) speedAdjust: The adjustment for the speed we need
%
% Outputs:
%   1) newPos: horizontal (x), vertical (y), and time value of new joystick position

if nargin < 4
    debugFlag = false;
end

% If we don't have speed Adjusting, then make it 1
if ~exist("speedAdjust", "var"); speedAdjust = [1,1]; end

%---Get joystick input---%
joystick = jst;
if debugFlag
    disp(['Xraw: ' num2str(joystick(2)) ', yRaw: ' num2str(joystick(1))])
end

%---Amplify movement by sensitivity---%
%don't amplitfy small movements
joystick(abs(joystick) < joystickThreshold) = 0;
xChange = joystick(2) .* xySensitivity;
yChange = -joystick(1) .* xySensitivity; %invert


%---update new joystick position---%
newPos(1) = floor( prevPos(1) + xChange * speedAdjust(1));
newPos(2) = floor( prevPos(2) - yChange * speedAdjust(2)); %y-axis is by default inverted
newPos(3) = GetSecs();%add time

%---Make sure new position is still within the limits of the screen---%
% X-coordinate control
if newPos(1) < xyLimits(1,1)
    newPos(1) = xyLimits(1,1);
elseif newPos(1) > xyLimits(1,2)
    newPos(1) = xyLimits(1,2);
end

% Y-coordinate control
if newPos(2) < xyLimits(2,1)
    newPos(2) = xyLimits(2,1);
elseif newPos(2) > xyLimits(2,2)
    newPos(2) = xyLimits(2,2);
end


if debugFlag
    disp(['XNew: ' num2str(newPos(2)) ', yNew: ' num2str(newPos(1))])
end

end