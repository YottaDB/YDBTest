;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2003, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
long	; This is a routine to set and write globals over a long period of time
         s unix=$zv'["VMS"

test
        s fname="long.out"
	o fname
	c fname:delete
	o fname
	u fname
	d func("^A")
	d func("^B")
	d func("^C")
	; crash the server
	if unix  do
	. zsy "$rsh $tst_remote_host_2 ""source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2; cd $SEC_DIR_GTCM_2; $gtm_tst/$tst/u_inref/gtcm_server_crash.csh"""
	else  do
	. zsy "@in$dir:[V_INREF]gtcm_server_crash.com HOST2"
	;
	d func("^A1")
	d func("^B1")
	d func("^C1")
	d func("^A2")
	d func("^B2")
	d func("^C2")
	c fname
	q
func(gbl)	;
	f i=1:1:100  d
	. s x=gbl_"("_i_")"
	. s @x=$j(i,i)
	. w x,"=",@x,!
	h 3
	q
