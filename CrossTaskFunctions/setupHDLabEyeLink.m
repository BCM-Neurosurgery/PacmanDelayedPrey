function [eyeTrackerhHandle,edfFileName,eyeTracked] = setupHDLabEyeLink(...
    screenWindow,createEDFFile,baseFileName,calibrationStrings)
%function setsup EyeLink eye tracker & call calibration.
%written by Seth Konig 2/20/2020
%To replace setupEyelink_pacman and make more flexible/automatic
%
%Inputs:
%   1) screenWindow: Screen Window handle so EyeLink knows screen info
%   2) createEDFFile: true/false flag for creating unique EDF files
%   3) baseFileName: base file name for task subject and session
%
%Outputs:
%   1) eyeTrackerhHandle: EyeTracker handle necessary for various functions
%   2) edfFileName: EDF file name
%   3) eyeTracked: which eye is being tracked, if binocular, default to
%   left eye, code will warn of this

%check input for alternative calibration strings
if nargin < 4
    calibrationStrings = 'default';
end

%%%---Connect the Eye Tracker---%%%
if ~Eyelink('IsConnected')
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    eyeTrackerhHandle = EyelinkInitDefaults(screenWindow);
    [result, dummy] = EyelinkInit(0);
else
    disp('Eye-tracker is already connected, restarting connection...');
    Eyelink('Shutdown');
    WaitSecs(1);%was in the demo not sure 100% necessary but hey its only 100 ms
    eyeTrackerhHandle = EyelinkInitDefaults(screenWindow);
    [result, dummy] = EyelinkInit(0);
end

%%%---Setup of Eye Tracking Data Streams---%%%
if dummy %failed to connect to the eye tracker
    eyeTrackerhHandle = [];
    return
end

eyeLinkStatus = Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');%only want a little bit of the data in real time
if eyeLinkStatus ~=0
    eyeLinkStatus( 'link sample data error, status: %2.2d	\n', eyeLinkStatus );
end

%%%---EDF file setting up---%%%
edfFileName = [];
if createEDFFile
    Eyelink( 'command', 'file_sample_data = LEFT, RIGHT, GAZE, HREF, AREA, STATUS, INPUT' );%store all the data
    edfFileName = [baseFileName '_pre.edf'];
    Eyelink('Openfile', edfFileName );
end

%%%---Calibrate Eye Tracker---%%%
if strcmpi(calibrationStrings,'default')
    Eyelink('command', 'randomize_calibration_order = YES');%if always do in order, ppl could get lazy
    Eyelink('command', 'generate_default_targets = YES');
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'enable_automatic_calibration = YES'); %automatically go through calibration points
    Eyelink('command', 'calibration_area_proportion 0.88 0.83'); %default area
    Eyelink('command', 'validation_area_proportion 0.88 0.83'); %default area
else
    switch calibrationStrings.type
        case 'existingCalibration'  %alternative default points such as HV3 instead of HV9
            Eyelink('command', 'generate_default_targets = YES');
            Eyelink('command', ['calibration_type = ' calibrationStrings.sequenceString]);
            Eyelink('command', 'randomize_calibration_order = YES');%if always do in order, ppl could get lazy
            Eyelink('command','enable_automatic_calibration = YES'); %automatically go through calibration points
            Eyelink('command', calibrationStrings.caliAreaProp);
            Eyelink('command', calibrationStrings.caliAreaProp);
            
        case 'calibrationPoints' %custom points
            Eyelink('command', 'randomize_calibration_order = NO');%have to turn off or uses default points
            Eyelink('command', 'generate_default_targets = NO');
            Eyelink('command',['calibration_samples = ' num2str(calibrationStrings.numPoints)]);
            Eyelink('command',['calibration_sequence = ' calibrationStrings.sequenceString]);
            Eyelink('command',calibrationStrings.caliTargets);
            Eyelink('command',['validation_samples = ' num2str(calibrationStrings.numPoints)]);
            Eyelink('command',calibrationStrings.validTargets);
            Eyelink('command','enable_automatic_calibration = YES'); %automatically go through calibration points
        otherwise
            error('calibration command string type is not recognized')
    end
end
EyelinkDoTrackerSetup(eyeTrackerhHandle);

%%%---Start Tracking the Eye---%%%
WaitSecs(0.1);%was in the demo not sure 100% necessary but hey its only 100 ms
recordingStatus = Eyelink('StartRecording');
if recordingStatus~=0
    error(['Eye Tracking Recording start error, status: ',recordingStatus]);
else
    disp('Eye Tracking recording started!');
end

%%%---Determine which eye(s) is being Tracked---%%%
eyeTracked = Eyelink('EyeAvailable'); % get eye that's tracked
if eyeTracked == eyeTrackerhHandle.BINOCULAR % if both eyes are tracked
    eyeTracked = eyeTrackerhHandle.LEFT_EYE; % use left eye
    warning('Binocular tracking, switching to storing only left eye!')
end

end