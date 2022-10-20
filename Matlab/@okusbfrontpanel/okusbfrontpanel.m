% to extend, read the function list by executing:
% libfunctionsview('okFrontPanel')


classdef okusbfrontpanel < handle
    properties
       hnd % okFrontPanel_HANDLE
       availableDevices
       connectedDevice
       
       verbose = false;
       
       OK_MAX_DEVICEID_LENGTH = 33;
       OK_MAX_SERIALNUMBER_LENGTH = 11;
       OK_MAX_PRODUCT_NAME_LENGTH = 128;
       OK_MAX_BOARD_MODEL_STRING_LENGTH = 128;
       
       MAX_DISPLAY_LENGTH_DEC_NUMBER = 12;
       MAX_DISPLAY_LENGTH_HEX_NUMBER = 8;
       MAX_DISPLAY_LENGTH_BIN_NUMBER = 32;
       
       HR_LENGTH = 96;
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
            calllib('okFrontPanel', 'okFrontPanel_Destruct', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {}, {}, {});
        end
        
        
        
        % @todo: make private to class
        function DisplayOutput(obj, input, inputVarNames, inputDisplay, output, outputVarNames, outputDisplay)
            if obj.verbose
                className = class(obj);
                stack = dbstack('-completenames');
                if numel(stack) >= 2
                    fprintf(1, '%s\n', pad('', obj.HR_LENGTH, 'left', '-'));
                    funcname = stack(2).name((length(className)+2):end);
                    
                    fprintf(1, '%s\n', funcname);
                    for i = 1:numel(input)
                        fprintf(1, 'INPUT    %s: %s\n', pad(inputVarNames{i}, 20, 'left', ' '), obj.ConvertForDisplay(input{i}, inputDisplay{i}));
                    end
                    
                    for i = 1:numel(output)
                        fprintf(1, 'RETURNED %s: %s\n', pad(outputVarNames{i}, 20, 'left', ' '), obj.ConvertForDisplay(output{i}, outputDisplay{i}));
                    end
                else
                    fprintf(1, 'No Caller\n');
                end
            end
        end
        
        
        function output = ConvertForDisplay(obj, number, conversionType)
            if isstring(number) || ischar(number)
                output = ['"', char(number), '"'];
                return;
            end
            
            switch(conversionType)
                case 'd'
                    output = char(sprintf("d'%s", pad(num2str(number), obj.MAX_DISPLAY_LENGTH_DEC_NUMBER, 'left', ' ')));
                case 'h'
                    output = char(sprintf("h'%s", dec2hex(number, obj.MAX_DISPLAY_LENGTH_HEX_NUMBER)));
                case 'b'
                    output = char(sprintf("b'%s", dec2bin(number, obj.MAX_DISPLAY_LENGTH_BIN_NUMBER)));
                case 'all'
                    output = char(strjoin({obj.ConvertForDisplay(number, 'd'), obj.ConvertForDisplay(number, 'h'), obj.ConvertForDisplay(number, 'b')}, ', '));
                case 's'
                    output = ['"', char(number), '"'];
                case 'bool'
                    if number == 1
                        output = 'true';
                    else
                        output = 'false';
                    end
            end
        end
        
        
        
        function obj = DisplayComment(obj, comment)
            fprintf(1, '\n\n%s\n', pad('', obj.HR_LENGTH + 10, 'left', '='));
            fprintf(1, '%s\n', pad(sprintf('COMMENT: %s   ', comment), obj.HR_LENGTH + 10, 'right', '='));
            
            %fprintf(1, '\n%s\n', pad('', obj.HR_LENGTH + 10, 'left', '='));
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
            obj.DisplayOutput({}, {}, {},...
                              {tf}, {'tf'}, {'bool'});
        end
        
        
        
        function tf = IsRemote(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsRemote', obj.hnd);
            obj.DisplayOutput({}, {}, {},...
                              {tf}, {'tf'}, {'bool'});
        end
        
        
        
        function boardModel = GetBoardModel(obj)
            boardModel = calllib('okFrontPanel', 'okFrontPanel_GetBoardModel', obj.hnd); 
            obj.DisplayOutput({}, {}, {},...
                              {boardModel}, {'boardModel'}, {'s'});
        end
        
        
        
        function tf = IsHighSpeed(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsHighSpeed', obj.hnd);
            obj.DisplayOutput({}, {}, {},...
                              {tf}, {'tf'}, {'bool'});
        end
        
        
        
        function errorCode = OpenBySerial(obj, serial)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_OpenBySerial', obj.hnd, serial);
            
            if strcmp(errorCode, 'ok_NoError')
                obj.GetDeviceList();
            end
            
            obj.DisplayOutput({serial}, {'serial'}, {'s'},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        function Close(obj)
            calllib('okFrontPanel', 'okFrontPanel_Close', obj.hnd);
            
            obj.GetDeviceList();
            
            obj.DisplayOutput({}, {}, {},...
                              {}, {}, {});
        end
        
        
        
        function errorCode = ResetFPGA(obj)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_ResetFPGA', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        function sn = GetSerialNumber(obj)
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetSerialNumber', obj.hnd, blanks(obj.OK_MAX_SERIALNUMBER_LENGTH));
            
            obj.DisplayOutput({}, {}, {},...
                              {sn}, {'sn'}, {'s'});
        end
        
        
        
        function minorVersion = GetDeviceMinorVersion(obj)
            minorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMinorVersion', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {minorVersion}, {'minorVersion'}, {'s'});
        end
        
        
        
        function majorVersion = GetDeviceMajorVersion(obj)
            majorVersion = calllib('okFrontPanel', 'okFrontPanel_GetDeviceMajorVersion', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {majorVersion}, {'majorVersion'}, {'s'});
        end
        
        
        
        function deviceID = GetDeviceID(obj)
            [~, deviceID] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceID', obj.hnd, blanks(obj.OK_MAX_DEVICEID_LENGTH));
            
            obj.DisplayOutput({}, {}, {},...
                              {deviceID}, {'deviceID'}, {'s'});
        end
        
        
        
        function tf = IsFrontPanelEnabled(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsFrontPanelEnabled', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {tf}, {'tf'}, {'bool'});
        end
        
        
        
        function tf = IsFrontPanel3Supported(obj)
            tf = calllib('okFrontPanel', 'okFrontPanel_IsFrontPanel3Supported', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {tf}, {'tf'}, {'bool'});
        end
        
        
        
        function count = GetDeviceCount(obj)
            count = calllib('okFrontPanel', 'okFrontPanel_GetDeviceCount', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {count}, {'count'}, {'d'});
        end
        
        
        
        function boardModel = GetDeviceListModel(obj, num)
            boardModel = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListModel', obj.hnd, num);
            
            obj.DisplayOutput({num}, {'num'}, {'d'},...
                              {boardModel}, {'boardModel'}, {'s'});
        end
        
        
        
        function sn = GetDeviceListSerial(obj, num)
            [~, sn] = calllib('okFrontPanel', 'okFrontPanel_GetDeviceListSerial', obj.hnd, num, blanks(obj.OK_MAX_SERIALNUMBER_LENGTH));
            
            obj.DisplayOutput({num}, {'num'}, {'d'},...
                              {sn}, {'sn'}, {'s'});
        end
        
        
        
        function errorCode = UpdateWireOuts(obj)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_UpdateWireOuts', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        function wireOutValue = GetWireOutValue(obj, epAddr)
            obj.UpdateWireOuts();
            
            wireOutValue = calllib('okFrontPanel', 'okFrontPanel_GetWireOutValue', obj.hnd, int32(epAddr));
            
            obj.DisplayOutput({epAddr}, {'epAddr'}, {'all'},...
                              {wireOutValue}, {'wireOutValue'}, {'all'});
        end
        
        
        
        function errorCode = UpdateWireIns(obj)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_UpdateWireIns', obj.hnd);
            
            obj.DisplayOutput({}, {}, {},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        function [errorCode, wireInValue] = GetWireInValue(obj, epAddr)
            [errorCode, ~, wireInValue] = calllib('okFrontPanel', 'okFrontPanel_GetWireInValue', obj.hnd, int32(epAddr), uint32(0));
            
            if ~strcmp(errorCode, 'ok_NoError')
                wireInValue = NaN;
            end
            
            obj.DisplayOutput({epAddr}, {'epAddr'}, {'all'},...
                              {errorCode, wireInValue}, {'errorCode', 'wireInValue'}, {'s', 'all'});
        end
        
        
        
        function errorCode = SetWireInValue(obj, epAddr, value, mask)
            % Wire in and wire out values may not be set on the FPGA until
            % 'UpdateWire[In|Out]s' is called. This behavior is device
            % dependent.
            errorCode = calllib('okFrontPanel', 'okFrontPanel_SetWireInValue', obj.hnd, int32(epAddr), uint32(value), uint32(mask));
            
            obj.UpdateWireIns();
            
            obj.DisplayOutput({epAddr, value, mask}, {'epAddr', 'value', 'mask'}, {'all', 'all', 'all'},...
                              {errorCode}, {'errorCode'}, {'s'});
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
              
              obj.DisplayOutput({}, {}, {},...
                                {deviceInfo.deviceID, deviceInfo.serialNumber, deviceInfo.productName}, {'deviceID', 'serialNumber', 'productName'}, {'s', 's', 's'});
        end
        
        
        
        function errorCode = ConfigureFPGA(obj, filename)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_ConfigureFPGA', obj.hnd, filename);
            
            obj.DisplayOutput({filename}, {'filename'}, {'s'},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        function [errorCode, data] = ReadRegister(obj, regAddr)
           [errorCode, ~ , data] = calllib('okFrontPanel', 'okFrontPanel_ReadRegister', obj.hnd, uint32(regAddr), uint32(0));
           
           if ~strcmp(errorCode, 'ok_NoError')
                data = NaN;
           end
           
           obj.DisplayOutput({regAddr}, {'regAddr'}, {'all'},...
                             {errorCode, data}, {'errorCode', 'data'}, {'s', 'all'});
        end
        
        
        
        function errorCode = WriteRegister(obj, regAddr, data)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_WriteRegister', obj.hnd, uint32(regAddr), uint32(data));
            
            obj.DisplayOutput({regAddr, data}, {'regAddr', 'data'}, {'all', 'all'},...
                              {errorCode}, {'errorCode'}, {'s'});
        end
        
        
        
        % @todo: probably wrong
        function errorCode = WriteToPipeIn(obj, epAddr, data)
            errorCode = calllib('okFrontPanel', 'okFrontPanel_WriteToPipeIn', obj.hnd, int32(epAddr), int64(length(data)), char(data));
            
            obj.DisplayOutput({epAddr, length(data), char(data)}, {'epAddr', 'length', 'data'}, {'all', 'all', 's'},...
                {errorCode}, {'errorCode'}, {'s'});
        end
    end
end