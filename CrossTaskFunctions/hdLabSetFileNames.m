function [fileBaseName,subjectTaskDataDir,subjDataDir] = hdLabSetFileNames(subjID,taskName)
%create unqiue filenames for every task with consitent data structure
%written by Seth Konig 2/17/2020
%
% Inputs: 
%   1) subjID: subject identification/name
%   2) taskName: name of task
%
% Outputs:
%   1) fileBaseName: base file name for all files generated during a task, excludes trial number and other suffixes
%   2) subjectTaskDataDir: file path of where data will be stored across all tasks
%   3) subjDataDir: specific file path for this task's data
%   #) makes directories if they don't exist.

%store data in documents folder for all tasks and patients
taskDataDir = [userpath filesep 'PatientData' filesep]; % CHANGE BY JA & RM TO ACCOUNT FOR BAYLOR EMU CURRENT FILE HANDLING (From 'userpath' to 'pwd') 
% taskDataDir = [pwd filesep 'PatientData' filesep]; % CHANGE BY JA & RM TO ACCOUNT FOR BAYLOR EMU CURRENT FILE HANDLING (From 'userpath' to 'pwd') 

%---Determine if subject Data Directory Exists/Make it---%
subjectTaskDataDir = [taskDataDir subjID filesep taskName filesep];

if ~exist(subjectTaskDataDir,'dir')
    mkdir(subjectTaskDataDir)
end

dateStr = datestr(now, 'yyyymmdd_HHMMSS');
fileBaseName = [taskName '__' subjID '__' dateStr];
subjDataDir = [subjectTaskDataDir fileBaseName filesep];

if exist(subjDataDir,'dir') == 7
    error('Why does specific Subject Data Directory exist if folder name is data-timestamped?')
else
    mkdir(subjDataDir)
end

end