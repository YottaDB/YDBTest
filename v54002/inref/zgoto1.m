;
; Test for ZGOTO functionality (all types)
;
	Set $ETrap="Write ""FAIL - Error encountered"",! ZShow ""*"" Halt"
	Set lvl=$ZLevel
	Set isunix=($ZVersion'[" VMS ")

	Write "ZGoto specifying local label",!
	ZGoto lvl:Next1
	Write "Failed..",!
	ZSHow "S"
	Halt

Next1
	Write "ZGoto specifying local label and offset",!
	ZGoto lvl:Next2+4
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next2
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "ZGoto specifying fully qualified entryref",!
	ZGoto lvl:Next3^zgoto1
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next3
	Write "ZGoto with indirect local label",!
	Set lbl="Next4"
	ZGoto lvl:@lbl
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next4
	Write "ZGoto with indirect local label and variable offset",!
	Set lbl="Next5"
	Set off=4
	ZGoto lvl:@lbl+off
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next5
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "ZGoto with indirect label and routine",!
	Set rtn="zgoto1"
	Set lbl="Next6"
	ZGoto lvl:@lbl^@rtn
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next6
	Write "ZGoto with indirect label and routine with offset",!
	Set rtn="zgoto1"
	Set lbl="Next7"
	Set off=4
	ZGoto lvl:@lbl+off^@rtn
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next7
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "ZGoto with full entry in single indirect",!
	Set eref="lvl:Next8^zgoto1"
	ZGoto @eref
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next8
	Write "ZGoto with full entry in single indirect (including offset)",!
	Set eref="lvl:Next9+4^zgoto1"
	ZGoto @eref
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next9
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "ZGoto external entry point (resolving/auto-zlinking) with no label",!
	ZGoto lvl:^zgoto2
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next10
	Set lvl=$ZLevel		; Reset lvl since may have changed since returned via UNLINK form of ZGOTO
	Write "Xecuted ZGoto specifying local label",!
	Xecute "ZGoto lvl:Next11"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next11
	Write "Xecuted ZGoto specifying local label and offset",!
	Xecute "ZGoto lvl:Next12+4"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next12
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "Xecuted ZGoto specifying fully qualified entryref",!
	Xecute "ZGoto lvl:Next13^zgoto1"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next13
	Write "Xecuted ZGoto with indirect local label",!
	Set lbl="Next14"
	Xecute "ZGoto lvl:@lbl"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next14
	Write "Xecuted ZGoto with indirect local label and variable offset",!
	Set lbl="Next15"
	Set off=4
	Xecute "ZGoto lvl:@lbl+off"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next15
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "Xecuted ZGoto with indirect label and routine",!
	Set rtn="zgoto1"
	Set lbl="Next16"
	Xecute "ZGoto lvl:@lbl^@rtn"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next16
	Write "Xecuted ZGoto with indirect label and routine with offset",!
	Set rtn="zgoto1"
	Set lbl="Next17"
	Set off=4
	Xecute "ZGoto lvl:@lbl+off^@rtn"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next17
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "Xecuted ZGoto with full entry in single indirect",!
	Set eref="lvl:Next18^zgoto1"
	Xecute "ZGoto @eref"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next18
	Write "Xecuted ZGoto with full entry in single indirect (including offset)",!
	Set eref="lvl:Next19+4^zgoto1"
	Xecute "ZGoto @eref"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next19
	Write "Failed..",!
	ZSHow "S" 
	Halt
	Write "Xecuted ZGoto external entry point (resolving/auto-zlinking) with no label",!
	Xecute "ZGoto lvl:^zgoto3"
	Write "Failed..",!
	ZSHow "S" 
	Halt

Next20
	Write "Test relative ZGOTO no entryref",!
	Do BumpLvl1(0)
	Write "Next20 return (good)",!
	; Fall into Next21

Next21
	Write "Test relative ZGOTO with entryref",!
	Do BumpLvl1(1)
	Write "Failed..",!
	ZShow "S"
	Halt

Next22
	Write "Next21 return (good)",!
	Goto Finish

BumpLvl1(type)
	Do BumpLvl2(type)
	Write "Failed..",!
	ZShow "S"
	Halt

BumpLvl2(type)
	ZGoto:(0=type) -2
	ZGoto:(1=type) -2:Next22
	Write "Failed..",!
	ZShow "S"
	Halt
	
Finish
	Write "Pass: ZGoto test successfully completed",!
	Quit
