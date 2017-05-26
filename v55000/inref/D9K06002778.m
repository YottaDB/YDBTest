;
; White-box test case that breaks a frame so get_frame_place_mcode.c (called during
; error handling) sees it but doesn't explode (test for changes made for D9K06-002778).
; One of the classic frame breaking TR fixes: C9J06-003137 but have been several others.
; Only known method to create failing issue is via white box test breakage now.
;
	Write "Entering main",!
	Set origlvl=$ZLevel
	Set $ETrap="Do showstack"
	Do subA
	Quit

subA
	Write "Entering subA",!
	Do subB
	Quit

subB
	Write "Entering subB - corruption subA with whitebox call",!
	Hang 0.999	; Causes stack-frame corruption by polluting the mpc of the previous frame
	Set x=1/0	; Trip an error which causes stack to be saved for $STACK().
	Quit

showstack
	Set $ETrap="ZShow ""*"" Halt"
	Set lvls=$Stack(-1)
	Write "Level",?10,"Place",?40,"ECode",?61,"MCode",!!
	For lvls=lvls:-1:1 Do
	. Write lvls,?10,$Stack(lvls,"Place"),?40,$Stack(lvls,"ECode"),?60,$Stack(lvls,"MCode"),!
	ZGoto origlvl	; Exits by bypassing the broken frame - effectively returning from subA
