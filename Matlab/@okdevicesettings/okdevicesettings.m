classdef okdevicesettings < handle
    properties
        hnd %okDeviceSettings_HANDLE
        deviceSettingNames
    end
    
    methods
        function obj = okdevicesettings
            if ~libisloaded('okFrontPanel')
                loadlibrary('okFrontPanel');
            end
           
            obj.hnd = calllib('okFrontPanel', 'okDeviceSettings_Construct');
            obj.deviceSettingNames = OpalKelly.okdevicesettingnames();
        end
        
        function delete(obj)
            calllib('okFrontPanel', 'okDeviceSettings_Destruct', obj.hnd);
        end
        
        function errorCode = List(obj)
            % currently returning 'ok_InvalidParameter'
            errorCode = calllib('okFrontPanel', 'okDeviceSettings_List', obj.hnd, obj.deviceSettingNames.hnd);
        end
    end
end