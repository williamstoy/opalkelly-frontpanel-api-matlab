classdef okusbfrontpanel < handle
    properties
       hnd % okFrontPanel_HANDLE
       devices
    end
    
    methods
        function obj = okusbfrontpanel
            if ~libisloaded('okFrontPanel')
                loadlibrary('okFrontPanel');
            end
            
            obj.hnd = calllib('okFrontPanel', 'okFrontPanel_Construct');
        end
        
        function delete(obj)
            disp('   DELETING OKUSBFRONTPANEL OBJECT.');
            calllib('okFrontPanel', 'okFrontPanel_Destruct', obj.hnd); 
        end
        
        function obj = getDeviceList(obj)
            num = obj.GetDeviceCount();
            d.model = '';
            d.serial = '';
            obj.devices = struct(d);

            for j = 1:num
                obj.devices(j).model = obj.GetDeviceListModel(j-1);
                obj.devices(j).serial = obj.GetDeviceListSerial(j-1);
            end
        end
        
        function tf = IsOpen(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsOpen', obj.hnd);
        end
        
        function tf = IsRemote(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsRemote', obj.hnd);
        end
        
        function boardModel = GetBoardModel(obj)
            boardModel = calllib('okFrontPanel', 'okFrontPanel_GetBoardModel', obj.hnd); 
        end
        
        function tf = IsHighSpeed(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsHighSpeed', obj.hnd); 
        end
        
        function errorCode = OpenBySerial(obj, serial)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_OpenBySerial', obj.hnd, serial);
        end
        
        function Close(obj)
            calllib('okFrontPanel', 'okFrontPanel_Close', obj.hnd);
        end
        
        function errorCode = ResetFPGA(obj)
             errorCode = calllib('okFrontPanel', 'okFrontPanel_ResetFPGA', obj.hnd);
        end
        
        function sn = GetSerialNumber(obj)
            % The header defines this function as returning null, but the
            % second return value contains the string. Also, we don't pass
            % a pointer here, we pass a blank string
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetSerialNumber', obj.hnd, blanks(11));
        end
        
        function minorVersion = GetDeviceMinorVersion(obj)
            minorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMinorVersion', obj.hnd);
        end
        
        function majorVersion = GetDeviceMajorVersion(obj)
            majorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMajorVersion', obj.hnd);
        end
        
        function deviceID = GetDeviceID(obj)
            [~, deviceID] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceID', obj.hnd, blanks(30));
        end
        
        function tf = IsFrontPanelEnabled(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsFrontPanelEnabled', obj.hnd);
        end
        
        function tf = IsFrontPanel3Supported(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsFrontPanel3Supported', obj.hnd);
        end
        
        function count = GetDeviceCount(obj)
            count = calllib('okFrontPanel', 'okFrontPanel_GetDeviceCount', obj.hnd);
        end
        
        function boardModel = GetDeviceListModel(obj, num)
            boardModel = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListModel', obj.hnd, num);
        end
        
        function sn = GetDeviceListSerial(obj, num)
            % The header defines this function as returning null, but the
            % second return value contains the string. Also, we don't pass
            % a pointer here, we pass a blank string
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListSerial', obj.hnd, num, blanks(11));
        end
    end
end