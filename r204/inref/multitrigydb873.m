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
	s x=$ztrigger("item","+^x2 -commands=set -xecute=""set x=1 do trig^multitrigydb873"" -name=x2set1")   ; load a SET trigger on ^x2 global
	s x=$ztrigger("item","+^x2 -commands=set -xecute=""set x=2 do trig^multitrigydb873"" -name=x2set2")   ; load a SET trigger on ^x2 global
	write "# Execute [set x2=2]",!
	set x2=2
	write "# Execute [zwrite $STACK]",!
	zwrite $stack
	write "# Execute [zshow ""s""]",!
	zshow "s"
	write "# Execute [zshow ""v""::0]",!
	zshow "v"::0
	write "# Execute [set ^x2=1] which invokes the trigger [do trig^multitrigydb873]",!
	set ^x2=1
	write "# Execute [zwrite $STACK]",!
	zwrite $stack
	write "# Execute [zshow ""s""]",!
	zshow "s"
	write "# Execute [zshow ""v""::0]",!
	zshow "v"::0
	quit

trig	;
	; Lock makes sure this trigger does not interleave its output when called twice simultaneously.
	lock +multitrigydb873
	set out=$ZTNAME_"out.log"  open out  use out
	write "# Inside trigger entryref [trig^multitrigydb873]",!
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
	write "# Execute [zshow ""v""::0]",!
	zshow "v"::0
	write "# Leaving trigger entryref [trig^multitrigydb873]",!
	use $PRINCIPAL
	lock -multitrigydb873
	quit
