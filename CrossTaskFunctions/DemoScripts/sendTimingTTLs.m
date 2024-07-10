%This code sends TTLs every so many seconds when the experimenter hits the
%space bar so that we can track when patients are doing non-Matlab task 
%(e.g. word tasks with voice recordings). Code stops sending TTLs when
% space bar is pressed again. Code uses defaultRig_params so TTLs being
% sent are based on the TTL hardware defined in defaultRig_params. Since
% this is all open ended to help parse Neuralynx and Natus files later, the
% behavioral times and EyeLink Times are not saved!
%
% To start, simply run script. You must then press the SPACEBAR to start
% sending TTLs. Pressing the SPACEBAR again will stop sending the TTLs.
%
% written by Seth Konig 10/21/20


timeBetweenPulses = 1.0; %time between pulses in seconds. Suggested value of 1.0 seconds.


%---Set up TTL System and Keyboard---%
%make sure environment parmaters are correct
rig = defaultRig_params();%get environment parameters
ttlStruct = hdLabSetupTTLDevice(rig);
KB = hdLabSetupKeyboard();%initiate keyboard short cuts
disp('TTL Hardware and Keyboard are ready to use!');
disp('Press the space bar to start sending TTLs!');


%---Wait for Keyboard Input---%
waitForKeyPress = true;
while waitForKeyPress
    [~, ~, keyCode] = KbCheck;
    if keyCode(KB.space)
        waitForKeyPress = false;
    end
    WaitSecs(0.001);%so doesn't loop too fast
end
WaitSecs(0.5); %for good luck and to prevent double taps...


%---Start Sending TTLs---%
sendStartTime = markEvent('taskStart',NaN,ttlStruct,[],false,0); %send start value
disp('Start pulse send!')

waitForKeyPress = true;
timeofLastPulse = sendStartTime;
pulseNumber = 0;
while waitForKeyPress
    
    %Check for Space Bar Press
    [~, ~, keyCode] = KbCheck;
    if keyCode(KB.space)
        waitForKeyPress = false;
    end
    
    %Update time since last pulse, if > timeBetweenPulses, send new pulse
    timeSinceLastPulse = GetSecs()-timeofLastPulse;
    wasLastPulseEven = true;
    if timeSinceLastPulse >= timeBetweenPulses
        if wasLastPulseEven
            timeofLastPulse = markEvent('timingPulse1',NaN,ttlStruct,[],false,0); %send timing pulse
            wasLastPulseEven = false;
        else
            timeofLastPulse = markEvent('timingPulse2',NaN,ttlStruct,[],false,0); %send timing pulse
            wasLastPulseEven = true;
        end
        pulseNumber = pulseNumber+1;
        disp(['Timing pulse# ' num2str(pulseNumber) ' sent'])
    end
    
    WaitSecs(0.001);%so doesn't loop too fast
end


%---Stop Sending TTL Pulses---%
sendEndTime = markEvent('taskStop',NaN,ttlStruct,[],false,0); %send start value
closeTask(ttlStruct); %closes everything
disp('End pulse send!')


%--Display Summary Stats---%
disp('')
disp('')
disp(['A total of ' num2str(pulseNumber)  ' pulses were sent over ' num2str(sendEndTime-sendStartTime) ' seconds']) 
