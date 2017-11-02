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
;
; See replace_rtn.csh for a description of this test - this is the target of the call-in
;
testrtnreplc2
	new $etrap
	set $etrap="write ""testrtnreplc2: ** Error** : "",$zstatus,!,""Aborting testrtnreplc2"",!"
	write "testrtnreplc2: Entered - creating alternate testrtnreplcA routine",!
	;
	; We've been entered via call-in. First up, create a new version of testrtnreplcA.m to replace the
	; one that is on the stack now after renaming the original so it stays in the test directory.
	;
	zsystem "mv testrtnreplcA.m testrtnreplcA.m.original"
	if (0'=$zsystem) do
	. write "testrtnreplc2: Failure in zsystem 'mv' command - aborting",!
	. zhalt 1
	set fn="testrtnreplcA.m"
	open fn:new
	use fn
	write " write ""testrtnreplcA (replaced): Entered - do some variable play"",!",!
	write " set a=a*2,b=b*2,c=c*2"
	write " write ""testrtnreplcA (replaced): Returning"",!",!
	write " quit",!
	close fn
	;
	; Allow a routine to be re-linked even if on stack. This allows us to have two version of the same
	; routine active. But if we didn't *find* the old routine because the call-in level prevented it, the
	; linker will REPLACE the previous routine such that when we unwind to the earlier version and it has
	; been replace, things won't be pleasant.
	;
	view "LINK":"RECURSIVE"
	write "testrtnreplc2: ZLINKing new version of ^testrtnreplcA",!
	zlink "testrtnreplcA.m"
	write "testrtnreplc2: Driving replaced ^testrtnreplcA",!
	set $etrap=""
	do ^testrtnreplcA
	write "testrtnreplc2: Back in testrtnreplc2 -- returning",!
	quit
