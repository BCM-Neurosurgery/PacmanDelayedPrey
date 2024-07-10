%Demo shows how to Play Sounds with Pyschtoolbox audio functions
%Demo works through all audio out devices. See setupOutputAudioHandle for
%more specific instructions.
%written by Seth Konig 3/5/21 based on https://peterscarfe.com/beepdemo.html

clear, clc, close all, sca

%---Get Lit of All Audio Out Devices---%
devices = PsychPortAudio('GetDevices');
outputDevices = zeros(1,length(devices));
for d = 1:length(devices)
    if devices(d).NrOutputChannels ~= 0
        outputDevices(d) = 1;
    end
end
outputDevices = find(outputDevices == 1); %select only ones that are output


%---Setup Audio Signals---%
% Initialize Sounddriver, must do
InitializePsychSound(1);

% Start immediately (0 = immediately)
startCue = 0;

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;



%---Generate Sound Output for All Devices---%

for o = 1:length(outputDevices)
    try
        %get device properites
        deviceIndex = devices(outputDevices(o)).DeviceIndex;
        deviceName = devices(outputDevices(o)).DeviceName;
        deviceOuputFrequency = devices(outputDevices(o)).DefaultSampleRate;
        
        %display properties
        disp(' ')
        disp(' ')
        disp(['Playing device index # ' num2str(deviceIndex)])
        disp(['Audio device name: ' deviceName])
        
        %make sounds, cuz frequency based
        [sf,rwdSound,norwdSound] = makeAudioFeedback(deviceOuputFrequency);
        
        % Open Psych-Audio port, with the follow arguements
        % (1) [] = default sound device
        % (2) 1 = sound playback only
        % (3) 1 = default level of latency
        % (4) Requested frequency in samples per second
        % (5) 2 = stereo putput
        pahandle = PsychPortAudio('Open', deviceIndex, 1, 1, deviceOuputFrequency, 2);
        
        % Set the volume to half for this demo
        PsychPortAudio('Volume', pahandle, 1);
        
        % Fill the audio playback buffer with the audio data, doubled for stereo
        % presentation
        preBufferFill = GetSecs();
        PsychPortAudio('FillBuffer', pahandle, [rwdSound; rwdSound]);
        bufferFull = GetSecs();
        bufferFillTime = bufferFull-preBufferFill;
        disp(['Buffer fill time was: ' num2str(bufferFillTime,3) ' seconds!'])

        % Start audio playback
        preAudioStart = GetSecs();
        PsychPortAudio('Start', pahandle, 1, 0, waitForDeviceStart);
        
        % Wait for stop of playback
        PsychPortAudio('Stop', pahandle, 1, 1);
        preAudioDone = GetSecs();
        
        audioDuration = preAudioDone-preAudioStart;
        disp(['Audio duration was: ' num2str(audioDuration,3) ' seconds!'])
        
        % Close the audio device
        PsychPortAudio('Close', pahandle);
        
        WaitSecs(4);
    catch
        disp('failed to play!')
    end
end