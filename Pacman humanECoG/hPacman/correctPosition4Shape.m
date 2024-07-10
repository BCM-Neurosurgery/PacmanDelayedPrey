function correction = correctPosition4Shape(objectType,objectSize)
%function corrects position to center stimlus because shape positions are
%not centered already they depend on verticies instead.
%
% Written by Seth Konig 5/16/2020


objectWidth = objectSize(1);
objectHeight = objectSize(2);

if objectWidth ~= objectHeight
    error('These should be identical, otherwise need to write new code!')
end

if objectType == 0 %player, circle
    %lower left corner is origin in rect
    correction = -[objectWidth/2 objectHeight/2];
elseif objectType == 1   %prey, square
    %lower left corner is origin in rect
    correction = -[objectWidth/2 objectHeight/2];
elseif objectType == -1% predator, triangle
    correction = [-objectWidth/2 objectHeight/2];
elseif objectType == -2 %predator, hexagon
    correction = [0 0];
else
    error('object type not recognized')
end

end