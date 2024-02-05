clear; clc;

folder = 'C:\Users\williamstoy\Documents\vivado\projects\jesd_verilog\jesd_verilog.runs\impl_1\';
filename = 'design_1_wrapper.bit';

okobj = okusbfrontpanel();
okobj.verbose = true;

if isempty(okobj.availableDevices)
    disp('No Opal Kelly Devices Found');
    return;
end

% open the first opal kelly device
okobj.OpenBySerial(okobj.availableDevices(1).serialNumber);

%okobj.ConfigureFPGA([folder filename]);

triggerAddr   = hex2dec('40');
rstTriggerBit = 0; 
rstnTriggerBit = 2;
wenTriggerBit = 1;
wdataAddr = 0;
sdoutAddr = hex2dec('20');

wireInMask = 2^32-1;

% reset
okobj.ActivateTriggerIn(triggerAddr, rstTriggerBit);
okobj.ActivateTriggerIn(triggerAddr, rstnTriggerBit);


okobj.GetWireOutValue(hex2dec('20'));
okobj.ReadRegister(hex2dec('000'));

okobj.GetWireOutValue(hex2dec('20'));
okobj.ReadRegister(hex2dec('000'));

okobj.GetWireOutValue(hex2dec('20'));
okobj.ReadRegister(hex2dec('000'));

okobj.GetWireOutValue(hex2dec('20'));


okobj.DisplayComment('Disconnect from FPGA');
okobj.Close();

clear okobj;