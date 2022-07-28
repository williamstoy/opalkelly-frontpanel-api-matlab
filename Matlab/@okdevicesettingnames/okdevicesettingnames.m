classdef okdevicesettingnames < handle
    properties
        hnd %okDeviceSettingNames_HANDLE
    end
    
    methods
        function obj = okdevicesettingnames
            if ~libisloaded('okFrontPanel')
                loadlibrary('okFrontPanel');
            end
           
            obj.hnd = calllib('okFrontPanel', 'okDeviceSettingNames_Construct');
        end
        
        function delete(obj)
            calllib('okFrontPanel', 'okDeviceSettingNames_Destruct', obj.hnd);
        end
        
        function settingName = Get(obj, num)
            settingName = calllib('okFrontPanel', 'okDeviceSettingNames_Get', obj.hnd, int32(num));
        end
        
        function settingsCount = GetCount(obj)
            settingsCount = calllib('okFrontPanel', 'okDeviceSettingNames_GetCount', obj.hnd);
        end
    end
end