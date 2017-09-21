;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See u_inref/rqtest00.csh for purpose of test. Also see reference file outref/rqtest00.txt for a better picture.
;
rqtest00 ;
	for dir=0,-2,"1E1","abcd" do tstlvn(dir)
	for dir=0,-2,"1E1","abcd" do tstgvn(dir)
	for dir=0,-2,"1E1","abcd" do tstindir(dir)
	quit
tstlvn(dir);
	set $etrap="do printquery2 set $ecode=""""  quit"
	write "$query(lvn,",dir,")=",$query(lvn,dir)
	quit
tstgvn(dir);
	set $etrap="do printquery2 set $ecode=""""  quit"
	write "$query(gvn,",dir,")=",$query(gvn,dir)
	quit
tstindir(dir);
	set $etrap="do printquery2 set $ecode=""""  quit"
	if $random(2) set indir="x"
	else          set indir="^x"
	write "$query(@indir,",dir,")=",$query(@indir,dir)
	quit
printquery2;
	; print the QUERY2 error text as well as the M location where it happened
	new status
	set status=$zstatus
	write !,$zpiece(status,",",2,99),!
	quit
