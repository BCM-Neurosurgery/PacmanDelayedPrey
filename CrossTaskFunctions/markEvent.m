function [timeStampMatlab,ttlValue] = markEvent(eventName,eventValue,ttlStruct,screenWindow,eyeTrackerConnected,screenFlip)
% Function sends TTL pulses via TTL device determined in ttlStruct, sends the same
% event to the eye tracker edf file, and gets the time stamp of the event
% in Matlab. Currently assumes 8 bit TTL (i.e. 256 values), but don't use 0
% because some TTL systems may read "ghost" values as 0 on falling edge.
% Modifed by Seth Konig 2/20/20 for use across multiple tasks. Event Names
% are CASE SENSITIVE!.
% Modified by Seth Konig 8/25/20 to make sure works with Python code that
% is now working as well as add 'conditional' eventName for N-back tasks.
%
% New events can be added as needed so long as the event values are unique & between 1-255
%
% All events are straightforward, but the following...
% a) Trial# event value is 100 + mod(Trial#,100)
% b) Block# event value is 200 + mod(Trial#,50)
% c) Unknown event values are coded as 99
%
%
% Inputs:
%   1) eventName: string containing event name
%   2) eventValue: integer value of event; currently only used for trial & block numbers
%   3) ttlStruct: structure containing information about TTL device and settings
%   4) eyeTrackerConnected: true/false flag determining if using an [EyeLink] eye tracker
%   5) screenFlip: true/false flag determining if flipping the screen (sync with screen refresh)
%
% Outputs:
%   1) timeStampMatlab: Matlab timestamp of GetSecs() or screen flip (basically same thing)
%   2) ttlValue: value of TTL pulse sent


%---Determine TTL value to Send---%
switch eventName
    
    %task start/stops pause/resume events
    case 'taskStart'
        ttlValue = 1;
    case 'taskStop'
        ttlValue = 2;
    case 'taskPaused'
        ttlValue = 3;
    case 'taskResume'
        ttlValue = 4;
    case 'taskQuit'
        ttlValue = 5;
    case 'recalibrateStart'
        ttlValue = 6;
    case 'recalibrateEnd'
        ttlValue = 7;
    case {'timingPulse','timingPulse1'}
        ttlValue = 8;
    case 'timingPulse2'
        ttlValue = 9;
        
        %left 10 available
        
        
        %important trial events
    case 'trialStart'
        ttlValue = 11;
    case 'trialEnd'
        ttlValue = 12;
    case 'unrewarded' %picked wrong stimulus but completed trial
        ttlValue = 13;
    case 'reward'
        ttlValue = 14;
    case 'eventTimeout'
        ttlValue = 15;
    case 'breakFixation'
        ttlValue = 16;
    case 'userInput' %e.g. important keypress
        ttlValue = 17;
    case 'blockStart' %for when there are lots of blocks!
        ttlValue = 18;
    case 'blockEnd' %for when there are lots of blocks!
        ttlValue = 19;
        %left available 20
        
        
        %period/epoch events
    case 'itiStart'
        ttlValue = 21;
    case 'itiEnd'
        ttlValue = 22;
    case 'centralCueStart'
        ttlValue = 23;
    case 'centralCueEnd'
        ttlValue = 24;
    case 'centralFixationStart'
        ttlValue = 25;
    case 'centralFixationEnd'
        ttlValue = 26;
    case 'choiceStart' %could be same for pacman forage?
        ttlValue = 27;
    case 'choiceEnd'
        ttlValue = 28;
    case 'targetSelectStart' %i.e. hold fixation/selection on target
        ttlValue = 29;
    case 'targetSelectEnd'
        ttlValue = 30;
    case 'feedbackStart'
        ttlValue = 31;
    case 'feedbackEnd'
        ttlValue = 32;
    case 'choice2FeedbackStart'
        ttlValue = 33;
    case 'choice2FeedbackEnd'
        ttlValue = 34;
        %left available 35-50
        
        
        %leave events 51-98, 99 is for unrecongized events
        %could need them for stimulation or something in the future
        
        
        %specifically to be used for tasks like N-back with target & non-target stimuli
    case 'conditional'
        if eventValue > 50 && eventValue < 60
            ttlValue = eventValue;
        else
            ttlValue = 99;%
        end
        
        
        %trial (100-199)/block numbers (201-250)
    case 'trialNumber'
        if eventValue >= 100
            eventValue = eventValue-100*floor(eventValue/100);
        end
        ttlValue = eventValue+100;
        
    case 'blockNumber'
        if eventValue > 50
            eventValue = eventValue-50*floor(eventValue/50);
        end
        ttlValue = eventValue+200;
        %left available 251-255, maybe for master blocks?
        
        
    otherwise
        disp([eventName ', Event Unrecognized...will send event value of 99!'])
        ttlValue = 99;
end

%quick error check, use NaNs for non-valued events
if isnan(ttlValue)
    error('How did a NaN get here?')
end


%---Get Timestamp in Matlab---%
%if flipping screen, then appears to wait for the next screen refresh typically
%running @60 Hz, so we want to run this first before sending TTLs
if screenFlip
    [~, ~, timeStampMatlab, ~] = Screen(screenWindow,'Flip'); 
    %timeStampMatlab = Screen(screenWindow,'Flip');
else
    timeStampMatlab = GetSecs();
end


%---Send TTL value---%
%try to speed up even if not using
eventStr = num2str(ttlValue);

%send ttl pulse
switch ttlStruct.ttlMode
    case 'USB2TTL8'
        %usb2TTL8Str = ['WRITE ' eventStr ' ' num2str(1000*ttlStruct.pulseDuration) '\n']; % Neuralynx reads the leading and falling edge so get extra 0's
        usb2TTL8Str = ['WRITE ' eventStr '\n'];%Neuralynx only reads change then, so don't use repeated values
        fprintf(ttlStruct.serialConn, usb2TTL8Str);
    case 'Plexon'
        PL_DOSetWord(ttlStruct.deviceNumbers, 1, 7, ttlValue );     % This is the event flag number you want to send over.
        PL_DOPulseBit(ttlStruct.deviceNumbers, 24, 0 );       % This pin is connected to Pin 22(White/Black/Orange)and to Pin3 on the NI card, and functions as a Strob
    case 'Python'
        %don't use system call at least 100x slower
        py.writeTTLPython.sendTTL(eventStr);
        %r = py.writeTTLPython.squared(ttlValue); %use to test python call works
    case 'USB-6501'
        bitVector = [1 de2bi(ttlValue,ttlStruct.ttlNumBits)]; %convert ttlValue in to 0's & 1's vector
        outputSingleScan(ttlStruct.serialConn,bitVector);
    case 'BlackrockComment'
        if ttlStruct.neuralRecording
            cbmex('comment',255,0,eventName);
        end
    case 'none'
        %do nothing
    otherwise
        error('Why is the TTL device not connected?')
end

%---Send Eye tracker event value---%
if eyeTrackerConnected
    Eyelink('Message',eventStr);
end


if ttlStruct.pulseDuration <= 2
    WaitSecs(0.002);%in case mutliple strobes in a row, also helps determine real strobes
    %when "splits/doubles" occur on Neuralynx Event files
end
end