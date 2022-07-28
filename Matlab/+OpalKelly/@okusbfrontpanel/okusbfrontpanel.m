% to extend, read the function list by executing:
% libfunctionsview('okFrontPanel')


classdef okusbfrontpanel < handle
    properties
       hnd % okFrontPanel_HANDLE
       availableDevices
       connectedDevice
       
       OK_MAX_DEVICEID_LENGTH = 33;
       OK_MAX_SERIALNUMBER_LENGTH = 11;
       OK_MAX_PRODUCT_NAME_LENGTH = 128;
       OK_MAX_BOARD_MODEL_STRING_LENGTH = 128;
    end
    
    methods
        function obj = okusbfrontpanel
            if ~libisloaded('okFrontPanel')
                loadlibrary('okFrontPanel');
            end
            
            obj.hnd = calllib('okFrontPanel', 'okFrontPanel_Construct');
            
            obj.GetDeviceList();
        end
        
        function delete(obj)
            disp('DELETING OKUSBFRONTPANEL OBJECT.');
            calllib('okFrontPanel', 'okFrontPanel_Destruct', obj.hnd); 
        end
        
        function obj = GetDeviceList(obj)
            % update the connected device information
            obj.connectedDevice = [];
            if obj.IsOpen()
                obj.connectedDevice = obj.GetDeviceInfo();
            end
            
            % Get the list of OK devices that are available for connection
            obj.availableDevices = [];
            
            num = obj.GetDeviceCount();
            for j = 1:num
                obj.availableDevices(j).boardModel = obj.GetDeviceListModel(j-1);
                obj.availableDevices(j).serialNumber = obj.GetDeviceListSerial(j-1);
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
            
            if strcmp(errorCode, 'ok_NoError')
                obj.GetDeviceList();
            end
        end
        
        function Close(obj)
            calllib('okFrontPanel', 'okFrontPanel_Close', obj.hnd);
            
            obj.GetDeviceList();
        end
        
        function errorCode = ResetFPGA(obj)
             errorCode = calllib('okFrontPanel', 'okFrontPanel_ResetFPGA', obj.hnd);
        end
        
        function sn = GetSerialNumber(obj)
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetSerialNumber', obj.hnd, blanks(obj.OK_MAX_SERIALNUMBER_LENGTH));
        end
        
        function minorVersion = GetDeviceMinorVersion(obj)
            minorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMinorVersion', obj.hnd);
        end
        
        function majorVersion = GetDeviceMajorVersion(obj)
            majorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMajorVersion', obj.hnd);
        end
        
        function deviceID = GetDeviceID(obj)
            [~, deviceID] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceID', obj.hnd, blanks(obj.OK_MAX_DEVICEID_LENGTH));
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
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListSerial', obj.hnd, num, blanks(obj.OK_MAX_SERIALNUMBER_LENGTH));
        end
        
        function errorCode = UpdateWireOuts(obj)
            % Unsupported Feature for ok_brdXEM7350K160T
            errorCode = calllib('okFrontPanel', 'okFrontPanel_UpdateWireOuts', obj.hnd);
        end
        
        function wireOutValue = GetWireOutValue(obj, epAddr)
            obj.UpdateWireOuts();
            wireOutValue = calllib('okFrontPanel', 'okFrontPanel_GetWireOutValue', obj.hnd, int32(epAddr));
        end
        
        function errorCode = UpdateWireIns(obj)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_UpdateWireIns', obj.hnd);
        end
        
        function [errorCode, wireInValue] = GetWireInValue(obj, epAddr)
            [errorCode, ~, wireInValue] = calllib('okFrontPanel', 'okFrontPanel_GetWireInValue', obj.hnd, int32(epAddr), uint32(0));
            
            if ~strcmp(errorCode, 'ok_NoError')
                wireInValue = NaN;
            end
        end
        
        function errorCode = SetWireInValue(obj, ep, value, mask)
            % Wire in and wire out values may not be set on the FPGA until
            % 'UpdateWire[In|Out]s' is called. This behavior is device
            % dependent.
            errorCode = calllib('okFrontPanel', 'okFrontPanel_SetWireInValue', obj.hnd, ep, value, mask);
        end
        
        function deviceInfo = GetDeviceInfo(obj)
              % Totaling up all data types in the okTDeviceInfo struct
              % definition from header suggests length should be 234.
              % However, when deviceInfoSize=234, structure is not complete
              % Empirical results showed 284 is max size.
              % When deviceInfoSize=285 an empty struct is returned
              deviceInfoSize = 284;
              [errorCode, ~, deviceInfo] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceInfoWithSize', obj.hnd, struct(), deviceInfoSize);
              
              if strcmp(errorCode, 'ok_NoError')
                  deviceInfo.deviceID = deblank(char(deviceInfo.deviceID));
                  deviceInfo.serialNumber = deblank(char(deviceInfo.serialNumber));
                  deviceInfo.productName = deblank(char(deviceInfo.productName));
              end
        end
        
        function errorCode = ConfigureFPGA(obj, filename)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_ConfigureFPGA', obj.hnd, filename);
        end
        
        function settings = GetDeviceSettings(obj)
            
        end
    end
end