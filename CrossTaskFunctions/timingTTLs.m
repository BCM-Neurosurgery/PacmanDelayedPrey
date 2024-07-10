function [lastTimerTTLEvent,lastTTLTime] = timingTTLs(lastTTLTime,lastTimerTTLEvent,ttlStruct,visEnviro,genericOpts)
%sends timing TTLs
%uses 2 TTL values because it won't recognize two equal consecutive values
if GetSecs()-lastTTLTime >= 10
    lastTTLTime = GetSecs();
    if lastTimerTTLEvent %odd event
        markEvent('timingPulse1',NaN,ttlStruct,visEnviro.screen.window,genericOpts.eyeParams.eyeTrackerConnected,0);
        lastTimerTTLEvent = false;
    else %even event
        markEvent('timingPulse2',NaN,ttlStruct,visEnviro.screen.window,genericOpts.eyeParams.eyeTrackerConnected,0);
        lastTimerTTLEvent = true;
    end
end
end