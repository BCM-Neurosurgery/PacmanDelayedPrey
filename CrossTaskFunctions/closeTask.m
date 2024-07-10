function closeTask(ttlStruct,visEnviro)
%does task cleanup for multiple functions by closing down TTL device, eye
%tracker, and Psychtoolbox
%made into function by Seth Konig 2/18/2020
%
% Inputs: 
%   1) ttlStruct: TTL structure containing information about TTL device
%   2) visEnviro: visual & environment structure which includes audio handle
% 
% Outputs:
%   none) closes everything

%Close any ttl devices
if nargin > 0
    hdLabCloseTTLDevice(ttlStruct);
end

%Close any Audio Handle
if nargin == 2
    try %sometimes prodcues an error
        if isfield(visEnviro,'soundParams')
            if isfield(visEnviro.soundParams,'audioOutHandle')
                PsychPortAudio('Close',visEnviro.soundParams.audioOutHandle);
            end
            if isfield(visEnviro.soundParams,'audioRecordingHandle')
                PsychPortAudio('Close',visEnviro.soundParams.audioRecordingHandle);
            end
        end
    end
end

%Close Eye Tracker
%if Eyelink('IsConnected')
%    Eyelink('command', 'clear_screen %d', 0);
%    Eyelink('stoprecording');
%    Eyelink('shutdown');
%end

% give keyboard & mouse back
ListenChar(0);
ShowCursor();

% Close all displays and back to command line
sca;
commandwindow;
end