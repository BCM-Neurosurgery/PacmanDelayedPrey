%---Code for Running Through System Call---%
%timing here may be unreliable

pythonTTLDir = 'C:\Users\hdlab\Documents\Task_iEEG_GithubRepo\CrossTaskFunctions\PythonTTL\';
cd(pythonTTLDir)
pauseTime = 0.25;

tic
for val = 1:255
    systemCommand = ['python writeTTLPython.py ' num2str(val)];
    system(systemCommand);
    WaitSecs(pauseTime);
end
toc

%---Pause again so we can tell timing in same recording
WaitSecs(pauseTime*10);


%---Code for Running Through Python Interface---%
%timing here should be pretty reliable
tic
for val = 1:255
    py.writeTTLPython.sendTTL(num2str(val))
    WaitSecs(pauseTime);
end
toc
