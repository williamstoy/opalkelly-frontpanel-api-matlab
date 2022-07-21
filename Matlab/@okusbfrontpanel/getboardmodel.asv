function epval = getboardmodel(obj)

%GETBOARDMODEL  Returns the board model of the current device.
%  GETBOARDMODEL(OBJ) returns the board model of the current
%  device, as a string:
%     'brdUnknown'
%     'brdXEM3001v1'
%     'brdXEM3001v2'
%     'brdXEM3001CL'
%     'brdXEM3005'
%     'brdXEM3010'
%     'brdXEM3020'
%     'brdXEM3050'
%
%  Copyright (c) 2005 Opal Kelly Incorporated
%  $Rev: 210 $ $Date: 2005-10-13 19:54:17 -0700 (Thu, 13 Oct 2005) $

brd = calllib('okFrontPanel', 'okFrontPanel_GetBoardModel', obj.ptr);
if brd==0,
  brdModel = 'brdUnknown'
elsif brd==1,
  brdModel = 'brdXEM3001v1'
elsif brd==2,
  brdModel = 'brdXEM3001v2'
elsif brd==3,
  brdModel = 'brdXEM3010'
elsif brd==4,
  brdModel = 'brdXEM3005'
elsif brd==5,
  brdModel = 'brdXEM3001CL'
elsif brd==6,
  brdModel = 'brdXEM3020'
elsif brd==7,
  brdModel = 'brdXEM3050'
elsif brd==8,
  brdModel = 'brdXEM9002'
elsif brd==9,
  brdModel = 'brdXEM3001RB'
elsif brd==10,
  brdModel = 'brdXEM5010'
elsif brd==11,
  brdModel = 'brdXEM6110LX45'
elsif brd==15,
  brdModel = 'brdXEM6110LX150'
elsif brd==12,
  brdModel = 'brdXEM6001'
elsif brd==13,
  brdModel = 'brdXEM6010LX45'
elsif brd==14,
  brdModel = 'brdXEM6010LX150'
end



	ok_brdXEM6006LX9 = 16,
	ok_brdXEM6006LX16 = 17,
	ok_brdXEM6006LX25 = 18,
	ok_brdXEM5010LX110 = 19,
	ok_brdZEM4310=20,
	ok_brdXEM6310LX45=21,
	ok_brdXEM6310LX150=22,
	ok_brdXEM6110v2LX45=23,
	ok_brdXEM6110v2LX150=24,
	ok_brdXEM6002LX9=25,
	ok_brdXEM6310MTLX45T=26,
	ok_brdXEM6320LX130T=27,
	ok_brdXEM7350K70T=28,
	ok_brdXEM7350K160T=29,
	ok_brdXEM7350K410T=30,
	ok_brdXEM6310MTLX150T=31,
	ok_brdZEM5305A2 = 32,
	ok_brdZEM5305A7 = 33,
	ok_brdXEM7001A15 = 34,
	ok_brdXEM7001A35 = 35,
	ok_brdXEM7360K160T = 36,
	ok_brdXEM7360K410T = 37,
	ok_brdZEM5310A4 = 38,
	ok_brdZEM5310A7 = 39,
	ok_brdZEM5370A5 = 40,
	ok_brdXEM7010A50 = 41,
	ok_brdXEM7010A200 = 42,
	ok_brdXEM7310A75 = 43,
	ok_brdXEM7310A200 = 44,
	ok_brdXEM7320A75T = 45,
	ok_brdXEM7320A200T = 46,
	ok_brdXEM7305 = 47,
	ok_brdFPX1301 = 48,
	ok_brdXEM8350KU060 = 49,
	ok_brdXEM8350KU085 = 50,
	ok_brdXEM8350KU115 = 51,
	ok_brdXEM8350SECONDARY = 52,
	ok_brdXEM7310MTA75 = 53,
	ok_brdXEM7310MTA200 = 54,
	ok_brdXEM9025 = 55,
	ok_brdXEM8320AU25P = 56,
	ok_brdXEM8310AU25P = 57,
	ok_brdFPX9301 = 58,

brdModel
