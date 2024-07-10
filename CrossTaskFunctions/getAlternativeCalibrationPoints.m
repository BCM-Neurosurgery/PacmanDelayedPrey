function [caliCoord,caliStrings] = getAlternativeCalibrationPoints(caliType,visEnviro,optionalParam)
%function grabs alteternative calibration (cali) coordinates and the
%EyeLink string commands assoicated with this.
%This script is where you could put patinet-specific calibration
%coordinates if a patient has visual issues (e.g. blindspots).
%
% Inputs:
%   1) caliType: calibration type
%   2) visEnviro: visual environment paramters so can get pixel coordinates and such
%   3) optionalParam: optinal calibration paramters (see individual types)
%
% Outputs:
%   1) caliCoord: calibration coordinates
%   2) caliStrings: strings formatted for the calibration specific to the
%   calibration type
%
%Written by Seth Koenig 9/4/21

switch caliType
    case 'HV9' %default
        caliType = [];
        caliCoord = [];
        
    case {'HV3','HV5','HV13'} %built in lower point counts; HV13 is not necessary
        %don't have to do much
        caliCoord = [];
        caliStrings = [];
        caliStrings.type = 'existingCalibration';
        caliStrings.sequenceString = caliType;
        
        %scale so doesn't cover fullscreen
        switch caliType
            case 'HV3' %doens't seem to work
                scalingFactor = 1/2; %1/3 to 1/2 is recomended; otherwise might as well be doing hv5
            case 'HV5'
                scalingFactor = 2/3; %1/3 to 2/3 is recommended; this way not close to edges otherwise might as well do hv9
            case 'HV13'
                scalingFactor = 1;%no need to change
        end
        defaultArea = [0.88 0.83];
        newArea= scalingFactor*defaultArea; %as in default from hardware settings according to SR EyeLink people
        caliStrings.caliAreaProp = ['calibration_area_proportion ' num2str(newArea(1)) ' ' num2str(newArea(2))];
        caliStrings.validAreaProp = ['validation_area_proportion ' num2str(newArea(1)) ' ' num2str(newArea(2))];
        
        
    case 'horizontal3' %3 point horizontal alignment
        %coordinate positions
        horizontalPosition = [1/3:1/6:2/3]*visEnviro.screen.screenWidth;
        verticalPosition = 0.5*visEnviro.screen.screenHeight*ones(1,3);
        caliCoord = round([horizontalPosition; verticalPosition]);
        
        %all the stuff for the eye link commands
        caliStrings = [];
        caliStrings.type = 'calibrationPoints';
        caliStrings.numPoints = 3;
        caliStrings.sequenceString = [];
        caliStrings.caliTargets = 'calibration_targets ='; %for calibration points
        caliStrings.validTargets = 'validation_targets ='; %for validation points
        for p = 1:3
            caliStrings.caliTargets = [caliStrings.caliTargets ' ' num2str(caliCoord(1,p)) ',' num2str(caliCoord(2,p))];
            caliStrings.validTargets = [caliStrings.validTargets ' ' num2str(caliCoord(1,p)) ',' num2str(caliCoord(2,p))];
            if p == 3
                caliStrings.sequenceString = [caliStrings.sequenceString num2str(p-1)];
            else
                caliStrings.sequenceString = [caliStrings.sequenceString num2str(p-1) ','];
            end
        end
        
        
    case 'vertical3' %3 point vertical alignment
        %coordinate positions
        horizontalPosition = 0.5*visEnviro.screen.screenWidth*ones(1,3);
        verticalPosition = [0.25:0.25:0.75]*visEnviro.screen.screenHeight;
        caliCoord = round([horizontalPosition; verticalPosition]);
        
        %all the stuff for the eye link commands
        caliStrings = [];
        caliStrings.type = 'calibrationPoints';
        caliStrings.numPoints = 3;
        caliStrings.sequenceString = [];
        caliStrings.caliTargets = 'calibration_targets ='; %for calibration points
        caliStrings.validTargets = 'validation_targets ='; %for validation points
        for p = 1:3
            caliStrings.caliTargets = [caliStrings.caliTargets ' ' num2str(caliCoord(1,p)) ',' num2str(caliCoord(2,p))];
            caliStrings.validTargets = [caliStrings.validTargets ' ' num2str(caliCoord(1,p)) ',' num2str(caliCoord(2,p))];
            if p == 3
                caliStrings.sequenceString = [caliStrings.sequenceString num2str(p-1)];
            else
                caliStrings.sequenceString = [caliStrings.sequenceString num2str(p-1) ','];
            end
        end
        
    case 'center1' %central point only better than nothing?
        %coordinate positions
        horizontalPosition = 0.5*visEnviro.screen.screenWidth;
        verticalPosition = 0.5*visEnviro.screen.screenHeight;
        caliCoord = round([horizontalPosition; verticalPosition]);
        
        %all the stuff for the eye link commands
        caliStrings = [];
        caliStrings.type = 'calibrationPoints';
        caliStrings.numPoints = 1;
        caliStrings.sequenceString = [];
        caliStrings.caliTargets = ['calibration_targets = ' num2str(caliCoord(1)) ',' num2str(caliCoord(2))]; %for calibration points
        caliStrings.validTargets = ['validation_targets = ' num2str(caliCoord(1)) ',' num2str(caliCoord(2))]; %for validation points
        caliStrings.sequenceString = '0';
        
        
    otherwise
        error('calibration type not recognized')
        
end

end