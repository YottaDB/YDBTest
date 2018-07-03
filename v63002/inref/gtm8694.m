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
;
breakfn
	write "# TESTING BREAK",!
	break
	write "Break command successfully ignored",!
	quit

zbreakfn
	write "# TESTING ZBREAK",!
	set $etrap="do incrtrap^incrtrap"
	zbreak zbreakchild^gtm8694
	do zbreakchild^gtm8694
	quit

zbreakchild
	write "Zbreak command successfully ignored",!
	quit

zcmdlnefn
	write "# TESTING ZCMDLINE",!
	write $ZCMDLNE,!
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


