function visualize_NPCs(screenWindow, position, objectType, color, objectSize)
% Draw all npc instances to the screen.
% This will need to include a switch
% that changes color coding for different instances.
%
% modified from original by Seth Konig 5/15/2020 to remove globals.
% 5/16/2020 fixed bug where object size was twice what it should be because
% adding and subtracting

%parse inputs
X_coord = position(1);
Y_coord = position(2);

objectWidth = objectSize(1);
objectHeight = objectSize(2);

%Draw Objects
if objectType == 0 % player: circle
    zone = [ X_coord, Y_coord, X_coord + objectWidth, Y_coord + objectHeight];
    Screen('FillOval', screenWindow, color, zone);
elseif objectType == 1   % Draw Prey: square
    zone = [ X_coord, Y_coord, X_coord + objectWidth, Y_coord + objectHeight];
    Screen( 'FillRect' , screenWindow, color, zone );
elseif objectType == -1% Draw Predator: triangle
    zone = [ X_coord,  Y_coord; ...
        X_coord + objectWidth, Y_coord ; ...
        X_coord + objectWidth/2 , Y_coord - objectHeight ];
    Screen( 'FillPoly', screenWindow, color, zone, 1 ); %true is for isConvex
elseif objectType == -2 %Draw predator, hexagon
    zone = [cosd(0), sind(0); ...
        cosd(60), sind(60); ...
        cosd(120), sind(120);...
        cosd(180), sind(180);...
        cosd(240), sind(240);...
        cosd(300), sind(300)];
    zone =  zone*objectWidth/2;
    zone(:,1) = zone(:,1) + X_coord;
    zone(:,2) = zone(:,2) + Y_coord;
    Screen( 'FillPoly', screenWindow, color, zone, 1 ); %true is for isConvex
else
    error('object type not recognized')
end

end