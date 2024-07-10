function [audioHandle,speakerFrequency] = setupOutputAudioHandle()
%function sets up audio handle for playing sounds. We have issues with just
%using sound in BART task.
%written by Seth Konig 3/5/21.

desiredHostAudioAPIName = 'Windows WASAPI'; %should provide the best latency
desiredDeviceName = 'Speakers/Headphones (Realtek(R) Audio)';
alternativeDevice = 'Microsoft Sound Mapper - Output'; %works but latency will suck. coudln't get Windows WDM-KS to work

%---Get Lit of All Audio Out Devices---%
InitializePsychSound;
devices = PsychPortAudio('GetDevices');
desiredDeviceIndex = [];
speakerFrequency = [];
for d = 1:length(devices)
    if devices(d).NrOutputChannels ~= 0 && ...
            strcmpi(devices(d).HostAudioAPIName,desiredHostAudioAPIName) && ...
            strcmpi(devices(d).DeviceName,desiredDeviceName)
        desiredDeviceIndex = devices(d).DeviceIndex;
        speakerFrequency = devices(d).DefaultSampleRate;
    end
end

%get alternative
if isempty(desiredDeviceIndex)
    desiredDeviceIndex = [];
    for d = 1:length(devices)
        if devices(d).NrOutputChannels ~= 0 && strcmpi(devices(d).DeviceName,alternativeDevice)
            desiredDeviceIndex = devices(d).DeviceIndex;
            speakerFrequency = devices(d).DefaultSampleRate;
        end
    end
end


%---Get Audio Device---%
%Initialize Sounddriver, absolutely must do
InitializePsychSound(1);
audioHandle = PsychPortAudio('Open', desiredDeviceIndex, 1, 1, speakerFrequency, 2);

%set a few other aduio settings
PsychPortAudio('Volume', audioHandle, 1); %set volume 1:1 with speaker volume
PsychPortAudio('Verbosity',0); %turns off warnings, mainly for BART with high rate of inflates!
end