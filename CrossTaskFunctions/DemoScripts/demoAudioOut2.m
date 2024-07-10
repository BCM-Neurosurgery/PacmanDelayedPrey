%Demo shows how to Play Sounds with Pyschtoolbox audio functions
%Demo used setupOutputAudioHandle, like a task would
%written by Seth Konig 3/5/21 based on https://peterscarfe.com/beepdemo.html

clear, clc, close all, sca

numberRewardSounds = 4;

%---Setup Audio---%
[audioOutHandle,speakerFrequency] = setupOutputAudioHandle();
[sf,rwdSound,norwdSound] = makeAudioFeedback(speakerFrequency);


%---Generate Sound Output for All Devices---%
for nRS = 1:numberRewardSounds
    disp(['Reward Sound#' num2str(nRS)])
    
    %Do Reward Sound
    rwdSoundStart = GetSecs();
    PsychPortAudio('FillBuffer', audioOutHandle, [rwdSound; rwdSound]);
    PsychPortAudio('Start', audioOutHandle, 1, 0, 0);
    PsychPortAudio('Stop', audioOutHandle, 1, 1);
    rwdSoundStop = GetSecs();
    
    rwdSoundDuration = rwdSoundStop-rwdSoundStart;
    disp(['Reward Sound duration was: ' num2str(rwdSoundDuration,3) ' seconds!'])
    
    
    %pause
    WaitSecs(0.5);
    
    
    %Do No Reward Sound
    norwdSoundStart = GetSecs();
    PsychPortAudio('FillBuffer', audioOutHandle, [norwdSound; norwdSound]);
    PsychPortAudio('Start', audioOutHandle, 1, 0, 0);
    PsychPortAudio('Stop', audioOutHandle, 1, 1);
    norwdSoundStop = GetSecs();
    
    norwdSoundDuration = norwdSoundStop-norwdSoundStart;
    disp(['No reward Sound duration was: ' num2str(norwdSoundDuration,3) ' seconds!'])
    
    
    WaitSecs(2);
end

% Close the audio device
PsychPortAudio('Close', audioOutHandle);