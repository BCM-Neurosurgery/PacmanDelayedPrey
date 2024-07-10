function hdLabCloseTTLDevice(ttlStruct)
%closes ttl devices; currently supports USB2TTL8 8 plexon/NiDAQ. Python TTL
%mode does not require setup because does this as it sends.
%
%written by Seth Konig 2/20/20, compiled code from various places
%
% Inputs:
%   1) ttlStruct: TTL structure containing information about TTL device
%
% Outputs:
%   none) closes TTL device/ports in hardware speific manner

switch ttlStruct.ttlMode
    case  'USB2TTL8'
        if strcmpi(ttlStruct.serialConn.Status,'open')
            fclose(ttlStruct.serialConn);
        else
            return; %nothing to do
        end
        
    case 'Plexon'
        isFound  = PL_DOInitDevice(ttlStruct.deviceNumbers, 0);
        if isFound == 0 %device found
            % Should be called to release hardware devices before the client terminates.
            PL_DOReleaseDevices();
        else
            return; %nothing to do
        end
        
    case 'Python'
        %nothing to do so return
        return;
        
    case 'USB-6501'
        release(ttlStruct.serialConn);
        
    case 'BlackrockComment'
        %nothing to do so return
        return
        
    case 'none'
        %nothing to do so return
        return;
        
    otherwise
        error('TTL mode not recongnized!')
end


end