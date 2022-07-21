clear; clc;

if libisloaded('okFrontPanel')
    unloadlibrary('okFrontPanel');
end

if ~libisloaded('okFrontPanel')
	loadlibrary('okFrontPanel', 'okFrontPanel.h');
end

xptr = calllib('okFrontPanel', 'okFrontPanel_Construct');
sn = '1729000I6U';

okobj = okusbfrontpanel(xptr);
openbyserial(okobj, sn)

% get the model number of the first device
display(okobj)
isopen(okobj)
calllib('okFrontPanel', 'okFrontPanel_Close', xptr)
isopen(okobj)

calllib('okFrontPanel', 'okFrontPanel_Destruct', xptr);