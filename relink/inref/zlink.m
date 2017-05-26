;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Test - ZLINK functionality
;

zlink

	do init

	set targetdir=""
	set usefullpathonzlink=0
	set iteration=""
	set autorelinkinuse=0

	set origzroutines=$zroutines

	; no auto-relink
	write "Pass 1: no auto-relink",!,!
	set iteration="pass1"
	set $zroutines="apple "_origzroutines
	set autorelinkinuse=0
	do ^zlinkcases

	; auto-relink
	write "Pass 2: auto-relink",!,!
	set iteration="pass2"
	set $zroutines="apple* "_origzroutines
	set autorelinkinuse=1
	set targetdir="apple"
	do ^zlinkcases

	; auto-relink with full paths on zlink
	set usefullpathonzlink=1
	write "Pass 3: auto-relink with zlink using full path",!
	set iteration="pass3"
	set $zroutines="apple* "_origzroutines
	set autorelinkinuse=1
	set targetdir="apple"
	do ^zlinkcases
	set usefullpathonzlink=0

	; auto-relink with a bogus directory
	write "Pass 4: auto-relink with bogus directory",!,!
	set iteration="pass4"
	; this is needed so the subsequent set will not complain
	if $&gtmposix.mkdir("kiwi",666,.errno)
	set $zroutines="apple* banana* kiwi* orange* "_origzroutines
	if $&gtmposix.rmdir("kiwi",.errno)
	set targetdir="apple"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs target in first
	write "Pass 5: auto-relink with three subdirs target in first",!,!
	set iteration="pass5"
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="apple"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs; target in the first with full paths on zlink
	write "Pass 6: auto-relink with three subdirs; target in the first with full paths on zlink",!,!
	set iteration="pass6"
	set usefullpathonzlink=1
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="apple"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs target in the second
	write "Pass 7: auto-relink with three subdirs target in the second",!,!
	set iteration="pass7"
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="banana"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs; target in the second with full paths on zlink
	write "Pass 8: auto-relink with three subdirs; target in the second with full paths on zlink",!,!
	set iteration="pass8"
	set usefullpathonzlink=1
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="banana"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs target in the last
	write "Pass 9: auto-relink with three subdirs target in the last",!,!
	set iteration="pass9"
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="orange"
	set autorelinkinuse=1
	do ^zlinkcases

	; auto-relink with three subdirs; target in the last with full paths on zlink
	write "Pass 10: auto-relink with three subdirs; target in the last with full paths on zlink",!,!
	set iteration="pass10"
	set usefullpathonzlink=1
	set $zroutines="apple* banana* orange* "_origzroutines
	set targetdir="orange"
	set autorelinkinuse=1
	do ^zlinkcases

	quit

init
	new errno
	; setup subdirectories
	if $&gtmposix.umask(0,,.errno)
	if $&gtmposix.mkdir("apple",511,.errno)
	if $&gtmposix.mkdir("banana",511,.errno)
	if $&gtmposix.mkdir("orange",511,.errno)
	quit
