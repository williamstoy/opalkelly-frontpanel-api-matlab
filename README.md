# opalkelly-frontpanel-api-matlab
 MATLAB API wrapper for Opal Kelly FrontPanel
 
 Existing API wrapper from Opal Kelly does not appear to be functional as of 2022-09-15, necessitating this custom wrapper.
 
 API Reference: https://library.opalkelly.com/library/FrontPanelAPI/annotated.html
 
 
## Requirements
- Opal Kelly FrontPanel SDK (must create an account with Opal Kelly PINS to download)
- MATLAB (Tested with v 2023a on Windows 11)

## Installation
- Download the Opal Kelly FrontPanel SDK
- Copy 'include' and 'lib' folders from OK FP SDK into the project root
- Add the project folder to the path
- Configure MEX to use the Matlab MinGW64 Compiler (C):
  - Run `mex -setup`
  - Confirm that 'MEX configured to use 'MinGW64 Compiler (C)' for C language compilation.'
  - If the MEX compiler is set to any other compiler, follow the instructions printed in the response to set the compiler to the 'MinGW64 Compiler (C)'
    - e.g. `mex -setup:'C:\Program Files\MATLAB\R2023a\bin\win64\mexopts\mingw64.xml' C`

## Example Usage
```matlab
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
