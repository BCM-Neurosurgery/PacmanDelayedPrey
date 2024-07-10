function sessionVars = createSessionVars()
%function setups up sessionVars variable...just easier & cleaner to do in
%one function as it's used across multiple tasks. If a task needs more than
%this we can always add more fields. 
%written by Seth Konig 9/8/20

sessionVars = [];

%trial/block number
sessionVars.trialNum = 0;%0; %trial number, always goes up
sessionVars.trialNumInBlock = 0; %trial number in block, resets with each new block
sessionVars.blockNum = 0; %[pseudo] block for TTL pulses

%important event flags
sessionVars.pauseFlag = false;
sessionVars.quitTask = false;
sessionVars.recalibrate = false;

end