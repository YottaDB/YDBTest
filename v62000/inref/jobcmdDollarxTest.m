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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A script to ensure that a newline is not inserted when a
; job is started for various devices. Ref:[GTM-8123]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parent
	set outfile=$piece($zcmdline," ",1)
	set deviceName=$piece($zcmdline," ",2)
	set string=$piece($zcmdline," ",3,999)
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	if (deviceName="SD") open outfile:okey=key_" "_iv
	if (deviceName="FIFO") set outfile="myParentFifo" open outfile:(fifo:okey=key_" "_iv)
	if (deviceName="PRINCIPAL") set outfile=$principal
	if (deviceName="PIPE") open outfile:(comm="cat > PIPE.encr":okey=key_" "_iv)::"PIPE"
	use outfile:(okey=key_" "_iv)
	write string
	set ^quitFlag=0
	job child^jobcmdDollarxTest(outfile,deviceName,key,iv)
	for i=1:1 quit:(^quitFlag)  hang 1 if (i=60) use $principal write "TEST-E-FAIL, Parent timed out.",! halt
	set $x=0
	close outfile
	set ^quitFlag=0
	for i=1:1 quit:($zsigproc($zjob,0))  hang 1 if (i=60) use $principal write "TEST-E-FAIL, Parent timed out.",! halt
	quit

child(deviceType,deviceName,key,iv)
	open:("FIFO"=$get(deviceName)) deviceType:(fifo:readonly:ikey=key_" "_iv)
	set ^quitFlag=$job
	if (deviceName'="FIFO") quit
	for i=1:1 quit:('^quitFlag)  hang 1 if (i=60) use $principal write "TEST-E-FAIL, Child timed out.",! halt
	set timeout=0
	for  do  quit:$zeof!timeout  use $principal write line
	.	use deviceType
	.	read line:30
	.	set timeout='$test
	close deviceType
	use $principal
	if (timeout) write "TEST-E-FAIL, Device timed out."
	set $x=0
	quit

decrypt
	set file=$piece($zcmdline," ",1)
	set decrypt=+$piece($zcmdline," ",2)
	set key=$select(decrypt:$ztrnlnm("gtmcrypt_key"),1:"")
	set iv=$select(decrypt:$ztrnlnm("gtmcrypt_iv"),1:"")
	open file:(ikey=key_" "_iv:fixed)
	use file
	set (temp,z)=""
	for  quit:$zeof  set temp=z read z#1:30 if ('$test) use $principal write "TEST-E-FAIL, Device timed out." quit
	if (temp=$char(10)) use $principal write "TEST-E-FAIL, Last char is "_$zwrite(temp),!
	quit
