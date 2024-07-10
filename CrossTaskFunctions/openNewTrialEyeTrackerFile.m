function openNewTrialEyeTrackerFile(trialnum,baseFileName)
%creates a new edf file on EyeLink eye tracker comptuer. 
%written by Seth Konig 2/18/20/20
%
% Inputs:
%   1) trialnum: trial number
%   2) baseFileName: base file name; only uses 1st 4 characters since
%   Eyelink has a maximum of 8 characters and remainder are saved for trial
%   number
%
% Outputs:
%   none) creates new EDF file on eye tracker computer

%---Create New EDF file and Starte Recording---%
%Eyelink only accepts file names 8 characters long
new_EDFname = [baseFileName(1:4), '_', num2str(trialnum), '.edf'];
Eyelink( 'Openfile', new_EDFname );

% Start recording every trials
Eyelink('StartRecording');

end