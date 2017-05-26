;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Series of routines used in calltest.m to test various call types. Identical to targrtn.m except routine
; and all labels are prefixed with a percent sign to test that path of things.
;
callnolbl(arg1,arg2)
	write !,"in [%callnolbl]^%targrtn !!",!
	write "arg1:  ",arg1,!
	write "arg2:  ",arg2,!
	quit

%donoargs
	write !,"in %donoargs^%targrtn !!",!
	quit

%dowargs(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
	write !,"in %dowargs^%targrtn:",!
	write "arg1:  ",arg1,!
	write "arg2:  ",arg2,!
	write "arg3:  ",arg3,!
	write "arg4:  ",arg4,!
	write "arg5:  ",arg5,!
	write "arg6:  ",arg6,!
	write "arg7:  ",arg7,!
	write "arg8:  ",arg8,!
	write "arg9:  ",arg9,!
	write "arg10: ",arg10,!
	quit

%funcnoargs()
	write !,"in %funcnoargs^%targrtn !!",!
	quit 42

%funcwargs(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10)
	write !,"in %funcwargs^%targrtn:",!
	write "arg1:  ",arg1,!
	write "arg2:  ",arg2,!
	write "arg3:  ",arg3,!
	write "arg4:  ",arg4,!
	write "arg5:  ",arg5,!
	write "arg6:  ",arg6,!
	write "arg7:  ",arg7,!
	write "arg8:  ",arg8,!
	write "arg9:  ",arg9,!
	write "arg10: ",arg10,!
	quit arg4_arg8_" "_arg10

