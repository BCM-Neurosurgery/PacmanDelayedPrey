function newPos = updatePacmanCheaterPosition(prevPos,npcPositionsX,npcPositionsY,xySensitivity,npcValues,cheaterID);
%function moves player automatically torwards an NPC of a certain value
%written by Seth Konig 5/22/20

if strcmpi(cheaterID,'Cheater')
    %always move torwards highest rewarded prey
    [~,npcTarget] = max(npcValues);
elseif strcmpi(cheaterID,'Naive')
    %always move torwards first stimulus regardless of value
    npcTarget = 1;
elseif strcmpi(cheaterID,'Troll')
    %move torward prey or if no prey move torwards lowest valued reward prey
    [~,npcTarget] = min(npcValues);
else
    error('Cheater name not recognized')
end

%---Get Vector between npc target and player---%
player2NPCVector = [npcPositionsX(npcTarget)-prevPos(1) npcPositionsY(npcTarget)-prevPos(2)];
player2NPCVector(2) = -player2NPCVector(2);
player2NPCVector = xySensitivity*player2NPCVector/norm(player2NPCVector);


%---update new joystick position---%
newPos(1) = floor( prevPos(1) + player2NPCVector(1));
newPos(2) = floor( prevPos(2) - player2NPCVector(2)); %y-axis is by default inverted
newPos(3) = GetSecs();%add time

end