clear; clc;

folder = 'C:\Users\williamstoy\Documents\Github\k410t_jesd\k410t_jesd.runs\impl_1\';
filename = 'design_1_wrapper.bit';

global readAddress writeAddress wireInAddress triggerInAddress counter1Address counter2Address;
writeAddress      = 0x80;
readAddress       = 0x20;
wireInAddress     = 0x00;
triggerInAddress  = 0x40;
counter1Address   = 0x21; % clk_lao_0
counter2Address   = 0x22; % core clock

registerSpace = containers.Map(...
    {'Version', 'Reset', 'ILA Support', 'Scrambling', 'SYSREF Handling', 'Test Modes', 'Link Error Status', 'Octets per Frame', 'Frames per Multiframe', 'Lanes in Use', 'Subclass Mode', 'RX Buffer Delay', 'Error Reporting', 'Sync Status', 'Debug Status', 'ILA Config Data 0', 'ILA Config Data 1', 'ILA Config Data 2', 'ILA Config Data 3', 'ILA Config Data 4', 'ILA Config Data 5', 'ILA Config Data 6', 'ILA Config Data 7', 'Test Mode Error Count', 'Link Error Count', 'Test Mode ILA Count', 'Test Mode Multiframe Count', 'Buffer Adjust'}, ...
    {'000', '004', '008', '00C', '010', '018', '01C', '020', '024', '028', '02C', '030', '034', '038', '03C', '800', '804', '808', '80C', '810', '814', '818', '81C', '820', '824', '828', '82C', '830'}...
);

wireInMask = 2^32-1;

okobj = okusbfrontpanel();
okobj.verbose = true;

if isempty(okobj.availableDevices)
    disp('No Opal Kelly Devices Found');
    return;
end

% @todo: make sure that reading isn't happening twice (which would reset
% the ILA bits in the debug status register)

% open the first opal kelly device
okobj.OpenBySerial(okobj.availableDevices(1).serialNumber);

%okobj.ConfigureFPGA([folder filename]);

okobj.GetDeviceSettings();
okobj.DeviceSettingsSetInt('XEM7350_FAN_MODE', 0);
okobj.DeviceSettingsSetInt('XEM7350_FAN_ENABLE', 1);
okobj.DeviceSettingsSetInt('FMC1_VADJ_VOLTAGE', 250);
okobj.DeviceSettingsSetInt('FMC1_VADJ_ENABLE', 1);
okobj.DeviceSettingsSetInt('FMC1_VADJ_MODE', 3);
okobj.DeviceSettingsGetInt('FMC1_STATUS');
okobj.DeviceSettingsSave();

%Startup sequence defined by ADS54J66 manual page 69/82
% write the address
% okobj.WriteToBlockPipeIn(writeAddress, 8, char(ones(1, 8)));
% okobj.ReadFromBlockPipeOut(readAddress, 8, 8);
% disp(okobj.GetWireOutValue(hex2dec('24')));

okobj.DisplayComment('Resetting...');
AXI4liteReset(okobj);
okobj.SetWireInValue(wireInAddress, 0, wireInMask); % rx_reset
okobj.SetWireInValue(wireInAddress, 1, wireInMask); % rx_reset
okobj.SetWireInValue(wireInAddress, 0, wireInMask); % rx_reset

% 5) Write 0x2 to JESD RX AXI register 0x04 (fixed reset) to hold the JESD core in reset.
% 6) Program ADC registers.
% 7) Clear JESD core reset. After clearing reset, the GT lanes start seeing 0xBCBC characters.

okobj.DisplayComment('Read Version of JESD IP');
AXI4liteRead(okobj, '000'); % 0x000: Read Version

L = 4; M = 4; F = 2; S = 1;

okobj.DisplayComment('Setting JESD IP Vars');
%AXI4liteWrite(okobj, registerSpace('Reset'), '00000000');
%AXI4liteWrite(okobj, registerSpace('Reset'), '00000002');
AXI4liteWriteAndConfirm(okobj, registerSpace('ILA Support')             , '00000001'); % 0x008: Support ILA
AXI4liteWriteAndConfirm(okobj, registerSpace('Scrambling')              , '00000000'); % 0x00C: Scrambling disabled
AXI4liteWriteAndConfirm(okobj, registerSpace('SYSREF Handling')         , '00010001'); % 0x010: Sysref always (TB uses 00000001) prev: 00010001
AXI4liteWriteAndConfirm(okobj, registerSpace('Test Modes')              , '00000000'); % 0x018: Test mode = Normal operation
AXI4liteWriteAndConfirm(okobj, registerSpace('Octets per Frame')        , '00000001'); % 0x020: Octets per Frame F=2
AXI4liteWriteAndConfirm(okobj, registerSpace('Frames per Multiframe')   , '0000000F'); % 0x024: Frames per Multiframe K=16
AXI4liteWriteAndConfirm(okobj, registerSpace('Lanes in Use')            , '0000000F'); % 0x028: Lanes in use 32'd4 (L=4)
AXI4liteWriteAndConfirm(okobj, registerSpace('Subclass Mode')           , '00000001'); % 0x02C: Device subclass 1
AXI4liteWriteAndConfirm(okobj, registerSpace('RX Buffer Delay')         , '00000000'); % 0x030: Rx buffer delay

% disable then re-enable error reporting bit in register memory to reset count
AXI4liteWriteAndConfirm(okobj, registerSpace('Error Reporting')         , '00000000'); % 0x034: Error reporting via ~sync (TB uses 00000000, prev 00000101)
%AXI4liteWriteAndConfirm(okobj, registerSpace('Error Reporting')         , '00000101'); % 0x034: Error reporting via ~sync (TB uses 00000000, prev 00000101)
% need to disable the error reporting via ~sync because frames only have
% one octet (see page 73 of JESD IP 7.2 documentation)

% write clearing reset to 0
AXI4liteWrite(okobj, registerSpace('Reset'), '00000000');
AXI4liteWrite(okobj, registerSpace('Reset'), '00000001');
okobj.verbose = 0;
registerValue = 1;
tic;
elapsedTime = 0;
% check TB- what is this waiting on?
while queryBits(registerValue, 0) ~= 0
    registerValue = AXI4liteRead(okobj, registerSpace('Reset'));
    
    elapsedTime = toc;
    if elapsedTime > 0.05
        printCoreClockFreq(okobj, 20);
        %findOscFreq(okobj);
        
        okobj.DisplayComment('Disconnect from FPGA');
        okobj.verbose = 0;
        okobj.Close();
        error('Timed out waiting for reset to return');
    end
end

okobj.SetWireInValue(wireInAddress, 0, wireInMask); % rx_reset
okobj.SetWireInValue(wireInAddress, 1, wireInMask); % rx_reset
okobj.SetWireInValue(wireInAddress, 0, wireInMask); % rx_reset
cprintf([0, 0.75, 0], sprintf('AXI Configuration and Reset complete after %.3f seconds\n', elapsedTime));

okobj.verbose = 1;
okobj.ActivateTriggerIn(triggerInAddress, 0);
pause(1.1);
counter1 = okobj.GetWireOutValue(counter1Address);
counter2 = okobj.GetWireOutValue(counter2Address);

fprintf(1, '%.2f MHz Device Clock\n', counter1/10000);
fprintf(1, '%.2f MHz Core Clock\n', counter2/10000);

okobj.DisplayComment('Disconnect from FPGA');
okobj.verbose = 0;
okobj.Close();

clear okobj;

function pollStatusRegister(okobj, registerSpace)
    okobj.DisplayComment('SYNC Status Register');
    n = 100;
    sync = zeros(n, 1);
    sysref = zeros(n, 1);
    valid = zeros(n, 1);
    times = zeros(n, 1);
    maxj = 1000;
    g = zeros(maxj, 1);
    k = zeros(maxj, 1);
    m = zeros(maxj, 1);
    t = 1:maxj;
    tic;
    close all; figure;
    for j = 1:maxj
        for i = 1:n
            syncStatus = AXI4liteRead(okobj, registerSpace('Sync Status'));
            times(i) = toc;
            a = int2bit(syncStatus, 32);
            sync(i) = a(1);
            sysref(i) = a(17);
            v = okobj.GetWireOutValue(hex2dec('22'));
            v2 = int2bit(v, 32);
            valid(i) = v2(end);
            %okobj.DisplayComment('ILA Config Data 0');
            r1 = okobj.GetWireOutValue(hex2dec('24'));
            r2 = okobj.GetWireOutValue(hex2dec('22'));
            disp(dec2bin(r2, 32));
            disp(dec2bin(r1, 32));
            
%             okobj.DisplayComment('ILA Config Data 1');
%             ilaConfigData1 = AXI4liteRead(okobj, registerSpace('ILA Config Data 1'));
%             disp(dec2bin(ilaConfigData1, 32));
%             
%             okobj.DisplayComment('ILA Config Data 2');
%             ilaConfigData2 = AXI4liteRead(okobj, registerSpace('ILA Config Data 2'));
%             disp(dec2bin(ilaConfigData2, 32));
%             
%             okobj.DisplayComment('ILA Config Data 3');
%             ilaConfigData3 = AXI4liteRead(okobj, registerSpace('ILA Config Data 3'));
%             disp(dec2bin(ilaConfigData3, 32));
            %disp(int2bit(syncStatus, 32)); % sync status
        end

        g(j) = sum(sysref)/length(sysref);
        k(j) = sum(sync)/length(sync);
        m(j) = sum(valid)/length(valid);
        subplot(3,1,1);
        plot(t, g);
        ylim([0, 1.1]);
        subplot(3,1,2);
        plot(t, k);
        subplot(3,1,3);
        plot(t, m);
        drawnow;
    end
end


function freq = printCoreClockFreq(okobj, divider)
    okobj.DisplayComment('Core Clock Frequency');

    n = 1;
    a = zeros(1, n);
    m = 1;
    internal_counter = 1e6;
    
    for i = 1:n
        % clear the counter
       okobj.ActivateTriggerIn(hex2dec('40'), 4);
       for k = 1:m
           % enable the counter for 1/2 clock cycle (100.8 MHz)
           okobj.ActivateTriggerIn(hex2dec('40'), 3);
       end
       pause(0.01);
       % cycles per 1/2 ok clock cycle * m
       value = okobj.GetWireOutValue(hex2dec('23'));
       a(i) = value/m/internal_counter; 
    end
    
    freq = mean(a)*100.8;
    
    fprintf(1, '%.3f -> %.3f MHz', freq, freq*divider);
end

function k = findOscFreq(okobj)
    n0 = 1;
    s = 1;
    n = 5;
    divVals = n0:s:n;
    g = 0 * divVals;
    
    for i = 1:length(divVals)
       fprintf(1, '\n\nSET DIVIDER TO: %i', divVals(i));
       pause;
       g(i) = printCoreClockFreq(okobj, divVals(i));
    end
    figure; plot(divVals,g);
    k = [(divVals)', g'];
    disp(k)
    
    ft = fittype('a*x^(-1)');
    f = fit(divVals', g', ft);
    
    x = 1:0.1:32;
    hold on; plot(x, f.a ./ x, 'r');
    disp(f.a)
end


function result = isBitSet(register, bitIndex)
    result = bitand(register, bitset(0, bitIndex)) > 0;
end


function AXI4liteWriteAndConfirm(obj, address, data)
    setValue = data;
    prev_verbosity = obj.verbose;
    obj.verbose = 0;
    beforeValue = AXI4liteRead(obj, address);
    AXI4liteWrite(obj, address, setValue);
%     bresp = obj.GetWireOutValue(hex2dec('23'));
    afterValue = AXI4liteRead(obj, address);
    
%     if bresp ~= 0
%         cprintf([0.75, 0, 0], 'BRESP: error writing to %s (value=%i)\n', address, bresp);
%     end
    
    if beforeValue == hex2dec(setValue)
        cprintf([0.5, 0.5, 0], 'Value was already set to commanded data\n');
    else
        if afterValue == hex2dec(setValue)
            cprintf([0, 0.75, 0], sprintf('Value at ADDRESS (0x%s) was set to (0x%s) successfully!\n', address, dec2hex(afterValue)));
        elseif beforeValue == afterValue
            cprintf([0.75, 0, 0], 'ERROR: write did not succeed (value before and after write are the same)\n');
        else
            cprintf([0.75, 0, 0], 'ERROR: write did not succeed (value after write is not equal to set value or before value)\n');
        end
    end
    obj.verbose = prev_verbosity;
end

function output = queryBits(decValue, bitIndicies)
    binArray = int2bit(decValue, 32);
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
    global readAddress writeAddress;

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
    
    obj.WriteToBlockPipeIn(writeAddress, 16, 16, uint8(a));
    
    if (readBit)
        output = obj.GetWireOutValue(readAddress);
    end
end
