;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nontp	;
	;
	write "Cannot be called directly. Use one of the entryref ",!
	quit

init	;
	set inst=$zcmdline
	for i=1:1:1000  set ^a(i,inst)=$j(i,10)
	quit

test1	; Two updates to same instance with interleaving online rollback
	new $etrap
	set $etrap="do err^nontp"
	set ^a=1
	zsystem "$MUPIP journal -online -rollback -backward -resync=800 -verbose ""*"" >&! orlbk1.out"
	set ^b=1	; Should issue a DBROLLEDBACK error
	quit

test2	; Should NOT issue a DBROLLEDBACK error because starting V63001A, online rollback does not increment cycles
	; on non-journaled regions on the current instance. For this, use an error trap "noerr" that signals failure.
	new $etrap
	set $etrap="do noerr^nontp"
	set ^hnonjnld=1
	zsystem "$MUPIP journal -online -rollback -backward -resync=700 -verbose ""*"" >&! orlbk2.out"
	set ^b=2
	write "PASS",!
	quit

test3	; Should NOT issue a DBROLLEDBACK error because ^a in mumps2.gld maps to ab.dat which rollback won't touch
	; set $etrap="do err^nontp" ; No error trap set as we don't expect a DBROLLEDBACK error
	set ^|"mumps2.gld"|a=1
	zsystem "$MUPIP journal -online -rollback -backward -resync=600 -verbose ""*"" >&! orlbk3.out"
	set ^b=3
	if $get(^|"mumps2.gld"|a)=1,$get(^b)=3  write "PASS",!
	else  zshow "*"  write "FAIL",!
	quit

test4	; Should issue a DBROLLEDBACK error because ^x in mumps2.gld maps to mumps.dat which rollback will touch
	new $etrap
	set $etrap="do err^nontp"
	set ^|"mumps2.gld"|x=1
	zsystem "$MUPIP journal -online -rollback -backward -resync=500 -verbose ""*"" >&! orlbk4.out"
	set ^b=4
	quit

test5	; This is test4 done in the reverse direction
	new $etrap
	set $etrap="do noerr^nontp"
	set ^a=1
	zsystem "$MUPIP journal -online -rollback -backward -resync=400 -verbose ""*"" >&! orlbk5.out"
	set ^|"mumps2.gld"|b=1	; Should NOT issue a DBROLLEDBACK error since ^b in mumps2.gld has replication OFF
	write "PASS",!
	quit

test6	; Should NOT issue a DBROLLEDBACK error because ^a mapped to other instance's gld which rollback won't touch
	set inst3dir=$ztrnlnm("inst3dir")
	for i=1:1:1000  do
	. if '$data(^|inst3dir_"/mumps.gld"|a(i))  zshow "*"	; This should cause a read from the other instance
	zsystem "$MUPIP journal -online -rollback -backward -resync=300 -verbose ""*"" >&! orlbk6.out"
	set ^b=5
	if $get(^b)=5  write "PASS",!
	else  zshow "*"  write "FAIL",!
	quit

test7	; A read from another instance and a rollback *also* on the other instance with a following write to the current instance
	set inst3dir=$ztrnlnm("inst3dir")
	new $etrap
	set $etrap="do err^nontp"
	for i=1:1:1000  do
	. if '$data(^|inst3dir_"/mumps.gld"|a(i))  zshow "*"
	zsystem "cd "_inst3dir_"; $MUPIP journal -online -rollback -backward -resync=200 -verbose ""*"" >&! orlbk7.out"
	set ^b=6 ; Should issue DBROLLEDBACK error
	quit

test8	; Update of same value during simultaneous rollback - expect DBROLLEDBACK error
	new $etrap
	set $etrap="do err^nontp"
	set ^a=$j(" ",4000)
	zsystem "$MUPIP journal -online -rollback -backward -resync=100 -verbose ""*"" >&! orlbk8.out"
	set ^a=$j(" ",3999)
	quit

err	; Error handler that signals PASS
	if $ZSTATUS["DBROLLEDBACK",0=$TLEVEL  write "PASS",!
	else  zshow "*"  write "FAIL",!
	set $ecode=""
	quit

noerr	; Error handler that signals FAIL
	zshow "*" write "FAIL",!
	set $ecode=""
	quit
