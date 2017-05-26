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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/memory_leak test. It
; verifies that cycling through encryption-enabled database and
; device I/O operations does not exhibit increases in memory
; consumption.
;
; This routine works by first "priming" the memory use with a
; small number of iterations of the same operations that are
; later repeated many more times.
;
; The test is careful about not mistaking the memory allocations
; due to local variable initialization and management and
; enforces garbage collection to rid the stringpool of temporary
; buffers.
;
; The test consludes with a random rotation of seven pregenerated
; configuration files, which exercises a variety of internal key
; allocation, lookup, storage, management, and deallocation
; procedures.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

memoryleak
	new i,memory,failed,error,option,quit,COUNT
	set COUNT=500
	set failed=0
	set memory=0
	do initDevices
	set:($zusedstor>memory) memory=$zusedstor
	do initDatabases
	set:($zusedstor>memory) memory=$zusedstor
	for i=1:1:10 do
	.	do openDevices(1)
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do writeToDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do closeDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do openDevices(0)
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do readFromDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do closeDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do openDevices(0)
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do readAllFromDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do closeDevices
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do writeToDatabases
	.	set:($zusedstor>memory) memory=$zusedstor
	.	do readFromDatabases
	.	set:($zusedstor>memory) memory=$zusedstor
	view "STP_GCOL"
	; {OPEN/CLOSE} cycle
	for i=1:1:COUNT do
	.	do openDevices(1)
	.	do closeDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an {OPEN/CLOSE} cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	; {OPEN/USE/WRITE/CLOSE} cycle
	for i=1:1:COUNT do
	.	do openDevices(1)
	.	do writeToDevices
	.	do closeDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an {OPEN/USE/WRITE/CLOSE} cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	; {OPEN/USE/READ/CLOSE} cycle
	for i=1:1:COUNT do
	.	do openDevices(0)
	.	do readFromDevices
	.	do closeDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an {OPEN/USE/READ/CLOSE} cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	; OPEN/{USE/WRITE}/CLOSE cycle
	do openDevices(1)
	for i=1:1:COUNT do writeToDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an OPEN/{USE/WRITE}/CLOSE cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	do closeDevices
	; OPEN/{USE/READ}/CLOSE cycle
	do openDevices(0)
	for i=1:1:COUNT do readFromDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an OPEN/{USE/READ}/CLOSE cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	do closeDevices
	; OPEN/USE/{WRITE}/{READ}/CLOSE cycle
	do openDevices(1)
	for i=1:1:COUNT do writeToDevices
	do readAllFromDevices
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during an OPEN/USE/{WRITE}/{READ}/CLOSE cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	do closeDevices
	; Cycle of database writes
	for i=1:1:COUNT do writeToDatabases
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during a database write cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	; Cycle of database reads
	for i=1:1:COUNT do readFromDatabases
	view "STP_GCOL"
	if ($zusedstor>memory) do
	.	use $principal
	.	write "TEST-E-FAIL, Memory usage increased during a database read cycle from "_memory_" to "_$zusedstor,!
	.	set memory=$zusedstor
	.	set failed=1
	; Prime the memory for the subsequent configuration file rotations.
	set COUNT=50
	set quit=0
	for i=1:1:COUNT set option(i)=-1
	for i=0:1:7 do
	.	hang 1 ; Hang is for the systems where stat does not provide subsecond granularity.
	.	zsystem "cp gtmcrypt"_(i#7+1)_".cfg "_$ztrnlnm("gtmcrypt_config")_"; touch "_$ztrnlnm("gtmcrypt_config")
	.	set error=""
	.	do
	.	.	new $etrap
	.	.	set $etrap="set error=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	.	.	open "dev":key="abc"
	.	.	close "dev"
	.	set:($zusedstor>memory) memory=$zusedstor
	.	if (error'="CRYPTKEYFETCHFAILED") use $principal write "TEST-E-FAIL, Attempt to use a missing key caused "_$select(""=error:"no error",1:"'"_error_"'")_" instead of 'CRYPTKEYFETCHFAILED'.",!
	.	view "STP_GCOL"
	; Cycle of random configuration file rotations
	for i=1:1:COUNT do  quit:quit
	.	set option(i)=$random(7)+1
	.	zsystem "cp gtmcrypt"_option(i)_".cfg "_$ztrnlnm("gtmcrypt_config")_"; touch "_$ztrnlnm("gtmcrypt_config")
	.	set error=""
	.	do
	.	.	new $etrap
	.	.	set $etrap="set error=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	.	.	set:($zusedstor>memory) memory=$zusedstor
	.	.	open "dev":key="abc"
	.	.	close "dev"
	.	view "STP_GCOL"
	.	if ($zusedstor>memory)&(i'=1) do  set quit=1 quit
	.	.	set COUNT=i
	.	.	use $principal
	.	.	write "TEST-E-FAIL, Memory usage increased during a configuration file rotation cycle from "_memory_" to "_$zusedstor,!
	.	.	write "  Sequence of configuration files chosen:",!
	.	.	for i=1:1:COUNT write "  "_i_") gtmcrypt"_option(i)_".cfg",!
	.	.	set failed=1
	.	if (error'="CRYPTKEYFETCHFAILED") use $principal write "TEST-E-FAIL, Attempt to use a missing key caused "_$select(""=error:"no error",1:"'"_error_"'")_" instead of 'CRYPTKEYFETCHFAILED'.",!
	use $principal
	write:('failed) "TEST-I-PASS, No memory leaks detected.",!
	quit

initDevices
	new i
	for i=1:1:10 do
	.	set DEV(i)="dev"_i
	.	set IV(i)=$$^%RANDSTR($random(17),,"AN")
	for i=1:1:9 do
	.	set WRITE(i)=$$^%RANDSTR($random(10),,"ANP")
	quit

openDevices(newversion)
	new i
	if (newversion) for i=1:1:10 open DEV(i):(newversion:key="key"_i_" "_IV(i))
	if ('newversion) for i=1:1:10 open DEV(i):(key="key"_i_" "_IV(i))
	quit

closeDevices
	new i
	for i=1:1:10 close DEV(i)
	quit

readFromDevices
	new i,line
	for i=1:1:10 do
	.	use DEV(i)
	.	read line
	quit

readAllFromDevices
	new i,line
	for i=1:1:10 do
	.	use DEV(i)
	.	for  quit:$zeof  read line
	quit

writeToDevices
	new i
	for i=1:1:10 do
	.	use DEV(i)
	.	write WRITE(i#9+1),!
	quit

initDatabases
	set NUMOFWRITES=0
	set (^a,^b,^c,^d,^e,^f,^g,^h,^i,^j)=1
	quit

writeToDatabases
	set ^a=WRITE((NUMOFWRITES+1)#9+1)
	set ^b=WRITE((NUMOFWRITES+2)#9+1)
	set ^c=WRITE((NUMOFWRITES+3)#9+1)
	set ^d=WRITE((NUMOFWRITES+4)#9+1)
	set ^e=WRITE((NUMOFWRITES+5)#9+1)
	set ^f=WRITE((NUMOFWRITES+6)#9+1)
	set ^g=WRITE((NUMOFWRITES+7)#9+1)
	set ^h=WRITE((NUMOFWRITES+8)#9+1)
	set ^i=WRITE((NUMOFWRITES+9)#9+1)
	set ^j=WRITE((NUMOFWRITES+10)#9+1)
	set NUMOFWRITES=NUMOFWRITES+10
	quit

readFromDatabases
	if ^a
	if ^b
	if ^c
	if ^d
	if ^e
	if ^f
	if ^g
	if ^h
	if ^i
	if ^j
	quit
