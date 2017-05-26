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
pipeuname
assignstderr
	set dostderr=1
defaultstderr
	set uname="uname"
	set expect="PIPE"
	set error="error"
	new $etrap,$estack
	set $ecode="",$etrap="do err"
	if '$get(dostderr) open uname:(command="uname -a":readonly)::"pipe"
	else  open uname:(command="uname -a":readonly:stderr=error)::"pipe"
	use uname read line
	use $p write line,!
	close uname
	quit

err	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
