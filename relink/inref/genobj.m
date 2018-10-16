;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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

; Generate an object file by the specified name and of up to the specified size (within 16 bytes).
; The -embed_source compilation option should be enable for correct operation.
genobj(name,size)
	new i,file,object,charsPerLine,errno,chars,checkRate

	set:(""=$get(name)) name=$piece($zcmdline," ",1)
	set:(""=$get(size)) size=+$piece($zcmdline," ",2)

	set file=name_".m"
	set object=name_".o"
	set charsPerLine=8000	; Do not exceed the line output buffer OR the maximum source line length allowed by compiler

	; Print the routine name.
	open file:newversion
	use file
	write name,!," ;"
	set $x=0
	close file

	; Find out the initial file size.
	zcompile file
	if $&ydbposix.stat(object,,,,,,,,.curSize,,,,,,,,,.errno)

	; Recheck the size after the first write, upon which adjust the safe rate at which to recheck
	; whether we are approaching the desired limit.
	set checkRate=1

	; Stop inflating the file in a loop when fewer characters are remaining than printed on one
	; iteration.
	for i=1:1 quit:(size-charsPerLine<curSize)  do
	.	; Print another long line.
	.	open file:append
	.	use file
	.	write $justify(" ",charsPerLine),!," ;"
	.	set $x=0
	.	close file
	.
	.	; If it is time to recheck, do so and adjust the rate.
	.	if (i>=checkRate) do
	.	.	zcompile file
	.	.	if $&ydbposix.stat(object,,,,,,,,.curSize,,,,,,,,,.errno)
	.	.	set checkRate=(size-curSize)\charsPerLine\2
	.	.	set:(checkRate>20) checkRate=20
	.	.	set i=0

	; Print the remaining number of characters.
	open file:append
	use file
	write $justify(" ",size-curSize)
	set $x=0
	close file

	zcompile file
	quit
