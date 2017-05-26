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
; A helper script employed in the encryption/device_encryption
; test. It contains a number of scenarios that induce particular
; encryption / decryption state changes and validate GT.M's
; responses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

encryptionstate
	set FILE=$piece($zcmdline," ",1)
	set KEY1=$piece($zcmdline," ",2)
	set IV1=$piece($zcmdline," ",3)
	set KEY2=$piece($zcmdline," ",4)
	set IV2=$piece($zcmdline," ",5)
	set HANDLER="set error=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	do scenario1
	do scenario2
	do scenario3
	do scenario4
	do scenario5
	do scenario6
	do scenario7
	do scenario8
	do scenario9
	do scenario10
	do scenario11
	do scenario12
	do scenario13
	do scenario14
	do scenario15
	do scenario16
	do scenario17
	do scenario18
	do scenario19
	quit

; CLOSE followed by an OPEN with different KEYNAME (pointing to a different key) should not issue error, but
; should read garbage.
scenario1
	new z,c
	open FILE:(newversion:key=KEY1_" "_IV1)
	use FILE
	write "hello world",!
	close FILE
	; Should not issue error but should read garbage!
	set c=$random(3)+1
	if (c=1) do
	.	open FILE:(key=KEY1_" "_IV2:ichset="M")
	else  if (c=2) do
	.	open FILE:(key=KEY2_" "_IV1:ichset="M")
	else  do
	.	open FILE:(key=KEY2_" "_IV2:ichset="M")
	use FILE
	read z
	close FILE
	do:(z="hello world") error(1,"garbage",z)
	quit

; CLOSE:NODESTROY followed by an OPEN with different KEYNAME should issue error.
scenario2
	new c,error
	open FILE:(newversion:key=KEY1_" "_IV1)
	use FILE
	write "hello world",!
	close FILE:nodestroy
	; Should issue error.
	set c=$random(3)+1
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if (c=1) do
	.	.	open FILE:(key=KEY1_" "_IV2)
	.	else  if (c=2) do
	.	.	open FILE:(key=KEY2_" "_IV1)
	.	else  do
	.	.	open FILE:(key=KEY2_" "_IV2)
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(2,"CRYPTNOOVERRIDE",error)
	quit

; OPEN (without KEY and IV specified) followed by a USE (with key and IV specified) should work.
scenario3
	new z
	open FILE:newversion
	use FILE:(KEY=KEY1_" "_IV1)
	write "hello world",!
	close FILE
	open FILE
	use FILE:(KEY=KEY1_" "_IV1)
	read z
	do:(z'="hello world") error(3,"hello world",z)
	close FILE
	quit

; Same as scenario3 but should issue an error because a different KEY or IV is specified after an I/O.
scenario4
	new c,error
	open FILE:newversion
	use FILE:(key=KEY1_" "_IV1)
	write "hello world",!
	; Should issue error.
	set c=$random(3)+1
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if (c=1) do
	.	.	use FILE:(key=KEY1_" "_IV2)
	.	else  if (c=2) do
	.	.	use FILE:(key=KEY2_" "_IV1)
	.	else  do
	.	.	use FILE:(key=KEY2_" "_IV2)
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(4,"CRYPTNOOVERRIDE",error)
	close FILE
	quit

; Same as scenario4, but should work since no I/O happened in between key changes.
scenario5
	new c,key,iv,error,z
	open FILE:newversion
	use FILE:(key=KEY1_" "_IV1)
	set c=$random(3)+1
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if (c=1) do
	.	.	set key=KEY1,iv=IV2
	.	else  if (c=2) do
	.	.	set key=KEY2,iv=IV1
	.	else  do
	.	.	set key=KEY2,iv=IV2
	.	use FILE:(key=key_" "_iv)
	do:(error'="") error(5,,error)
	write "hello world",!
	close FILE
	open FILE:(key=key_" "_iv)
	use FILE
	read z
	close FILE
	do:(z'="hello world") error(5,"hello world",z)
	quit

; Should not mix unencrypted and encrypted content in the same device.
scenario6
	open FILE:newversion
	use FILE
	write "hello world",!
	; Should raise error.
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	use FILE:(key=KEY1_" "_IV1)
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(6,"CRYPTNOOVERRIDE",error)
	write "zallo world",!
	close FILE
	quit

; Same as scenario6, but no I/O happened.
scenario7
	new z
	open FILE:newversion
	use FILE
	; Should not issue error
	use FILE:(key=KEY1_" "_IV1)
	write "hello world",!
	close FILE
	open FILE:(key=KEY1_" "_IV1)
	use FILE
	read z
	close FILE
	do:(z'="hello world") error(7,"hello world",z)
	quit

; Duplicate USE should not cause error.
scenario8
	new z1,z2
	open FILE:newversion
	use FILE:(key=KEY1_" "_IV1)
	write "hello world",!
	; Should not issue error
	use FILE:(key=KEY1_" "_IV1)
	write "zallo world",!
	close FILE
	open FILE:(key=KEY1_" "_IV1)
	use FILE
	read z1
	read z2
	close FILE
	do:(z1'="hello world") error(8,"hello world",z1)
	do:(z2'="zallo world") error(8,"zallo world",z2)
	quit

; Migration from unencrypted to encrypted using CLOSE:NODESTROY should be disallowed.
scenario9
	new error
	open FILE:newversion
	use FILE
	write "hello world",!
	close FILE:nodestroy
	; Should issue an error
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	open FILE:(key=KEY1_" "_IV1)
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(9,"CRYPTNOOVERRIDE",error)
	close FILE
	quit

; A key name that is too long should not be accepted.
scenario10
        new key,error
        set key=$$^%RANDSTR(10000,,"AN")
	; Should issue an error
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
        .	open FILE:(newversion:key=key_" "_IV1)
	do:(error="")!(error'="DEVPARTOOBIG") error(10,"DEVPARTOOBIG",error)
        quit

; Specifying a bad key name should result in error.
scenario11
        new key,error
        set key=$$^%RANDSTR($random(10)+1,,"AN")
	; Should issue an error
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
        .	open FILE:(newversion:key=key_" "_IV1)
	do:(error="")!(error'="CRYPTKEYFETCHFAILED") error(11,"CRYPTKEYFETCHFAILED",error)
        quit

; Disabling encryption / decryption should work until writes / reads are done.
scenario12
	new c,line,error
	set c=$random(3)+1
	if (c=2) do
	.	open FILE:newversion
	.	use FILE
	.	write "hello world",!
	.	close FILE
	else  do
	.	open FILE
	.	close FILE:delete
	open FILE
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if (c=1) do
	.	.	use FILE:(key=KEY1_" "_IV1)
	.	.	use FILE:(key="")
	.	.	write "hello world",!
	.	.	use FILE:rewind
	.	.	read line
	.	else  if (c=2) do
	.	.	use FILE:(ikey=KEY1_" "_IV1)
	.	.	use FILE:(ikey="")
	.	.	read line
	.	else  do
	.	.	use FILE:(okey=KEY1_" "_IV1)
	.	.	use FILE:(okey="")
	.	.	write "hello world",!
	.	.	close FILE
	.	.	open FILE
	.	.	use FILE
	.	.	read line
	.	close FILE
	do:(error'="") error(12,,error_" (case "_c_")")
	do:(line'="hello world") error(12,"hello world",line_" (case "_c_")")
	quit

; Disabling encryption / decryption is not allowed after some writes / reads are done.
scenario13
	new c,line,error
	set c=$random(4)+1
	if (c=1)!(c=3) do
	.	open FILE:(newversion:key=KEY1_" "_IV1)
	.	use FILE
	.	write "hello world",!
	.	close FILE
	else  do
	.	open FILE
	.	close FILE:delete
	open FILE
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if (c<3) do
	.	.	use FILE:(key=KEY1_" "_IV1)
	.	.	if (c=1) do
	.	.	.	read line
	.	.	else  write "hello world",!
	.	.	use FILE:(key="")
	.	else  if (c=3) do
	.	.	use FILE:(ikey=KEY1_" "_IV1)
	.	.	read line
	.	.	use FILE:(ikey="")
	.	else  do
	.	.	use FILE:(okey=KEY1_" "_IV1)
	.	.	write "hello world",!
	.	.	use FILE:(okey="")
	.	close FILE
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(13,"CRYPTNOOVERRIDE",error_" (case "_c_")")
	quit

; Writing at the end of a non-empty file reached by the means of reads should be disallowed.
scenario14
	new error
	open FILE:newversion
	use FILE
	write "hello world",!
	close FILE
	open FILE:(okey=KEY1_" "_IV1)
	use FILE
	for  read line quit:$zeof
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	write "zallo world",!
	close FILE
	do:(error="")!(error'="CRYPTBADWRTPOS") error(14,"CRYPTBADWRTPOS",error)
	quit

; Ensure that encryption state is reset on TRUNCATE at the beginning and is not at the end of a file.
scenario15
	new c,line
	do:($random(2))
	.	open FILE:newversion
	.	use FILE
	.	write "hello world",!
	.	close FILE
	open FILE:(key=KEY1_" "_IV1)
	use FILE:truncate
	read line:0
	use FILE:(key="")
	write "zallo world",!
	close FILE
	do:(line'="") error(15,"nothing",line_" (case 1)")
	open FILE
	use FILE
	read line:0
	close FILE
	do:(line'="zallo world") error(15,"zallo world",line_" (case 2)")
	set c=$random(2)+1
	if (c=1) do
	.	open FILE:(okey=KEY1_" "_IV1:ichset="M")
	else  do
	.	open FILE:(okey=KEY1_" "_IV1:ikey=KEY2_" "_IV2:ichset="M")
	use FILE
	for  read line quit:$zeof
	use FILE:truncate
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	write "yallo world",!
	do:(error="")!(error'="CRYPTBADWRTPOS") error(15,"CRYPTBADWRTPOS",error_" (case 3."_c_")")
	use FILE:(rewind:truncate)
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	write "xallo world",!
	do:(error'="") error(15,,error_" (case 4)")
	set c=$random(3)+1
	if (c=1) do
	.	use FILE:rewind
	.	use FILE:truncate
	.	use FILE:(key="")
	else  if (c=2) do
	.	use FILE:(rewind:truncate)
	.	use FILE:(key="")
	else  do
	.	use FILE:(rewind:truncate:key="")
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	write "wallo world",!
	do:(error'="") error(15,,error_" (case 5."_c_")")
	use FILE:rewind
	read line:0
	do:(line'="wallo world") error(15,"wallo world",line_" (case 6)")
	close FILE
	open FILE
	use FILE
	read line:0
	close FILE
	do:(line'="wallo world") error(15,"wallo world",line_" (case 7)")
	quit

; Writing at the end or middle of a file not reached by prior writes should be disallowed.
scenario16
	new error,c
	open FILE:newversion
        use FILE:(key=KEY1_" "_IV1)
        write "hello world",!
        close FILE
        open FILE:seek=5
	set c=$random(2)
	if (c=1) do
        .	use FILE:(key=KEY1_" "_IV1)
	else  do
        .	use FILE:(key=KEY1_" "_IV1:truncate)
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	write "zallo world",!
        close FILE
	if (c=1) do:(error="")!(error'="NOTTOEOFONPUT") error(16,"NOTTOEOFONPUT",error_" (case "_c_")")
	if (c=2) do:(error="")!(error'="CRYPTBADWRTPOS") error(16,"CRYPTBADWRTPOS",error_" (case "_c_")")
	quit

; Disabling encryption upon a REWIND followed by TRUNCATE should work.
scenario17
	new error
	open FILE:newversion
        use FILE:(key=KEY1_" "_IV1)
        write "hello world",!
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	use FILE:(rewind:truncate:key="")
        close FILE
	do:(error'="") error(17,,error)
	quit

; Disabling both encryption and decryption upon a REWIND should cause an error.
scenario18
	new error
	open FILE:newversion
        use FILE:(key=KEY1_" "_IV1)
        write "hello world",!
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	use FILE:(rewind:key="")
        close FILE
	do:(error="")!(error'="CRYPTNOOVERRIDE") error(18,"CRYPTNOOVERRIDE",error)
	quit

; Disabling only decryption upon a REWIND should work.
scenario19
	new error,line1,line2
	set line2=""
	open FILE:newversion
        use FILE:(key=KEY1_" "_IV1)
        write "hello world",!
	close FILE
	open FILE:(ikey=KEY1_" "_IV1)
	use FILE
	read line1#5:30
	use FILE:(rewind:key="")
	set error=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	read line2:30
        close FILE
	do:(line1'="hello") error(19,"hello",line1)
	do:(line2="hello world") error(19,"not hello world","hello world")
	if ($zchset'="M") do:(error'="")&(error'="BADCHAR") error(19,"BADCHAR",error)
	quit

error(scenario,expected,error)
	set expected=$get(expected)
	set:(expected="") expected="no error"
	set error=$get(error)
	set:(error="") error="no error"
	use $principal
	write "TEST-E-FAIL, Scenario "_scenario_" failed: "
	write "expected "_expected_"; got "_error,!
	zgoto -2
