;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztslate
	do init
	do main
	write !,"Repeat the same tests, but wrap them in an explicit transaction",!
	do maintxn
	quit

init
	kill ^a,^fired,x
	do item^dollarztrigger("tfile^ztslate","ztslate.trg.trigout")
	; need to use trigger enabled etrap handler incrtrap^inspectISV
	; which prints the error message and continues
	set ^etrap="set tab=$c(9),backlevel=1 do incrtrap^inspectISV"
	; using ugly $ztrap so that I can get ^incrtrap which prints
	; the error message and continues
	set $ztrap="goto ^incrtrap"
	quit

maintxn
	set txn=1
main
	do ^echoline
	do ztwoundeftest
	do ztslatetest
	do ztslateundeftest
	do ztwoundeftestintrg
	do newslate4txn
	do trollslate
	do restartslate
	do commitslate
	do startcommitslate
	do ^echoline
	quit

	; set $ztwo to an undef variable
	; this is here only because $ztslate failed and ztwo was not
	; tested similarly
ztwoundeftest
	do ^echoline
	write "set $ztwormhole to an undef variable",!
	set $ztwormhole=undef
	quit

	; set $ztwo to an undef variable inside a trigger
ztwoundeftestintrg
	do ^echoline
	if $data(txn) tstart (x)
	write "set $ztwormhole to an undef variable in a trigger",!
	write "You will see two error messages from the trigger's $etrap handler",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^c=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; set ztslate inside a trigger
ztslatetest
	do ^echoline
	if $data(txn) tstart (x)
	write "set $ztslate to a valid variable",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^a=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; set ztslate to an undef variable inside a trigger
ztslateundeftest
	do ^echoline
	if $data(txn) tstart (x)
	write "set $ztslate to an undef variable",!
	write "You will see two error messages from the trigger's $etrap handler",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^b=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; show that $ztslate is nulled at each transaction start
newslate4txn
	do ^echoline
	if $data(txn) tstart (x)
	write:'$data(txn) "show $ztslate is empty for each imlpict transaction start",!
	write:$data(txn) "show $ztslate is not empty for each imlpict transaction when "
	write:$data(txn) "wrapped by an explicit transaction",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^a=$i(x,10),^a=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; show that $ztslate is not valid for SET after trollback kills the trigger context
trollslate
	do ^echoline
	if $data(txn) tstart (x)
	write "use $ztslate with trollback in trigger",!
	write:'$data(txn) "because trollback breaks the trigger context, expect error messages from $etrap and $ztrap",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^d=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; show that $ztslate is nulled at each transaction restart
restartslate
	do ^echoline
	if $data(txn) tstart (x)
	write "use $ztslate with trestart in trigger",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^e=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; show that $ztslate is valid for SET after a $etrap'ed tcommit does not reset trigger context
commitslate
	do ^echoline
	if $data(txn) tstart (x)
	write "use $ztslate with tcommit in trigger",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^f=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; show that $ztslate is not nulled at each sub transaction start/commit
startcommitslate
	do ^echoline
	if $data(txn) tstart (x)
	write "use $ztslate with tstart/tcommit in trigger",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^g=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	quit

	; trigger routine to set $ztslate to an undef variable
undefslate
	set $etrap=^etrap
	set $ztslate=$ztslate_undef
	quit

	; trigger routine to set $ztwormhole to an undef variable
undefztwo
	set $etrap=^etrap
	set $ztwormhole=$ztwormhole_undef
	quit

	; trigger routine to show that $ztslate is not a valid SET after trollback
rollback
	set $etrap=^etrap
	set $ztslate=$ztslate_"I've been triggered!"
	write "inside:",?7,$ztslate,!
	trollback
	set $ztslate=$ztslate_"I've been trollbacked!"
	write "rolled:",?7,$ztslate,!
	quit

	; trigger routine to show that $ztslate is updated or not after a trestart
restart
	set $etrap=^etrap
	set $ztslate=$ztslate_"I've been triggered!"
	write "inside:",?7,$ztslate,!
	if $trestart<1  do
	. set $ztslate=$ztslate_"time to restart!"
	. write "trestart:",?7,$ztslate,!
	. trestart
	if $trestart>0  do
	. set $ztslate=$ztslate_"I've been trestarted!"
	write "restart:",?7,$ztslate,!
	quit

	; trigger routine to show that $ztslate can still be changed
commit
	set $etrap=^etrap
	set $ztslate=$ztslate_"I've been triggered!"
	write "inside:",?7,$ztslate,!
	tcommit
	set $ztslate=$ztslate_"I've been committed!"
	write "commit:",?7,$ztslate,!
	quit

	; trigger routine to the issues tstart/tcommit to show that $ztslate is not nulled
start
	set $etrap=^etrap
	set $ztslate=$ztslate_"I've been triggered!"
	write "inside:",?7,$ztslate,!
	tstart ()
	set $ztslate=$ztslate_"I've been started!"
	write "start:",?7,$ztslate,!
	tcommit
	set $ztslate=$ztslate_"I've been committed!"
	write "commit:",?7,$ztslate,!
	quit

	; This non-restartable test case cause an assert
assert
	do ^echoline
	write "This caused an assert instead of issuing a %YDB-E-TRESTNOT",!
	do init
	set txn=1
	if $data(txn) tstart
	write "use $ztslate with trestart in trigger",!
	write "before:",?7,$ztslate,?32,$ztwormhole,!
	set ^z=$i(x,10)
	write "after:",?7,$ztslate,?32,$ztwormhole,!
	if $data(txn) tcommit
	do ^echoline
	quit

assertrtn
	set $etrap=^etrap
	set $ztslate=$ztslate_"I've been triggered!"
	write "inside:",?7,$ztslate,!
	if $trestart<1 trestart
	set $ztslate=$ztslate_"I've been trestarted!"
	write "restart:",?7,$ztslate,!
	quit

tfile
	;-*
	;+^a -commands=S -xecute="write ""inside:"",?7,$ztslate,! set $ztslate=$ztslate_$char(65,66)_^a"
	;+^b -commands=S -xecute="write ""inside:"",?7,$ztslate,! do undefslate^ztslate"
	;+^c -commands=S -xecute="set $ztslate=$ztslate_""set undef ztwo"" write ""inside:"",?7,$ztwormhole,! do undefztwo^ztslate"
	;;Disabled until GTM-7507 is fixed;+^d -commands=S -xecute="do rollback^ztslate"
	;+^e -commands=S -xecute="do restart^ztslate"
	;+^f -commands=S -xecute="do commit^ztslate"
	;+^g -commands=S -xecute="do start^ztslate"
	;+^z -commands=S -xecute="do assertrtn^ztslate"
