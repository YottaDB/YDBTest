;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
randrestrict
	set y="restrictlist.txt"
	open y
	use y read restrictlist
	set x="$ydb_dist/restrict.txt"
	open x
	use x
	for i=1:1:$length(restrictlist," ") do
	. write:$random(2) $piece(restrictlist," ",i),!
	quit

randrestrictgroup
	set y="restrictlist.txt"
	open y
	use y read restrictlist
	set x="$ydb_dist/restrict.txt"
	open x
	use x
	for i=1:1:$length(restrictlist," ") do
	. write $piece(restrictlist," ",i)
	. write:$random(2) ":",$ztrnlnm("groupname")
	. write !
	quit

breakfn
	write "# TESTING BREAK",!
	break
	write "Break command successfully ignored",!
	quit

zbreakfn
	set ^X=1
	write "# TESTING ZBREAK",!
	set $etrap="do incrtrap^incrtrap"
	zbreak zbreakchild^gtm8694:"set ^X=0  write ""ZBREAK not ignored"",!"
	do zbreakchild^gtm8694
	quit

zbreakchild
	write:^X "Zbreak command successfully ignored",!
	quit

zcmdlnefn
	write "# TESTING ZCMDLINE",!
	write $ZCMDLINE,!
	quit

zeditfn
	write "# TESTING ZEDIT",!
	set $etrap="do incrtrap^incrtrap"
	zedit "dummy.txt"
	quit

zsystemfn
	write "# TESTING ZSYSTEM",!
	set $etrap="do incrtrap^incrtrap"
	zsystem "echo ""ZSYSTEM not ignored"""
	quit

pipefn
	write "# TESTING PIPE",!
	set $etrap="do incrtrap^incrtrap"
	set p="pipeprocess"
	open p:(command="echo 'PIPE not ignored'")::"PIPE"
	use p  read x
	use $p  write x,!
	quit
trigmodfn
	write "# TESTING TRIGMOD",!
	set $etrap="do incrtrap^incrtrap"
	write $ztrigger("file","trigclear.trg")
	quit


