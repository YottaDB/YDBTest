;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x2	;
	s x=$ztrigger("item","-*")							; delete any/all pre-existing triggers
	s x=$ztrigger("item","+^x2 -commands=set -xecute=""set z=3  do trig^trigydb873"" -name=x2set")   ; load a SET trigger on ^x2 global
	write "# Execute [set x2=2]",!
	set x2=2
	write "# Execute [zwrite $STACK]",!
	zwrite $stack
	write "# Execute [zshow ""s""]",!
	zshow "s"
	write "# Execute [zshow ""v""::0]",!
	zshow "v"::0
	write "# Execute [set ^x2=1] which invokes the trigger [do trig^trigydb873]",!
	set ^x2=1
	write "# Execute the trigger a second time (this takes a different codepath that reuses the symbol table)",!
	set ^x2=1
	write "# Execute [zwrite $STACK]",!
	zwrite $stack
	write "# Execute [zshow ""s""]",!
	zshow "s"
	write "# Execute [zshow ""v""::0]",!
	zshow "v"::0
	quit

trig	;
	new
	write "# Inside trigger entryref [trig^trigydb873]",!
	write "# Execute [zwrite $STACK]",!
	zwrite $stack
	write "# Execute [set trig=3]",!
	set trig=3
	write "# Execute [zshow ""s""]",!
	zshow "s"
	write "# Execute [zshow ""v""::2]",!
	zshow "v"::2
	write "# Execute [zshow ""v""::1]",!
	zshow "v"::1
	write "# Execute [zshow ""v""::0] : Expect to see local variables defined before trigger entry",!
	write "# See https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1618?diff_id=1243502228&start_sha=dad2040cd16c8e209418ba7ef89fd7b8c9ce0291#note_2312571263 for more discussion about this test case.",!
	zshow "v"::0
	write "# Leaving trigger entryref [trig^trigydb873]",!
	quit
