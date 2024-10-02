function [pacmanTaskSpecs, pacmanOpts] = pacmanSetupStimuli(pacmanOpts,visEnviro)
    % Initializes the prey and predator reward contingencies used throughout the task
    % as well as determines some color settings since these are also very important.
    %
    % written by Seth Konig 5/14/2020

    % Create placeholders for future use
    pacmanOpts.npcTimeTableSpecs = NaN;
    pacmanOpts.npcTimeTableOriginal = NaN;      % GK code insertion
    pacmanOpts.npcTimeTableRandomized = NaN;    % GK code insertion

    %---Determine reward value and speed of prey and predators---%
    gameOpts = struct();
    if strcmpi(pacmanOpts.trialParams.rewardStructType,'originalRandom')
        %speed and value are correlated 1:1
        gameOpts.preyValue = [ 2, 4, 6, 8, 10 ]*0.5;
        gameOpts.predatorValue	= -[ 2, 4, 6, 8, 10 ]*0.5;
        gameOpts.preyVelocity = [6:10]*0.5;
        gameOpts.predatorVelocity = gameOpts.preyVelocity*0.35;
        gameOpts.predatorType = -1; %triangle
        gameOpts.timeOutCost = 0;
    elseif strcmpi(pacmanOpts.trialParams.rewardStructType,'newBalanced')
        %speed and value or anti-correlated and intersect with predator, predator has only 1 value and speed to simplify analysis
        gameOpts.preyValue = [ 2, 2, 6, 10, 10 ]*0.5;
        gameOpts.predatorValue	= -6*0.5;
        gameOpts.preyVelocity = [ 2, 6, 6, 6, 10 ]*0.5;
        gameOpts.predatorVelocity = -gameOpts.predatorValue;
        gameOpts.predatorType = -2; %hexagon
        gameOpts.timeOutCost = gameOpts.predatorValue; %equal to predator value
        % Code insertion GK
    elseif contains(pacmanOpts.trialParams.rewardStructType,'50plusDelay')
        %speed and value are correlated 1:1
        gameOpts.preyValue = [ 2, 4, 6, 8, 10 ]*0.5;
        gameOpts.predatorValue	= -[ 2, 4, 6, 8, 10 ]*0.5;
        gameOpts.preyVelocity = (5:9)*0.5*0.9;
        gameOpts.predatorVelocity = gameOpts.preyVelocity*0.35;
        gameOpts.predatorType = -1; %triangle
        gameOpts.timeOutCost = 0;
        % Code insertion GK end
    else
        error('Reward structure type not recognized')
    end

    %scale with parameters so can make easier and harder for some people
    gameOpts.preyVelocity = gameOpts.preyVelocity*pacmanOpts.chase.preySpeedFactor;
    gameOpts.predatorVelocity = gameOpts.predatorVelocity*pacmanOpts.chase.predatorSpeedFactor;


    %---Color Options---%
    colorOpts = struct();

    % Define white, black, and grey
    colorOpts.white = [255, 255, 255];
    colorOpts.black = [0, 0, 0];
    colorOpts.grey  = colorOpts.white/2;
    colorOpts.time_bar = colorOpts.white;

    colorOpts.background = [ 50, 50, 50 ];
    colorOpts.zoneWall	 = colorOpts.black; % wall color

    if strcmpi(pacmanOpts.trialParams.rewardStructType,'originalRandom')
        colorOpts.player	 = [0.5, 0.5, 0.225]*255;
        colorOpts.predator	 = [ 255, 125, 0;  0, 0, 255; 0, 255, 0; 255, 0, 255; 0, 255, 255 ]; % Remove Yellow
        colorOpts.prey		 = [ 255, 125, 0;  0, 0, 255; 0, 255, 0; 255, 0, 255; 0, 255, 255 ]; % Remove Yellow
    elseif strcmpi(pacmanOpts.trialParams.rewardStructType,'newBalanced')
        %~isoluminent w/average luminance around 67.6 above so trying to match
        colorOpts.player	 = [165 165 165];
        colorOpts.prey		 = [255 111 105; 163 148 255; 196 162 7; 0 187 255; 75 187 78];
        colorOpts.predator	 = [196 162 7];
        % Code insertion GK
    elseif contains(pacmanOpts.trialParams.rewardStructType,'50plusDelay')
        colorOpts.player	 = [0.5, 0.5, 0.225]*255;
        colorOpts.predator	 = [ 255, 125, 0;  0, 0, 255; 0, 255, 0; 255, 0, 255; 0, 255, 255 ];
        colorOpts.prey		 = [ 255, 125, 0;  0, 0, 255; 0, 255, 0; 255, 0, 255; 0, 255, 255 ];
        % Code insertion GK end
    else
        error('Reward structure type not recognized')
    end


    %---Size/Shape Options---%
    %want all to be the same area if we can
    sizeOpts = struct();
    player2NPCScaleFactor = 1.0; %size ratio of player to prey/predator, default is 1.0

    %circles
    sizeOpts.playerWidth = 30*2;%was previoulsy doubling this size during visualization so fixing it here
    sizeOpts.playerHeight = sizeOpts.playerWidth;

    %squares
    sizeOpts.preyWidth = ceil(sizeOpts.playerWidth*pi/4*player2NPCScaleFactor);
    sizeOpts.preyHeight = sizeOpts.preyWidth;

    %polygons
    if gameOpts.predatorType == -1 %triangle
        %not equal in area
        sizeOpts.predatorWidth = sizeOpts.preyWidth;
        sizeOpts.predatorHeight = sizeOpts.preyHeight;
    elseif gameOpts.predatorType == -2 %hexagon
        %equal in area
        sizeOpts.predatorWidth = ceil(sizeOpts.playerWidth/(3*sqrt(3)/2/pi))*player2NPCScaleFactor;
        sizeOpts.predatorHeight = sizeOpts.predatorWidth;
    else
        error('predator shape not recognized!')
    end


    %just assume objects are circles/encompassed by circles and life is so much easier
    %it may not work for all options 100% perfectly but works 99% the time
    sizeOpts.collission.collisionRadiusFactor = pacmanOpts.chase.collisionRadiusFactor;
    sizeOpts.collisionRadius = (sizeOpts.playerWidth/2 + sizeOpts.preyWidth/2*sqrt(2))*pacmanOpts.chase.collisionRadiusFactor;

    % Define borders/walls
    sizeOpts.wallThickness = 10; % Wall thickness
    % Basic Arena Configuration
    sizeOpts.northWall = [ visEnviro.screen.windowRect(1), visEnviro.screen.windowRect(2), visEnviro.screen.windowRect(3), visEnviro.screen.windowRect(2) + sizeOpts.wallThickness  ];
    sizeOpts.southWall = [ visEnviro.screen.windowRect(1), visEnviro.screen.windowRect(4) - sizeOpts.wallThickness , visEnviro.screen.windowRect(3), visEnviro.screen.windowRect(4) ];
    sizeOpts.westWall = [ visEnviro.screen.windowRect(1), visEnviro.screen.windowRect(2), visEnviro.screen.windowRect(1) + sizeOpts.wallThickness , visEnviro.screen.windowRect(4) ];
    sizeOpts.eastWall = [ visEnviro.screen.windowRect(3) - sizeOpts.wallThickness , visEnviro.screen.windowRect(2), visEnviro.screen.windowRect(3), visEnviro.screen.windowRect(4) ];

    % storing all the walls above in one array for easier drawing
    sizeOpts.boundaries = [ sizeOpts.northWall; sizeOpts.southWall; sizeOpts.eastWall; sizeOpts.westWall];
    limitExtension = sizeOpts.wallThickness+sizeOpts.playerWidth; %player width plus wall size
    sizeOpts.playerLimits = [sizeOpts.wallThickness,  visEnviro.screen.screenWidth - limitExtension;...
        sizeOpts.wallThickness,  visEnviro.screen.screenHeight - limitExtension];


    %---Define Positional Cost Grid---%
    costOpts.costWall = 6;    % Factor to avoid the edge and corner, 2x stronger than center
    costOpts.costPositionMax = 3; %relative weigthing of position

    % Cost grid part 1. considering the corner factor
    wallCostGrid = zeros(  visEnviro.screen.screenHeight, visEnviro.screen.screenWidth ); %wall cost magnitude
    wallCostX = zeros( visEnviro.screen.screenHeight, visEnviro.screen.screenWidth); %wall cost x direction
    wallCostY = zeros( visEnviro.screen.screenHeight, visEnviro.screen.screenWidth); %wall cost y direction

    %top wall
    %wallCostGrid(1:sizeOpts.wallThickness+round(sizeOpts.playerWidth/2*sqrt(2)),:) = costOpts.costWall;
    wallCostGrid(1:sizeOpts.wallThickness,:) = costOpts.costWall;
    wallCostX(1:sizeOpts.wallThickness,1:visEnviro.screen.screenWidth/2) = 0; %leftward
    wallCostX(1:sizeOpts.wallThickness,visEnviro.screen.screenWidth/2+1:end) = pi; %rigthward
    wallCostY(1:sizeOpts.wallThickness,:) = 3/2*pi; %downward

    %bottom wall
    wallCostGrid(visEnviro.screen.windowRect(4) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end,1:visEnviro.screen.screenWidth) = costOpts.costWall;
    wallCostX(visEnviro.screen.windowRect(4) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end,:) = 0; %leftward
    wallCostX(visEnviro.screen.windowRect(4) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end,visEnviro.screen.screenWidth/2+1:end) = pi; %rightward
    wallCostY(visEnviro.screen.windowRect(4) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end,:) = pi/2; %upward

    %left wall
    %wallCostGrid(:,1:sizeOpts.wallThickness+round(sizeOpts.playerWidth/2*sqrt(2))) = costOpts.costWall;
    wallCostGrid(:,1:sizeOpts.wallThickness) = costOpts.costWall;
    wallCostX(:,1:sizeOpts.wallThickness) = 0; %rightward
    wallCostY(1:visEnviro.screen.screenHeight/2,1:sizeOpts.wallThickness) = pi/2;%upward
    wallCostY(visEnviro.screen.screenHeight/2+1:end,1:sizeOpts.wallThickness) = 3/2*pi;%downward

    %right wall
    wallCostGrid(:,visEnviro.screen.windowRect(3) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end) = costOpts.costWall;
    wallCostX(:,visEnviro.screen.windowRect(3) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end) = pi; %rightward
    wallCostY(1:visEnviro.screen.screenHeight/2,visEnviro.screen.windowRect(3) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end) = pi/2; %upward
    wallCostY(visEnviro.screen.screenHeight/2+1:end,visEnviro.screen.windowRect(3) - sizeOpts.wallThickness-round(sizeOpts.playerWidth/2*sqrt(2)):end) = 3/2*pi;%downward

    %store wall cost grid
    costOpts.wallCostPosition = wallCostGrid;
    costOpts.wallCostdirectionX = wallCostX;
    costOpts.wallCostdirectionY = wallCostY;

    % Cost grid part 2. Gradient map for low cost at center.
    [ x , y ] = meshgrid( 1 : visEnviro.screen.screenWidth, 1 : visEnviro.screen.screenHeight  );
    centerGrid	= sqrt(((x-visEnviro.screen.screenWidth/2)/visEnviro.screen.screenWidth).^4 ...
        + ((y-visEnviro.screen.screenHeight/2)/visEnviro.screen.screenHeight).^4);
    centerGrid = costOpts.costPositionMax*centerGrid/max(centerGrid(:)); %normalize & scale

    % Final grid part: add up every
    costOpts.positionCostGrid = centerGrid;%position costs
    radiusH = sqrt((x-visEnviro.screen.screenWidth/2).^2+(y-visEnviro.screen.screenHeight/2).^2); %radial distance from center
    costOpts.directionCostGridX = pi-acos((x-visEnviro.screen.screenWidth/2)./radiusH);%direction for X
    costOpts.directionCostGridY = pi-asin((y-visEnviro.screen.screenHeight/2)./radiusH);%direction for X


    %---Define Distance Cost---%
    %not clear what the justification is behind these values but we will keep
    %them for now SDK 5/16/2020
    costOpts.maxDistanceCost = 1.5; %scale factor for distance cost
    costOpts.max_dist = sqrt(visEnviro.screen.screenWidth.^2 + visEnviro.screen.screenHeight.^2);
    distanceAxis = linspace( 1, 10, costOpts.max_dist );	% Possible maximum distance within the screen.
    costOpts.player2NPCDistanceWeight = fliplr(1./(1+exp(-2*(distanceAxis -6))));
    costOpts.player2NPCDistanceWeight = costOpts.maxDistanceCost*costOpts.player2NPCDistanceWeight./max(costOpts.player2NPCDistanceWeight); %normalize & scale
    costOpts.npc2NPCDistanceWeight = fliplr(exp(-4*(10-distanceAxis)));
    costOpts.npc2NPCDistanceWeight = costOpts.maxDistanceCost*costOpts.npc2NPCDistanceWeight./max(costOpts.npc2NPCDistanceWeight);%normalize & scale


    %---Define Momentum "Costs"---%
    costOpts.momentumMaxCost = 0.33; %maximum cost of momentum vector
    maxCostVal = (costOpts.costWall + costOpts.costPositionMax + costOpts.maxDistanceCost); %maximum cost npc will experience
    costOpts.momentumScaleValue = 0:0.1:maxCostVal;
    costOpts.momentumScaleFunction	= fliplr(1./(1+exp(-2*(costOpts.momentumScaleValue - maxCostVal))));
    costOpts.momentumScaleFunction = costOpts.momentumMaxCost*costOpts.momentumScaleFunction/max(costOpts.momentumScaleFunction);
    costOpts.momentumFrames = 6; %how many positions to go back in time to calculate momentum, 6 is ~100 ms
    costOpts.momentumFrames = costOpts.momentumFrames + 1;%for indexing


    %---Generate Task structure---%
    taskData = struct();

    %generate all starting positions for npcs
    if pacmanOpts.positions.numPositions <= 8
        taskData.startingPositions = NaN(2,pacmanOpts.positions.numPositions);
        angleDiff = 360/pacmanOpts.positions.numPositions;
        for pos = 1:pacmanOpts.positions.numPositions
            taskData.startingPositions(1,pos) = cosd(angleDiff*(pos-1))*pacmanOpts.positions.eccentricity;
            taskData.startingPositions(2,pos) = sind(angleDiff*(pos-1))*pacmanOpts.positions.eccentricity;
        end

        %add these positions to center
        taskData.startingPositions(1,:) = taskData.startingPositions(1,:) + visEnviro.rig.width/2;
        taskData.startingPositions(2,:) = taskData.startingPositions(2,:) + visEnviro.rig.height/2;

    elseif pacmanOpts.positions.numPositions == 24
        %center point is removed
        centerX = visEnviro.rig.width/2;
        centerY = visEnviro.rig.height/2;
        taskData.startingPositions = NaN(2,pacmanOpts.positions.numPositions);
        xSpacing = visEnviro.rig.width/5*0.8;
        ySpacing = visEnviro.rig.height/5*0.8;
        uniqueX = [centerX-2*xSpacing centerX-xSpacing centerX centerX+xSpacing centerX+2*xSpacing];
        uniqueY = [centerY-2*ySpacing centerY-ySpacing centerY centerY+ySpacing centerY+2*ySpacing];

        posInd = 1;
        for xS = 1:length(uniqueX)
            for yS = 1:length(uniqueY)
                if xS == 3 && yS == 3
                    continue
                else
                    taskData.startingPositions(1,posInd) = uniqueX(xS);
                    taskData.startingPositions(2,posInd) = uniqueY(yS);
                    posInd = posInd + 1;
                end
            end
        end
    else
        error('need to write code here!')
    end

    %generate trial structure
    if strcmpi(pacmanOpts.trialParams.rewardStructType,'originalRandom')
        if rem(pacmanOpts.trialParams.ntrials,100) == 0
            halfTrials = pacmanOpts.trialParams.ntrials/2;

            %single npc trials
            scaleFactor= halfTrials/5;
            npcIndex1 = [1*ones(1,scaleFactor), 2*ones(1,scaleFactor), 3*ones(1,scaleFactor), 4*ones(1,scaleFactor), 5*ones(1,scaleFactor)];
            npcIndex1 = npcIndex1(randperm(length(npcIndex1)));%random order
            npcIndex1 = [npcIndex1; NaN(2,halfTrials)]; %to keep structure with block below

            %multiple npc trials with balanced 2 trial combos
            allPotentialCombos = nchoosek(1:5,2); %unique combinations of 2 prey
            comboFactor = halfTrials/size(allPotentialCombos,1);
            comboIndeces = ones(comboFactor,1)*(1:size(allPotentialCombos,1));%creates balanced combos

            %shuffle order
            shuffledInd = randperm(halfTrials);
            comboIndeces = comboIndeces(shuffledInd);
            npcIndex2 = NaN(3,halfTrials);
            for trial = 1:halfTrials
                npcIndex2(1:2,trial) = allPotentialCombos(comboIndeces(trial),:)';
            end

            %predators
            predatorIndex1 = -[1*ones(1,scaleFactor), 2*ones(1,scaleFactor), 3*ones(1,scaleFactor), 4*ones(1,scaleFactor), 5*ones(1,scaleFactor)];
            predatorIndex1 = [predatorIndex1 NaN(1,halfTrials)];
            shuffledInd2 = randperm(length(predatorIndex1));
            predatorIndex1 = predatorIndex1(shuffledInd2);

            %combine all
            allNPCIndex = [npcIndex1 npcIndex2];
            for trial = 1:length(predatorIndex1)
                if ~isnan(predatorIndex1(trial))
                    if isnan(allNPCIndex(2,trial))
                        allNPCIndex(2,trial) = predatorIndex1(trial);
                    else
                        allNPCIndex(3,trial) = predatorIndex1(trial);
                    end
                end
            end
            shuffledInd3 = randperm(length(allNPCIndex));
            allNPCIndex = allNPCIndex(:,shuffledInd3);
            allNumnpcs = sum(~isnan(allNPCIndex),1);

            %store all together
            taskData.numNPCs = allNumnpcs;
            taskData.npcIndex = allNPCIndex;
        else
            error('need code here! Assumed trial count was a multiple of 100 (e.g. 200)')
        end

    elseif strcmpi(pacmanOpts.trialParams.rewardStructType,'newBalanced')
        pacmanOpts.trialParams.ntrials = 250; %write over in case not 250

        %block 1: 50 trials of 1 prey
        numNPCs1 = ones(1,50);%total number
        npcIndex1 = [1*ones(1,10), 2*ones(1,10), 3*ones(1,10), 4*ones(1,10), 5*ones(1,10)];
        npcIndex1 = npcIndex1(randperm(length(npcIndex1)));%random order
        npcIndex1 = [npcIndex1; NaN(2,50)]; %to keep structure with block below

        %block 2: random mix of 100 trials 2 prey no predator + 100 trials of 2 prey + 1 predator
        %try to balance so 10 trials for each comparison with and without predator
        numNPCs2 = [2*ones(1,100) 3*ones(1,100)];%total number of npcs, 2 for w/o predator 3 for w/ predator
        allPotentialCombos = nchoosek(1:5,2); %unique combinations of 2 prey
        comboIndeces = ones(10,1)*(1:size(allPotentialCombos,1));%create 10 of these for 100 trials
        comboIndeces = [comboIndeces(:); comboIndeces(:)]; %combined 2 to make 200 trials worth

        %shuffle order
        shuffledInd = randperm(length(numNPCs2));
        numNPCs2 = numNPCs2(shuffledInd);
        comboIndeces = comboIndeces(shuffledInd);
        npcIndex2 = NaN(3,200);
        for trial = 1:200
            npcIndex2(1:2,trial) = allPotentialCombos(comboIndeces(trial),:)';
            if numNPCs2(trial) == 3
                npcIndex2(3,trial) = -1; %negative for pedator
            end
        end

        %store all together
        taskData.numNPCs = [numNPCs1 numNPCs2];
        taskData.npcIndex = [npcIndex1 npcIndex2];
        % Code insertion GK
    elseif contains(pacmanOpts.trialParams.rewardStructType,'50plusDelay')
        % Generate the first 50 trials in random order
        npc_index_start = kron(1:5, ones(1,2));
        npc_index_start = npc_index_start(randperm(length(npc_index_start)));
        % npc_index_start = npc_index_start(1:20);
        
        % Generate the Npc Trials and the hiding times
        [pacmanOpts, npc_servings, hide_time_table] = pacmanGetWaitTable(pacmanOpts, ...
                                                        pacmanOpts.trialParams.rewardStructType);
        
        % Update variables to conform to the new data
        npc_index_start = [npc_index_start;NaN(height(npc_servings)-1, width(npc_index_start))];  % Change the first 50 trials to the format of the rest
        pacmanOpts.npcHideTimeTable = [zeros(1,width(npc_index_start)), hide_time_table];
            % update nTrials to reflect what we need
        if pacmanOpts.trialParams.ntrials < 0
            pacmanOpts.trialParams.ntrials = width(npc_servings) + width(npc_index_start);
        else
            pacmanOpts.trialParams.ntrials = pacmanOpts.trialParams.ntrials + width(npc_index_start);
        end
        
        
        % Concatenate the start and the randomized trials together
        all_npc_index = [npc_index_start, npc_servings];

        if length(all_npc_index) ~= pacmanOpts.trialParams.ntrials; error('ntrials differs from number of trials'); end

        allNumNpcs = zeros(1, length(all_npc_index));
        for numIdx = 1:length(allNumNpcs)
            allNumNpcs(numIdx) = sum(~isnan(all_npc_index(:,numIdx)));
        end

        %store all together
        taskData.numNPCs = allNumNpcs;
        taskData.npcIndex = all_npc_index;
        % Code insertion GK end
    else
        error('block type not recognized!')
    end


    %generate starting positions, these can be totally random
    taskData.startingPosition = cell(3,250);
    numStartingPos = length(taskData.startingPositions);
    for trial = 1:length(taskData.numNPCs)
        startingInd = 1:numStartingPos;
        startingInd = startingInd(randperm(numStartingPos));
        for npc = 1:taskData.numNPCs(trial)
            taskData.startingPosition{npc,trial} = taskData.startingPositions(:,startingInd(npc));
        end
    end



    %---Store All Data into Structure Array and Save---%
    pacmanTaskSpecs = struct();
    pacmanTaskSpecs.gameOpts = gameOpts;
    pacmanTaskSpecs.colorOpts = colorOpts;
    pacmanTaskSpecs.sizeOpts = sizeOpts;
    pacmanTaskSpecs.costOpts = costOpts;
    pacmanTaskSpecs.taskData = taskData;

    %always save [even reloaded options and rewards] for each session in case there are issues
    save([pacmanOpts.fileParams.dataDirectory pacmanOpts.fileParams.fileBaseName '_taskVariables.mat'],'pacmanOpts','visEnviro','pacmanTaskSpecs');

end
