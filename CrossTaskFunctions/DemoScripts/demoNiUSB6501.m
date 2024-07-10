%Tests basic Digital Output with NI USB-6501 using Matlab DAQ toolbox.
%Seth Koenig 2/27/2020

clear,clc

d = daq.getDevices;
deviceNum = 1;
if isempty(d)
    error('No DAQ entities found!')
elseif ~strcmpi(d(deviceNum).Model,'USB-6501')
   error('This script was made only  for Ni USB-6501...please fix the script!') 
end


s = daq.createSession('ni');
ch = addDigitalChannel(s,'dev1','Port0/Line0','OutputOnly');%this is strobe bit?
ch = addDigitalChannel(s,'dev1','Port1/Line0:7','OutputOnly');
for i = 1:255
    outputSingleScan(s,[1 de2bi(i,8)]);
    WaitSecs(0.25);
end