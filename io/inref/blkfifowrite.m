;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2009, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
blockedfifo
	; write output until fifo blocks.  When it traps, wait a few seconds and try again.
	; to process more
	set ^ztrapfifo=0
	set p1="test1.fifo"
	open p1:(fifo:writeonly:newversion)
	set $ztrap="goto cont1"
	for i=1:1:10000  do
	. use p1
	. set c=i_":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"
	. write c,!
	. use $p write i,!
	quit
cont1
	set z=$za
	; use $device to make sure ztrap caused by blocked write to pipe
	set d=$device
	if "1,Resource temporarily unavailable"=d do
	. use $p
	. set ^ztrapfifo=^ztrapfifo+1
	. write "fifo full, i= ",i," $za = ",z,!
	. set i=i-1
	. hang 3
	. use p1
	quit
