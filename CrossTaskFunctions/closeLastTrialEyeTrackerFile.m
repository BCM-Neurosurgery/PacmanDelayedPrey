function closeLastTrialEyeTrackerFile(trialnum,fileStruct)
%close last trial's edf file or pre-trial file if trialnum == 1, else
%subtract one trial from current trial count to move file
%function written by Seth Konig 2/18/2020
%
% Inputs:
%   1) trialnum: trial number
%   2) fileStruct: structure containing file names and folder paths
% 
% Outputs:
%   none) saves and renames edf file name in appropraite file directory

fileBaseName = fileStruct.fileBaseName;
eyeDataFolder = fileStruct.eyeDataFolder;

%---Stop Recording & Close Old EDF File---%
Eyelink('Command', 'set_idle_mode');
status=Eyelink('closefile');
if status ~=0
    disp('closefile error, status');
% else
%     disp('file closed correctly');
end

%---Transfer OlD EDF File to Behavior Computer---%
%only can use up to 8 chars for file name, so will have to rename later
if trialnum == 1 %this is to store all eye data including calibraiton...hopefully
    old_EDFname = [fileBaseName(1:4) '_pre.edf'];
else
    old_EDFname = [fileBaseName(1:4) '_' num2str(trialnum-1) '.edf'];
end

status = Eyelink('ReceiveFile', old_EDFname, eyeDataFolder, 1);
if status < 0 % Negative: error code; positive: size of the file; zero: file transfer was cancelled.
    fprintf('problem: ReceiveFile status: %d\n', status);
end

if exist([eyeDataFolder old_EDFname], 'file')
    %fprintf('Data file ''%s'' can be found in ''%s''\n', old_EDFname, eyeDataFolder);
    
    %rename folder with full folder name since want unique file names & Eyelink only acccepts 8 chars
    if trialnum == 1
        movefile([eyeDataFolder old_EDFname],[eyeDataFolder fileBaseName '_preTrial.edf'])
    else
        movefile([eyeDataFolder old_EDFname],[eyeDataFolder fileBaseName '_' num2str(trialnum-1) '.edf'])
    end
else
    error([eyeDataFolder old_EDFname, ' where did the EDF file get copied to?'])
end

end