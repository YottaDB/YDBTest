;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/device_encryption
; test. It deals with some basic attempts to use encryption in
; conjunction with legitimate and illegitimate deviceparameters
; and various devices.
;
; Note that most encryption attributes are specified on OPEN. The
; USE functionality is exercised in the encryptionstate and
; iormuse subtests.
;
; Most of the labels in this routine perform (or attempt to)
; encryption of one of two string (or both) set in environment of
; the test. Decryption is always done using simpleDecrypt or, in
; one case, incrementalDecrypt.
;
; When we encrypt data, depending on the selected device (passed
; in from the test script), we either write encrypted content
; directly to a file (case of "SD") or get it redirected to a
; file from the process's stdout (case of "PRINCIPAL", "PIPE",
; and "FIFO").
;
; For $principal we simply print the encrypted data. For pipes,
; we encrypt data when sending it to a cat command, read it back
; without decrypting, and print that to $principal. Finally, for
; FIFOs we encrypt data before feeding it to a child process who
; then reads it without decrypting and prints it to $principal.
;
; Decryption works similarly, only we obtain the encrypted data
; either via a file ("SD"), $principal ("PRINCIPAL" and "FIFO"),
; or a pipe ("PIPE"); and the final (decrypted) result is always
; printed to $principal, even for the "SD" case.
;
; Towards the end there are few labels that deal with READs in
; FOLLOW mode, for both the reader and the writer; encryption and
; decryption to, and from, $principal when feeding data through
; input redirection and heredocs; and testing of encryption and
; decryption on stdin, stdout, and stderr channels of a pipe.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test simple encryption and decryption.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simpleEncrypt
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string
	write:(device'="FIFO") !
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

simpleDecrypt
	do setup
	if (device="SD") do
	.	open infile:(ikey=key_" "_iv)
	.	quit:$$timedReadDeviceToDevice(infile,$principal)
	else  if (device="PRINCIPAL") do
	.	use $principal:(ikey=key_" "_iv)
	.	quit:$$timedReadDeviceToDevice($principal,$principal)
	else  if (device="PIPE") do
	.	open infile:(comm=command:ikey=key_" "_iv)::"PIPE"
	.	quit:$$timedReadDeviceToDevice(infile,$principal,0)
	else  if (device="FIFO") do
	.	open infile:fifo
	.	quit:$$timedReadDeviceToDevice($principal,infile,0)
	.	do startChildFifo(infile,key,iv,"decrypt")
	close:(device'="FIFO")&($random(2)) infile
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test simple encryption with NoDestroy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
encryptNoDestroy
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	set:(device="SD") $x=0
	close outfile:nodestroy
	open:((device="SD")!(device="PRINCIPAL")) outfile
	open:((device="FIFO")!(device="PIPE")) @openCmd
	use outfile
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test SEEK, APPEND, and TRUNCATE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simpleSeek
	do setup("seek=$random(40)")
	use $principal:(okey=key_" "_iv)
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

seekNoDestroy
	do setup
	use $principal:(okey=key_" "_iv)
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	write:(device'="PRINCIPAL") !
	close outfile:nodestroy
	do setup("seek=$random(40)","newversion")
	open @openCmd
	use outfile
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

simpleAppend
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	write:(device'="PRINCIPAL") !
	close outfile
	do setup("append","newversion")
	open @openCmd
	use outfile
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

appendNewversion
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	write:(device'="PRINCIPAL") !
	close outfile
	do setup("append:newversion")
	open @openCmd
	use outfile
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

appendEmptyDevice
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	close outfile
	do setup("append","newversion")
	open @openCmd
	use outfile
	write string,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

appendNoDestroy
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	set $x=0
	close outfile:nodestroy
	do setup("append","newversion")
	open @openCmd
	use outfile
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

rewindTruncate
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	use outfile:(outrewind:truncate)
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

truncateRewind
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	write string1
	use outfile:(truncate:outrewind)
	if ("PRINCIPAL"=device) new $etrap set $etrap="goto truncerr"
        if (device="SD") do
	.	for i=1:1 read z(i) quit:$zeof
	.	write string2,!
	.	use outfile:(truncate:rewind)
	.	read z#5
	write string2,!
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test incremental encryption and decryption.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
incrementalEncrypt
	do setup
	open @openCmd
	use outfile:(okey=key_" "_iv)
	do incrementalWriteHelper
	write !
	do pipeOrFifo
	close:(device'="FIFO")&($random(2)) outfile
	quit

incrementalDecrypt
	do setup
	if (device="SD") do
	.	open infile:(key=key_" "_iv)
	.	use infile
	.	quit:$$timedReadDeviceToDevice(infile,$principal,0,1)
	else  if (device="PRINCIPAL") do
	.	use $principal:(ikey=key_" "_iv)
	.	quit:$$timedReadDeviceToDevice(infile,$principal,0,1)
	else  if (device="PIPE") do
	.	open infile:(comm=command:ikey=key_" "_iv)::"PIPE"
	.	quit:$$timedReadDeviceToDevice(infile,$principal,0,1)
	else  if (device="FIFO") do
	.	open infile:fifo
	.	quit:$$timedReadDeviceToDevice($principal,infile,0,1)
	.	do startChildFifo(infile,key,iv,"decrypt",1)
	close:(device'="FIFO")&($random(2)) infile
	quit

; Open a FIFO in readonly mode and read encrypted data (optionally decrypting it) to $principal, following a
; specific communication protocol with its parent to avoid deadlocks.
childFifo(file,key,iv,incremental)
	do setTimeout
	open:(""'=key) file:(fifo:readonly:ikey=key_" "_iv)
	open:(""=key) file:(fifo:readonly)
	set ^quitFlag=$job
	for i=1:1 quit:('^quitFlag)  hang 1 if (i>60) use $principal write "TEST-E-FAIL, ^quitFlag was never set to 0.",! halt
	quit:$$timedReadDeviceToDevice(file,$principal,0,1)
	close file
	quit

; Start a child FIFO job, following specific communication protocol to avoid deadlocks.
startChildFifo(hfile,key,iv,name,incremental)
	set name=$get(name,"encrypt")
	set ^quitFlag=0
	set jobCmd="childFifo^deviceopers("""_hfile_""","""_$get(key)_""","""_$get(iv)_""","_$get(incremental,0)_"):(output="""_name_".mjo"":error="""_name_".mje"")"
	job @jobCmd
	for i=1:1 quit:(^quitFlag)  hang 1 if (i>60) use $principal write "TEST-E-FAIL, ^quitFlag was never set to 1.",! halt
	close hfile
	set ^quitFlag=0
	for i=1:1 quit:($zsigproc($zjob,0))  hang 1 if (i>60) use $principal write "TEST-E-FAIL, Process "_$zjob_" never died.",! halt
	quit

; Continuously write a small random number of bytes from a preset string up to a specific length.
incrementalWriteHelper
	set length=$length(string)
	set total=0
	for  do  quit:(total=length)
	.	set num=$random(5)+1
	.	set:(total+num>length) num=length-total
	.	write $extract(string,total+1,total+num)
	.	set total=total+num
	quit

; Continuously read bytes from one specified device to the other, optionally inserting new lines and
; choosing a random number of bytes per read.
timedReadDeviceToDevice(input,output,newline,incremental)
	set newline=$get(newline,1)
	set incremental=$get(incremental,0)
	for  do  quit:$zeof!timeout  use output write line write:newline !
	.	set timeout=0
	.	use input
	.	read:('incremental) line:TIMEOUT
	.	read:(incremental) line#($random(3)+1):TIMEOUT
	.	set timeout='$test
	use output
	set $x=0
	if (timeout) use $principal write "TEST-E-FAIL, Pipe timed out."
	use $principal
	set $x=0
	quit timeout

; Helper label that implements pipe- and FIFO-specific code for most of the other labels.
pipeOrFifo
	if (device="PIPE") do
	.	write /eof
	.	quit:$$timedReadDeviceToDevice(outfile,$principal,0)
	else  if (device="FIFO")  do
	.	do startChildFifo(outfile)
	quit

; Set things up.
setup(extra,sans)
	do setTimeout
	set extra=$get(extra)
	set sans=$get(sans)
	set:(""'=extra) extra=":"_extra
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	set device=$piece($zcmdline," ",4)
	set command=$piece($zcmdline," ",5,999)
	set (string,string1)=$ztrnlnm("string1")
	set string2=$ztrnlnm("string2")
	if (device="FIFO") set (infile,outfile)="fifo"
	else  if (device="PRINCIPAL") set (infile,outfile)=$principal
	else  set (infile,outfile)=$piece($zcmdline," ",1)
	set openCmd=""""_infile_""":("
	set:(device="SD")&(sans'["newversion") openCmd=openCmd_"newversion:"
	set:(device="FIFO") openCmd=openCmd_"fifo:"
	set:(device="PIPE") openCmd=openCmd_"command="""_command_""":"
	set openCmd=openCmd_"okey="""_key_" "_iv_""""_extra_")"
	set:(device="PIPE") openCmd=openCmd_"::""PIPE"""
	quit

setTimeout
	set TIMEOUT=30
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test FOLLOW.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	open file:(append:key=key_" "_iv)
	use file
	; Now, write a lot of lines, but sleep for a while in between so that we give enough time for
	; follow to catch up.
	for i=1:1:400 write "line number "_i,! hang $random(6)/1000
	close file
	quit

follow
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	open file:(follow:key=key_" "_iv)
	use file
	set stop=0
	for i=1:1:400 do  quit:stop
	.	use file
	.	read line:30
	.	if ('$test) set stop=1 use $principal write "Test ended prematurely on line "_i,! quit
	.	if (line'=("line number "_i)) do
	.	.	use $principal
	.	.	write "On line "_i_" expected 'line number "_i_"' but got '"_line_"'",!
	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test FOLLOW with HANG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hangFill
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	open file:(append:key=key_" "_iv)
	use file
	; Now, write a burst of lines, but sleep for a while in between so that we give enough time for
	; follow to catch up.
	for i=1:1:4 do
	.	for j=1:1:100 do
	.	.	write "line number "_$increment(count),!
	.	.	hang $random(6)/1000
	.	hang ($random(6)*100)/1000
	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test FOLLOW with random READ and WRITE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomFill
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	set string=$piece($zcmdline," ",4,999)
	set strlen=$length(string)
	open file:(append:key=key_" "_iv)
	set stop=0
	set writtenBytes=0
	for  do  quit:stop
	.	if (strlen<=writtenBytes) set stop=1 quit
	.	set bytes=$random(3)+1
	.	set randStr=$extract(string,writtenBytes+1,writtenBytes+bytes)
	.	use file
	.	write randStr,!
	.	hang $random(6)/1000
	.	set writtenBytes=writtenBytes+bytes
	close file
	quit

randomFollow
	set file=$piece($zcmdline," ",1)
	set key=$piece($zcmdline," ",2)
	set iv=$piece($zcmdline," ",3)
	set string=$piece($zcmdline," ",4,999)
	set strlen=$length(string)
	open file:(follow:key=key_" "_iv)
	set str=""
	set stop=0
	set readBytes=0
	for  do  quit:stop
	.	set bytes=$random(3)+1
	.	if (strlen=readBytes) set stop=1 quit
	.	use file
	.	read z#bytes:30
	.	if ('$test) set stop=1 use $principal write "Test ended prematurely after reading "_readBytes_" bytes",! quit
	.	set bytes=$length(z)
	.	set readBytes=readBytes+bytes
	.	set str=str_z
	use $principal
	write str,!
	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test $principal and split stdout and stderr
; channels on a pipe.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
principalDecryptEncrypt
	do principalPipeSetup
	use @(""""_$principal_""":("_keyOption_"="""_key_" "_iv_""")")
	for  read line:30 quit:$zeof  write line,!
	quit

pipeEncryptDecryptErrTest
	do principalPipeSetup
	set string="The quick brown fox jump over the lazy little dog."
	set pipe="pipe"
	set stderr="pipeError"
	open @(""""_pipe_""":(command="""_comm_""":"_keyOption_"="""_key_" "_iv_""":stderr="""_stderr_""")::""PIPE""")
	use pipe
	write string,!,/eof
	do stdoutStderrRead(stderr,string)
	do stdoutStderrRead(pipe,string)
	quit

principalPipeSetup
	set key=$piece($zcmdline," ",1)
	set iv=$piece($zcmdline," ",2)
	set encrypt=+$piece($zcmdline," ",3)
	set decrypt=+$piece($zcmdline," ",4)
	set comm=$piece($zcmdline," ",5,999)
	set keyOption=$select(encrypt&decrypt:"key",encrypt:"okey",1:"ikey")
	quit

stdoutStderrRead(stream,string)
	set result=""
	for i=1:1  use stream set timeout=0 read line:30 set timeout='$test quit:$zeof!timeout  set result=result_$select(i>1:"|",1:"")_line
	if (timeout) do  quit
	.       use $principal
	.       write "TEST-E-FAIL, Pipe timed out.",!
	if (result'=string) do
	.       use $principal
	.       write "TEST-E-FAIL, Expected '"_string_"' but got '"_result_"'",!
	close stream
	quit
err
	set io=$IO
	close io
	use $principal
	write $zstatus,!
	quit

truncerr
	new saveio set saveio=$io
	new efile
	set efile="Truncerror.outx"
	open efile
	use efile
	write $zstatus,!
	close efile
	use saveio
	zgoto $estack
	quit
