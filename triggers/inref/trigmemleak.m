;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trigmemleak	;
	for i=1:1:10 do
	.	tstart ():serial
	.	if $ztrigger("file","trigmemleak.trg")
	.	trollback
	.	if i=1 set azrealstor=$zrealstor
	.	if azrealstor'=$zrealstor write "$zrealstor after "_i_"th $ztrigger(FILE) = ",$zrealstor,!
	.	if azrealstor=$zrealstor write "No memory leak after "_i_"th $ztrigger(FILE)",!
	quit
