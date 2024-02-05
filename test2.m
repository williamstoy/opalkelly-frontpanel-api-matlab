clear; clc;

folder = 'C:\Users\williamstoy\Documents\vivado\projects\fp_testbench\fp_testbench.runs\impl_1\';
filename = 'clock_tester_wrapper.bit';

okobj = okusbfrontpanel();
okobj.verbose = true;

if isempty(okobj.availableDevices)
    disp('No Opal Kelly Devices Found');
    return;
end

% btpipein80 raddr
% btpipeouta0 read
% btpipein81 waddr
% btpipein82 write

% open the first opal kelly device
okobj.OpenBySerial(okobj.availableDevices(1).serialNumber);

okobj.ConfigureFPGA([folder filename]);

okobj.GetDeviceSettings();
okobj.DeviceSettingsSetInt('XEM7350_FAN_MODE', 0);
okobj.DeviceSettingsSetInt('XEM7350_FAN_ENABLE', 1);
okobj.DeviceSettingsSetInt('FMC1_VADJ_VOLTAGE', 250);
okobj.DeviceSettingsSetInt('FMC1_VADJ_ENABLE', 1);
okobj.DeviceSettingsSetInt('FMC1_VADJ_MODE', 3);
okobj.DeviceSettingsGetInt('FMC1_STATUS');
okobj.DeviceSettingsSave();

woOKClock         = hex2dec('20');
woADCClock        = hex2dec('21');
woADCJESDClk      = hex2dec('22');
triggerAddress    = hex2dec('40');

okfs = 100.8;

okobj.ActivateTriggerIn(triggerAddress, 0);

okobj.DisplayComment('Clock Count');
ok_count = okobj.GetWireOutValue(woOKClock);

okobj.DisplayComment('JESD Clock Count');
jesd_clock_count = okobj.GetWireOutValue(woADCJESDClk);

okobj.DisplayComment('ADC Clock');
adc_count = okobj.GetWireOutValue(woADCClock);

disp('CLK_LAO');
disp(okfs * adc_count / ok_count);
disp('JESD_CLK');
disp(okfs * jesd_clock_count / ok_count);

okobj.DisplayComment('Disconnect from FPGA');
okobj.verbose = 0;
okobj.Close();

clear okobj;

function AXI4liteWriteAndConfirm(obj, address, data)
    verbosity = obj.verbose;
    obj.verbose = 0;
    initialValue = AXI4liteRead(obj, address);
    AXI4liteWrite(obj, address, data);
    bresp = obj.GetWireOutValue(hex2dec('23'));
    setValue = AXI4liteRead(obj, address);
    
    if bresp ~= 0
        cprintf([0.75, 0, 0], 'BRESP: error writing to %s (value=%i)\n', address, bresp);
    end
    
    if initialValue == hex2dec(data)
        cprintf([0.5, 0.5, 0], 'Value was already set to commanded data\n');
    else
        if initialValue == setValue
            cprintf([0.75, 0, 0], 'ERROR: write did not succeed (value before and after write are the same)\n');
        else
            cprintf([0, 0.75, 0], sprintf('Value at ADDRESS (0x%s) was set to (0x%s) successfully!\n', address, dec2hex(setValue)));
        end
    end
    obj.verbose = verbosity;
end

function output = queryBits(decValue, bitIndicies)
    binArray = fliplr(hexToBinaryVector(dec2hex(decValue), 32));
    output = binArray(bitIndicies+1);
end

function output = AXI4liteRead(obj, address)
    output = AXI4liteSend(obj, 0, 0, 1, '000', '0', address);
end

function AXI4liteWrite(obj, address, data)
    AXI4liteSend(obj, 0, 1, 0, address, data, '000');
end

function AXI4liteReset(obj)
    AXI4liteSend(obj, 1, 0, 0, '000', '0', '000');
end

function output = AXI4liteSend(obj, resetBit, writeBit, readBit, axi_waddr, axi_wdata, axi_raddr)
    output = '';
    
    controlBits = [...
        zeros(1, 32-3), readBit, writeBit, resetBit,... % control bits
        hexToBinaryVector(axi_waddr, 32),... % write address
        hexToBinaryVector(axi_wdata, 32),... % write data
        hexToBinaryVector(axi_raddr, 32)...  % read address
    ];
    
    % @todo: this whole operation seems very convoluted, simplify
    controlBytes = reshape(...
        controlBits,...
        8,...
        16 ...
    );

    a = [];
    for i = 1:16
        a(i) = bin2dec(num2str(controlBytes(:,i)'));
    end
    
    % FrontPanel API 3.3.3 Byte Order (USB 3.0):
    % When writing to Pipe Ins, the first byte written is transferred over
    % the lower order bits of the data bus (7:0).  The second byte written
    % is transferred over next higher order bits of the data bus (15:8) and
    % so on.  Similarly, when reading from Pipe Outs, the lower order bits
    % are the first byte read and the next higher order bits are the second
    % byte read.
    a = reshape(flipud(reshape(a, 4, 4)), 1, 16);
    
    obj.WriteToBlockPipeIn(hex2dec('80'), 16, 16, uint8(a));
    
    if (readBit)
        output = obj.GetWireOutValue(hex2dec('21'));
    end
end
