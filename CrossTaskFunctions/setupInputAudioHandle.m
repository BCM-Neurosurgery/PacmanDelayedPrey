function audioRecordingHandle = setupInputAudioHandle()
%function sets up audio input handle for recording audio based on catFlu version.
%written by Danielle Carlson and Seth Konig 9/20/21

%---Determine What to Record From---%
desiredHostAudioAPIName = 'Windows WASAPI'; %should provide the best latency
desiredDeviceType = 'Microphone';
desiredHostListeningDeviceName = 'AIR 192 4'; %should provide the best latency


%---Get Audio Recording Handle---%
InitializePsychSound;
deviceStruct = PsychPortAudio('GetDevices');
for i = 1:length(deviceStruct)
    if strcmp(deviceStruct(i).HostAudioAPIName, desiredHostAudioAPIName)
        if contains(deviceStruct(i).DeviceName, desiredDeviceType)
            if contains(deviceStruct(i).DeviceName,desiredHostListeningDeviceName)
                desiredDeviceIndex = deviceStruct(i).DeviceIndex;
                break;
            end
        end
    end
end


%---Get Audio Device---%
%Initialize Sounddriver, absolutely must do
InitializePsychSound(1);
audioRecordingHandle = PsychPortAudio('Open', desiredDeviceIndex, 2);

%set a few other aduio settings
PsychPortAudio('Verbosity',0); %turns off warnings

end