;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triggers	;
	set $ztrap="goto errorAndCont^errorAndCont"
	write "# Select/Load/Delete triggers that map to the local region should work fine",!
	write $ztrigger("select","a*"),!
	do loadbyitem("localdel.trg")
	do loadbyitem("local.trg")
	write $ztrigger("file","localdel.trg"),!
	write $ztrigger("file","local.trg"),!
	write "# Select/Load/Delete triggers that map to the remote (GTCM client) region should error gracefully",!
	write $ztrigger("select","b*"),!
	write $ztrigger("select","^x"),!
	do loadbyitem("remotedel.trg")
	do loadbyitem("remote.trg")
	write $ztrigger("file","remotedel.trg"),!
	write $ztrigger("file","remote.trg"),!
	quit

remoteadd	;
	;+^b(acn=:) -commands=SET -name=btrig -xecute="Set ^b(acn,acn+1)=$ztval"
	;+^x(acn=:) -commands=SET -xecute="Set ^x(acn,acn+1)=$ztval"
	quit

remotedelete	;
	;-^b(acn=:) -commands=SET -name=btrig -xecute="Set ^b(acn,acn+1)=$ztval"
	;-^x(acn=:) -commands=SET -xecute="Set ^x(acn,acn+1)=$ztval"
	;-btrig
	;-b*
	;-x*
	quit

localadd	;
	;+^a(acn=:) -commands=SET -xecute="Set ^a(acn,acn+1)=$ztval"
	quit

localdelete	;
	;-a*
	quit

gentrigfiles	;
	do text^dollarztrigger("remoteadd^gtcmtriggers","remote.trg")
	do text^dollarztrigger("localadd^gtcmtriggers","local.trg")
	do text^dollarztrigger("remotedelete^gtcmtriggers","remotedel.trg")
	do text^dollarztrigger("localdelete^gtcmtriggers","localdel.trg")
	quit

loadbyitem(file)	;
	open file:readonly
	use file
	for  read line quit:$zeof  do
	.	use $p write line_" :",!,$ztrigger("item",line),!
	. 	use file
	close file
	quit
