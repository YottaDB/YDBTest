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
regression ;
	kill ^x
	set x=$translate($justify(1,2**19)," ",$char(3))
	set ^y=x					; save a copy of the local variable in a global ^y for later comparison
	zshow "v":^x				; zshow "v" into global ^x
	kill x						; kill local x in preparation for it to be restored from global ^x
	if $$^%ZSHOWVTOLCL("^x")	; restore local x from zshow "v" output stored in global ^x
	if x'=^y write "FAIL",!		; check that restored local x matches global ^y
	else  write "PASS",!
	quit

zwrtac ;
	set c=1,*a=c,*b(2)=c	; Create two aliases and an alias container
	kill *a,*c				; Kill the aliases, leaving only the alias container
	set x="0"				; Generate a string expression with a length close to MAX_STRLEN
	for i=1:1:1048566  set x=x_"0"
	set x=x_"1"
	set @("$ZWRTAC="_x)		; Do SET @($ZWRTAC=expr) using the long expression string
	kill x					; Kill the variable with the long string for a cleaner ZWRITE
	zwrite					; ZWRITE to show the final $ZWRTAC variables
	quit

zwrtaclvn ;
	; Create alias container a(1) pointing to $ZWRTAC1 lvn with value close to 1Mib
	set ^expect=$j(1,2**20-15)
	set b=^expect,*a(1)=b
	kill *b,val
	; Record zwrite output with $ZWRTAC1 lvn in file "zwr.txt"
	set file="zwr.txt"
	open file:(newversion:stream:nowrap)
	use file
	zwrite
	close file
	; Kill all variables and alias variables
	kill
	kill *
	; Verify that ZWRITE output now shows nothing
	zwrite
	; Read the file back in and process it
	set file="zwr.txt"
	open file:(readonly:stream:nowrap)
	use file:(width=2**20)
	for  read line($increment(nlines)) quit:$zeof
	close file
	kill line(nlines) if $increment(nlines,-1)
	; Verify that ZWRITE output now shows the same 1Mib
	for i=1:1:nlines set @line(i)
	; Connect $ZWRTAC1 with the variable name "connect"
	set *newlvn=a(1)
	kill line,i,nlines,file
	set *b=a(1),^actual=b
	if ^actual'=^expect write "TEST-E-FAIL : Expected output stored in ^expect. Actual output stored in ^actual",!
	else  write "PASS : Successfully restored close to a 1Mib value through $ZWRTAC1 in ZWRITE output",!
	quit


missingnew ;
	zwrite
	set %ZSHOWvbase=1 zshow "v":^x do ^%ZSHOWVTOLCL("^x")
	zwrite
	quit

nooutput ;
	set x(1)=1 kill ^x zshow "v":^x kill x do ^%ZSHOWVTOLCL("^x")
	set ret(1)=1 kill ^x zshow "v":^x kill ret do ^%ZSHOWVTOLCL("^x")
	zwrite
	quit

nowork ;
	kill ^x
	set x=$translate($justify(1,2**20)," ",$char(3))
	set ^y=x					; save a copy of the local variable in a global ^y for later comparison
	zshow "v":^x				; zshow "v" into global ^x
	kill x						; kill local x in preparation for it to be restored from global ^x
	if $$^%ZSHOWVTOLCL("^x")	; Try to restore local x from zshow "v" output stored in global ^x, but expect an error
	if x=^y write "FAIL: Expected 'Could not work...' error",!
	quit

miblimit ;
	kill ^x
	set x=$translate($justify(1,2**20-15)," ",$char(3))
	set ^y=x					; save a copy of the local variable in a global ^y for later comparison
	zshow "v":^x				; zshow "v" into global ^x
	kill x						; kill local x in preparation for it to be restored from global ^x
	if $$^%ZSHOWVTOLCL("^x")	; Try to restore local x from zshow "v" output stored in global ^x, but expect an error
	if x'=^y write "FAIL: x not restored",!		; check that restored local x matches global ^y
	else  write "PASS: x successfully restored",!
	quit

bigkey ;
	kill ^x
	; Create a local variable node referenced by a key > 8192 bytes in length
	for i=1:1:16  do
	. set t(i)="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	set x(t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1))="TESTVALUE"
	; Save a copy of the local variable in a global ^y for later comparison
	set ^y=x(t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1))
	zshow "v":^x    ; zshow "v" into global ^x
	kill x          ; kill local x in preparation for it to be restored from global ^x
	if $$^%ZSHOWVTOLCL("^x")        ; restore local x from zshow "v" output stored in global ^x
	if x'=^y write "FAIL",! ; check that restored local x matches global ^y
	else  write "PASS",!
	quit

nonempty ;
	kill ^x
	; Create a local variable node referenced by a key > 8192 bytes in length
	for i=1:1:16  do
	. set t(i)="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	set x(t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1))="TESTVALUE"
	; Save a copy of the local variable in a global ^y for later comparison
	set ^y=x(t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1),t(1))
	zshow "v":^x    ; zshow "v" into global ^x
	kill x          ; kill local x in preparation for it to be restored from global ^x
	if $$^%ZSHOWVTOLCL("^x")        ; restore local x from zshow "v" output stored in global ^x
	if x'=^y write "FAIL",! ; check that restored local x matches global ^y
	else  write "PASS",!
	quit
