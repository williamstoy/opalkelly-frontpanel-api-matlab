# opalkelly-frontpanel-api-matlab
 MATLAB API wrapper for Opal Kelly FrontPanel
 Existing API wrapper from Opal Kelly does not appear to be functional as of 2022-09-15, necessitating this custom wrapper.
 API Reference: https://library.opalkelly.com/library/FrontPanelAPI/annotated.html
 
## Requirements
- Opal Kelly FrontPanel SDK (must create an account with Opal Kelly PINS to download)
- MATLAB (Tested with v 2021b on Windows 10)

## Installation
- Download the Opal Kelly FrontPanel SDK
- Copy 'include' and 'lib' folders into the project root
- Add the project folder to the path

## Example Usage
```
sn = '##########'; % INSERT YOUR OPAL KELLY BOARD'S SERIAL NUMBER HERE

okobj = okusbfrontpanel();

if isempty(okobj.availableDevices)
    disp('No Opal Kelly Devices Found');
    return;
end

% open the first opal kelly device
okobj.OpenBySerial(okobj.availableDevices(1).serialNumber);

sn = okobj.GetSerialNumber();
v_major = okobj.GetDeviceMajorVersion();
v_minor = okobj.GetDeviceMinorVersion();

fprintf(1, 'SN: %s (Version %d.%d)\n', sn, v_major, v_minor);

okobj.Close();

clear okobj;
```
