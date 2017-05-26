;
; Called via call-in. Verify generate error when try to use UNLINK ZGOTO with a valid target

	Write "In simpleci - attempting UNLINK type ZGOTO - expect ZGOCALLOUTIN error",!
	ZGoto 0:unlinktgt^simpleci
	Write "FAIL - zgoto did not launch",!
	Halt

unlinktgt
	Write "FAIL - UNLINK seems to have worked when expected failure",!
	Halt
