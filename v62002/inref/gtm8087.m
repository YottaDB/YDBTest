;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8087
	write !,"Let's validate the empty case",!
	write !,"zshow ""C""",!
	zshow "C"
	write !,"Now use the gtm8087xcalls1 extcall package",!
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write !,"zshow ""C""",!
	zshow "C"
	write !,"Let's see the output to a local",!
	write !,"zshow ""C"":x",!
	zshow "C":x
	zwrite x
	write !,"Now use the gtm8087xcalls3 extcall package",!
	zsystem "mkdir kiwi"
	if $&gtm8087xcalls3.rmdir("kiwi",.errno)
	write !,"zshow ""C""",!
	zshow "C"
	write !,"Let's see the output to a global",!
	write "zshow ""C"":^y",!
	zshow "C":^y
	zwr ^y
	write !,"Let's make sure if an existing subscript exists, it gets deleted",!
	write !,"set z(""C"")=""I should not be here"""
	set z("C")="I should not be here"
	zshow "C":z
	zwrite z
	write !,"set ^z(""C"")=""I should not be here"""
	set ^z("C")="I should not be here"
	zshow "C":^z
	zwrite ^z
	quit
locallimits31
	write !,"Let's check some limits on locals",!
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write !,"kill x",!
	kill x
	write "zshow ""C"":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)",!
	zshow "C":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
	quit
locallimits30
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)",!
	zshow "C":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)
	quit
locallimits29
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29)",!
	zshow "C":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29)
	quit
locallimits28
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28)",!
	zshow "C":x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28)
	zwrite x
	quit
globallimits5
	write !,"Let's check some limits on globals",!
	write !,"kill ^z",!
	kill ^z
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":^z(1,2,3,4,5)",!
	zshow "C":^z(1,2,3,4,5)
	quit
globallimits5b
	zwrite ^z
	quit
globallimits4
	write !,"kill ^z",!
	kill ^z
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":^z(1,2,3,4)",!
	zshow "C":^z(1,2,3,4)
	quit
globallimits4b
	zwrite ^z
	quit
globallimits3
	write !,"kill ^z",!
	kill ^z
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write "zshow ""C"":^z(1,2,3)",!
	zshow "C":^z(1,2,3)
	zwrite ^z
	quit
zshowstar
	write !,"Let's check zshow ""*""",!
	zsystem "touch apple"
	if $&gtm8087xcalls1.renameFile("apple","banana")
	write !,"zshow ""*""",!
	zshow "*"
	write !,"Let's check zshow ""*"" to a local",!
	write !,"kill x",!
	kill x
	write !,"zshow ""*"":x",!
	zshow "*":x
	write !,"zwr x(""C"",*)",!
	zwr x("C",*)
	write !,"Let's check zshow ""*"" to a global",!
	write !,"kill ^z",!
	kill ^z
	write !,"zshow ""*"":^z",!
	zshow "*":^z
	write !,"zwr ^z(""C"",*)",!
	zwr ^z("C",*)
	quit
