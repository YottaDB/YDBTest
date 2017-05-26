;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
longnames
	set $ztrap="goto errorAndCont^errorAndCont"
	do ^echoline
	write "Exceed the length of the name field",!
	set trig="+^a -command=S -xecute=""do ^twork"" -name="
	; 28 character trigger name for ^a
	set name="" for i=1:1:28 set name=name_$char(65)
	if '$ztrigger("item",trig_name) write "FAIL  28 char name",!
	;
	; 29 character trigger name for ^b
	; Only the last letter is different, but GT.M silently truncates
	; the name leading to an overlap collision, so this will fail
	set trig="+^b -command=S -xecute=""do ^twork"" -name="
	if $ztrigger("item",trig_name_"B") write "FAIL  29 char name",!
	;
	; 100 character name for ^c
	set trig="+^c -command=S -xecute=""do ^twork"" -name="
	for i=29:1:100 set name=name_$char(65)
	if $ztrigger("item",trig_name) write "FAIL 100 char name",!
	do run^validnames
	;
	; zprint/$text/zbreak of long (invalid) trigger name
	set longtrigname="^"_name_"#" set rand=$random(2)
	zprint:rand @longtrigname zbreak:'rand @longtrigname
	write $text(@longtrigname)
	zbreak:rand @longtrigname zprint:'rand @longtrigname
	quit

