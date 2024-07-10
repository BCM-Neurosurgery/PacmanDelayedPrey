function ttlStruct = hdLabSetupTTLDevice(ttlOptions)
%Setups ttl devices; currently supports USB2TTL8 8 plexon/NiDAQ. Python TTL
%mode does not require setup because does this as it sends.
%
%written by Seth Konig 2/20/20, compiled code from various places
% 
% Inputs:
%   1) ttlOptions: structure containing information about TTL options e.g.
%   hardware mode
%
% Outputs:
%   1) ttlStruct: structure containing information about connected TTl
%   devices as well as a few recapitulated TTL options necessary for
%   functions to communicated with TTL device.
%   #) opens/connects TTL device

%creat new struct so don't have to pass ttlOptions everywhere too
ttlStruct = [];
ttlStruct.pulseDuration = ttlOptions.ttlDuration;
ttlStruct.ttlMode = ttlOptions.ttlMode; 
ttlStruct.ttlPort = ttlOptions.ttlPort;
ttlStruct.ttlNumBits = ttlOptions.ttlNumBits;


switch ttlOptions.ttlMode
    case  'USB2TTL8'
        ttlStruct.serialConn = serial(ttlOptions.ttlPort,'BaudRate', 128000, 'DataBits', 8);
        fopen(ttlStruct.serialConn);
        
        if ~strcmpi(ttlStruct.serialConn.Status,'open')
            error('Serial port for USB2TTL8 could not be opened!')
        end
        
        
    case 'Plexon'
        warning('Plexon library is outdated/unstable. I strongly recommend not using!')
        %get Plexon_SDK folder path and add to Path if not already!
        findingDevice = true;
        findAttempts = 0;
        while findingDevice && findAttempts < 100
            thisFunctionPath = mfilename('fullpath');
            slash = strfind(thisFunctionPath,filesep);
            thisFunctionPath = thisFunctionPath(1:slash(end));
            addpath([thisFunctionPath filesep 'PlexDoSDK']);
            
            isFound  = PL_DOInitDevice(ttlOptions.ttlDeviceNumber, 0);
            
            if isFound == 0 %device found
                [numDOCards, deviceNumbers, numBits, numLines] = PL_DOGetDigitalOutputInfo;
                [getDeviceStringResult, deviceString] = PL_DOGetDeviceString(ttlOptions.ttlDeviceNumber);
                ttlStruct.deviceNumbers = deviceNumbers(ttlOptions.ttlDeviceNumber);
                findingDevice = false;
                disp(['NiDAQ device connected on ' num2str(findAttempts+1) ' attempt!'])
            end
            
            findAttempts = findAttempts + 1;
            WaitSecs(0.05);
        end
        
        %device is buggy and not always officially connected and
        %working...not 100% sure why 
        if findAttempts == 100
            disp('NiDAQ device not officially connected. Device should still work')
            ttlStruct.deviceNumbers = ttlOptions.ttlDeviceNumber;
        end
        
    case 'Python'
        %add to path python folder to Matlab and python paths
        thisFunctionPath = mfilename('fullpath');
        slash = strfind(thisFunctionPath,filesep);
        thisFunctionPath = thisFunctionPath(1:slash(end));
        addpath([thisFunctionPath filesep 'PythonTTL']);
        
        %check that pthon script is in path so can call later, if not add path
        %if count(py.sys.path,[thisFunctionPath filesep 'PythonTTL']) == 0 %doesn't seem to work well but Matlab says to use this
        insert(py.sys.path,int32(0),[thisFunctionPath filesep 'PythonTTL']);
        %end
        
    case 'USB-6501'
        %A NiDAQ device connected with Matlab DAQ toolbox
        d = daq.getDevices;
        if isempty(d)
            error('No DAQ entities found!')
        elseif ~strcmpi(d(ttlOptions.ttlDeviceNumber).Model,'USB-6501')
            error('This script was made only  for Ni USB-6501...please fix the script!')
        end

        ttlStruct.serialConn = daq.createSession('ni'); %create NI device 
        if ttlOptions.ttlNumBits == 8 %may only be able to use 8
            %setup channels as output only, Port0/Line0 is strobe bit
            ch = addDigitalChannel(ttlStruct.serialConn,'dev1','Port0/Line0','OutputOnly');%this is strobe bit?
            ch = addDigitalChannel(ttlStruct.serialConn,'dev1','Port1/Line0:7','OutputOnly');
        else
           error('Please specify channel layout for differnt number of channels!'); 
        end
        
    case 'BlackrockComment'
        ttlStruct.neuralRecording = ~ttlOptions.neuralRecording;
        %nothing to do so return
        return
    case 'none'
        %nothing to do so return
        return;
        
    otherwise
        error('TTL mode not recongnized! Please make sure you use proper case-sensitive names!')
end

WaitSecs(0.25);
end