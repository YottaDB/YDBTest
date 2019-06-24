;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
; Does a majority of the tests for $ztimeout
; The extra functions at the bottom are tests the either cause errors
; Or need to be run in separate processes
gtm6135 ;
	write "Check that $ztimeout starting value is -1: "
	if $ztimeout=-1 write "PASS $ztimeout started at -1",!
	else  write "FAIL $ztimeout did not start correctly Expected: -1; Actual: ",$ztimeout,!
	;
	write "Check that 'set $ztimeout=""2:a(1)=0""' after 2 seconds and not before: "
	set $ztimeout="2:set a(1)=0"
	hang 0.5 if $get(a(1))=0 set a(1)=1 quit
	hang 2
	if $get(a(1))=0 write "PASS a(1) is correctly 0",!
	else  if $get(a(1))=1 write "FAIL a(1) is 1. This should be 0 due to $ztimeout vector",!
	else  write "FAIL a(1) is not set correctly Expected: 0; Actual: ",$get(a(1)),!
	;
	kill a
	write "Check that 'set $ztimeout=3' will reuse a(1)=0: "
	set $ztimeout=3
	for i=1:1:2 hang 0.5 if $get(a(1))=0 set a(1)=1 quit
	hang 3
	if $get(a(1))=0 write "PASS a(1) is correctly 0",!
	else  if $get(a(1))=1 write "FAIL a(1) is 1. This should be 0 due to $ztimeout vector",!
	else  write "FAIL a(1) is not set correctly Expected: 0; Actual: ",$get(a(1)),!
	;
	kill a
	write "Check that 'set $ztimeout=2' and then 'set $ztimeout="":set a(2)=0""' before the timeout will change the vector without affecting the time remaining: "
	set $ztimeout=2
	hang 0.5
	set $ztimeout=":set a(2)=0"
	hang 2
	if $get(a(2))=0 write "PASS a(2) is correctly 0",!
	else  write "FAIL a(2) is not set correctly Expected: 0; Actual: ",$get(a(2)),!
	;
	kill a
	write "Check that 'set $ztimeout=0' will trigger a(2)=0 immediately: "
	set $ztimeout=0
	hang 0.5
	if $get(a(2))=0 write "PASS a(2) is correctly 0",!
	else  write "FAIL a(2) is not set correctly Expected: 0; Actual: ",$get(a(2)),!
	;
	kill a
	write "Check that 'set $ztimeout=-1' will cancel the running timeout: "
	set $ztimeout=1
	set $ztimeout=-1
	hang 2
	if $get(a(2))="" write "PASS a(2) is correctly unset",!
	else  write "FAIL a(2) is not unset Expected: ; Actual: ",$get(a(2)),!
	;
	write "Check that 'set $ztimeout=""2:""' will set the trigger vector to $ztrap instead of $etrap if it is set",!
	write "$ztrap is currently set to 'set c(1)=0': "
	set $ztrap="set c(1)=0"
	set $ztimeout="2:"
	hang 0.5 if $get(c(1))=0 set c(1)=1 quit
	hang 2
	if $get(c(1))=0 write "PASS c(1) is correctly 0",!
	else  if $get(c(1))=1 write "FAIL a(1) is 1. This should be 0 due to vector is not valid and $ztrap is set c(1)=0",!
	else  write "FAIL c(1) is not set correctly Expected: 0; Actual: ",$get(c(1)),!
	;
	; this happens last because $etrap exits after triggering
	set $ztrap=""
	set $ecode=""
	write "Check that 'set $ztimeout=""2:""' will set the trigger vector to $etrap when $ztrap is not set",!
	write "$etrap is currently set to 'set b(1)=0': "
	set $etrap="set $ecode="""" set b(1)=0"
	do
	. set $ztimeout="2:"
	. hang 0.5 if $get(b(1))=0 set b(1)=1 quit
	. hang 2
	if $get(b(1))=0 write "PASS b(1) is correctly 0",!
	else  if $get(b(1))=1 write "AIL a(1) is 1. This should be 0 due to vector is not valid and $etrap is set c(1)=0",!
	else  write "FAIL b(1) is not set correctly Expected: 0; Actual: ",$get(b(1)),!
	quit
	;
; tries a new $ztimeout
; causes a %GTM-E-SVNONEW
newztimeout ;
	write "Trying new of $ztimeout should give error %GTM-E-SVNONEW",!
	new $ztimeout
	quit
	;
; tries a kill $ztimeout
; causes a %GTM-E-VAREXPECTED
killztimeout
	write "Trying a kill of $ztimeout should give error %GTM-E-VAREXPECTED",!
	kill $ztimeout
	quit
	;
backgroundA ;
	for  quit:$get(^start(1))=1  hang 0.01 ; wait for the trigger (set by gtm6135.csh) before starting timeout
	set $ztimeout="3:set ^a(1)=1"
	hang 4
	set ^done(1)=1
	quit
	;
backgroundB ;
	for  quit:$get(^start(1))=1  hang 0.01 ; wait for the trigger (set by gtm6135.csh) before starting timeout
	set $ztimeout="3:set ^a(2)=1"
	hang 4
	set ^done(2)=1
	quit
	;
