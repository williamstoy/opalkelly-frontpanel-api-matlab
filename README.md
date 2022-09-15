# opalkelly-frontpanel-api-matlab
 MATLAB API wrapper for Opal Kelly FrontPanel
 Existing API wrapper from Opal Kelly does not appear to be functional as of 2022-09-15, necessitating this custom wrapper.
 API Reference: https://library.opalkelly.com/library/FrontPanelAPI/annotated.html
 
## Requirements
- Opal Kelly FrontPanel SDK (must create an account with Opal Kelly PINS to download)
- MATLAB (Tested with v 2021b on Windows 10)

## Installation
- Download the Opal Kelly FrontPanel SDK
- Copy files in 'include' and 'lib' folders into corresponding folders at the project root
- Add the project folder to the path

## Example Usage
```
sn = '##########'; % INSERT YOUR OPAL KELLY BOARD'S SERIAL NUMBER HERE

if ~libisloaded('okFrontPanel')
	loadlibrary('okFrontPanel', 'okFrontPanel.h');
end

xptr = calllib('okFrontPanel', 'okFrontPanel_Construct');

okobj = okusbfrontpanel(xptr);
openbyserial(okobj, sn)

% get the model number of the first device
display(okobj)
isopen(okobj)
calllib('okFrontPanel', 'okFrontPanel_Close', xptr)
isopen(okobj)

calllib('okFrontPanel', 'okFrontPanel_Destruct', xptr);
```
