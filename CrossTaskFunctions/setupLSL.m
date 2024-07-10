function lslInlet = setupLSL()
%function links Matlab to lab streaming layer (LSL) to collect EEG data during task in real time.
%written by Seth Konig 11/2/2020 based on Tay's code.
%Code modified, cleaned up, & integrated into github repo by Seth Konig 2/28/22

%add path for realitme collection of eeg data
addpath(genpath('C:\Users\hdlab\Documents\labstreaminglayer\LSL\liblsl-Matlab'));
lib = lsl_loadlib();

%resolve a stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end

% create a new lsl inlet (aka streaming object)
disp('Opening an inlet...');
lslInlet = lsl_inlet(result{1});

end