;
; GTM-7206 - test UNLINK all works with triggers. Drive 4 triggers for ^A, ^B, ^C ^D. After the unlink, 
; load a few of small unrelated modules that should take up the space that the triggers were in. Then
; redrive the triggers and verify they execute properly instead of executing garbage or the routines
; we linked in.
;

	Write "Drive triggers in order ^A, ^B, ^C, ^D",!
	Set ^A=1
	Set ^B=2
	Set ^C=3
	Set ^D=4

	Write "Performing unlink",!
	ZGoto 0:resume^unlinktrg	; Do the unlink and restart process at "resume".
	Write "unlink failed - inappropriate return",!
	ZShow "*"
	Halt

resume
	Write "Unlink successful - creating replacement routines",!
	;
	; Create a link 3 routines about the same size as the triggers
	;
	For i=1:1:2 Do
	. Set file="relink"_i_".m"
	. Open file:New
	. Use file
	. Write $Char(9),"Write ""In relink",i," routine"",!",!
	. Close file
	. ZLink file
	;
	; Now drive the triggers again
	;
	Write "Re-driving triggers in same order as before",!
	Set ^A=2
	Set ^B=3
	Set ^C=4
	Set ^D=5
	Quit
