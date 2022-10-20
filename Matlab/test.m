clear; clc;

filename = 'design_1_wrapper(8).bit';

okobj = okusbfrontpanel();
okobj.verbose = true;

if isempty(okobj.availableDevices)
    disp('No Opal Kelly Devices Found');
    return;
end

% open the first opal kelly device
okobj.OpenBySerial(okobj.availableDevices(1).serialNumber);

okobj.ConfigureFPGA(filename);

okobj.SetWireInValue(0, 1, 2^32-1);
okobj.GetWireInValue(0);

okobj.DisplayComment('Read Counter (Should be empty)');
okobj.GetWireOutValue(hex2dec('20'));

okobj.DisplayComment('Deassert Reset Flag');
okobj.SetWireInValue(0, 0, 2^32-1);
okobj.GetWireInValue(0);

okobj.DisplayComment('Read Registers a Few Times (FIFO)');
okobj.ReadRegister(0);
okobj.ReadRegister(4);
okobj.WriteRegister(4,1);
okobj.ReadRegister(4);
okobj.WriteRegister(4,0);
okobj.ReadRegister(4);

okobj.DisplayComment('Disconnect from FPGA');
okobj.Close();

clear okobj;