%Script shows how to use and test various TTL pulse hardware/software
%outside of specific tasks. 
%Written by Seth Konig 2/21/20

clear, clc, close all

doFlipScreen = true;

%all current as of 2/21/20
allEventNames = {'taskStart','taskStop','taskPaused','taskResume','taskQuit','recalibrateStart','recalibrateEnd',...
    'trialStart','trialEnd','unrewarded','reward','eventTimeout','breakFixation','userInput','itiStart','itiEnd',...
    'centralCueStart','centralCueEnd', 'centralFixationStart','centralFixationEnd','choiceStart','choiceEnd',...
    'targetSelectStart','targetSelectEnd','feedbackStart','feedbackEnd','trialNumber','blockNumber',...
    'testPulse',... %test pulse is not a real pulse name...it's just for testing the otherwise condition!
    };

numPulses = 1e3;
allEventValues = randi([1 250],1,numPulses); %251-255 reserved
zeroDiff = find(diff(allEventValues) == 0);
%USB2TTL8 only shows TTL pulses when value is not the same! Helps with
%debugging in general too.
while ~isempty(zeroDiff)     
    allEventValues(zeroDiff) = allEventValues(zeroDiff)+1;
    zeroDiff = find(diff(allEventValues) == 0);
end

randIndex =randi([1 length(allEventNames)],1,numPulses);
ttlValues = NaN(1,numPulses);
ttlTimes = NaN(1,numPulses);
%%
%---Set up TTL System---%
%make sure environment parmaters are correct
rig = defaultRig_params();%get environment parameters
ttlStruct = hdLabSetupTTLDevice(rig);


%---Setu Screen---%
if doFlipScreen
    visEnviro = hdLabSetupScreen();
    screenWindow = visEnviro.screen.window;
else
   screenWindow = NaN; 
end

%%
tic
startTime = GetSecs();
for nP = 1:numPulses
    [ttlTimes(nP),ttlValues(nP)] = markEvent(allEventNames{randIndex(nP)},allEventValues(nP),...
        ttlStruct,screenWindow,false,doFlipScreen); %run without screen flipping & eye tracker connected
    WaitSecs(0.25);
end
endTime = GetSecs();
toc

psychTime = endTime-startTime;

%%
closeTask(ttlStruct); %closes everything