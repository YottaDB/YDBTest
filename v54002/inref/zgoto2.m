;
; External entry point (needs autozlink) for zgoto test.
;
; Returns to caller using new UNLINK form ZGOTO on UNIX, just normal ZGOTO on VMS
;
	ZGoto $Select(isunix:0,1:$ZLevel):Next10^zgoto1
	Write "Failed..",!
	ZShow "S"
	Halt
