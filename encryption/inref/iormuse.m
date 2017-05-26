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
; test. It covers most error scenarios with encryption detectable
; in iorm_use.c.
;
; The test works by running a loop of scenarios, similar, for
; both input and output directions, in which a randomly selected
; value is specified for IKEY or OKEY, respectively. The value
; is then interpreted for fitness in each particular situation
; (Is the encryption / decryption state already enabled? Is a key
; name specified with an IV? Have any reads / writes occurred
; yet? Is the key and / or IV the same as before? and so on) and
; the expected outcome is determined. Finally, the command is
; tried and the expected output isverified.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iormuse
	new i,CASE,CASENUM,CURIKEY,CURIIV,CUROKEY,CUROIV,READDONE,WRITEDONE,ERROR
	new FILE,FILE1,FILE2,KEY1,IV2,KEY2,IV2
	set FILE1=$piece($zcmdline," ",1)
	set FILE2=$piece($zcmdline," ",2)
	set KEY1=$piece($zcmdline," ",3)
	set IV1=$piece($zcmdline," ",4)
	set KEY2=$piece($zcmdline," ",5)
	set IV2=$piece($zcmdline," ",6)
	set HANDLER="set ERROR=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	for i=1:1:500 do
	.	set FILE=FILE1
	.	open FILE:chset="M"
	.	do doInput
	.	close FILE
	.
	.	set FILE=FILE2
	.	open FILE:(newversion:chset="M")
	.	do doOutput
	.	close FILE
	quit

doInput
	new c,key,iv
	set (CURIKEY,CURIIV)=""
	set READDONE=0
	kill CASE,CASENUM
	if ($random(2)) do
	.	do enableEncryption(1)
	.	do case("Input encryption enabled: key='"_CURIKEY_"'; iv='"_CURIIV_"'")
	else  do
	.	do use
	.	do case("No input encryption")
	do:($random(2)) doRead,case("Read is done")
	if ($random(2)) do
	.	do case("Input key entry present")
	.	if ($random(2)) do
	.	.	do case("Input key not empty")
	.	.	if (CURIKEY'="") do
	.	.	.	if ($random(2)) do
	.	.	.	.	do case("Input key and iv are same: key='"_CURIKEY_"'; iv='"_CURIIV_"'")
	.	.	.	.	do use(CURIKEY_" "_CURIIV)
	.	.	.	.	do:(ERROR'="") error(,ERROR)
	.	.	.	else  do
	.	.	.	.	set c=$random(3)
	.	.	.	.	set key=$select((c'=2):$select(CURIKEY=KEY1:KEY2,1:KEY1),1:CURIKEY)
	.	.	.	.	set iv=$select((c'=1):$select(CURIIV=IV1:IV2,1:IV1),1:CURIIV)
	.	.	.	.	do case("Input key or iv is different: key='"_key_"'; iv='"_iv_"'")
	.	.	.	.	do use(key_" "_iv)
	.	.	.	.	do:(READDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	.	do:('READDONE)&(ERROR'="") error(,ERROR)
	.	.	.	.	do:('READDONE)&('$$isInputEncrypted()) error("input to be encrypted","unencrypted input")
	.	.	else  do
	.	.	.	set key=$select($random(2):KEY1,1:KEY2)
	.	.	.	set c=$random(3)
	.	.	.	set iv=$select((c=1):"",(c=2):IV1,1:IV2)
	.	.	.	do use(key_" "_iv)
	.	.	.	do:(READDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:('READDONE)&(ERROR'="") error(,ERROR)
	.	.	.	do:('READDONE)&('$$isInputEncrypted()) error("input to be encrypted","unencrypted input")
	.	else  do
	.	.	do case("Input key empty")
	.	.	if ($random(2)) do
	.	.	.	set iv=$select($random(2):IV1,1:IV2)
	.	.	.	do case("Input iv present: key=''; iv='"_iv_"'")
	.	.	.	do use(" "_iv)
	.	.	.	do:(CURIKEY'="")&(READDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:((CURIKEY="")!('READDONE))&(ERROR'="CRYPTNOKEYSPEC") error("CRYPTNOKEYSPEC",ERROR)
	.	.	else  do
	.	.	.	do case("Input iv missing: key=''; iv=''")
	.	.	.	do use(" ")
	.	.	.	do:(CURIKEY'="")&(READDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:((CURIKEY="")!('READDONE))&(ERROR'="") error(,ERROR)
	else  do
	.	do case("Input key entry missing")
	.	do use
	.	do:(ERROR'="") error(,ERROR)
	quit

doOutput
	new c,key,iv
	set (CUROKEY,CUROIV)=""
	set WRITEDONE=0
	kill CASE,CASENUM
	if ($random(2)) do
	.	do enableEncryption(0)
	.	do case("Output encryption enabled: key='"_CUROKEY_"'; iv='"_CUROIV_"'")
	else  do
	.	do use
	.	do case("No output encryption")
	do:($random(2)) doWrite,case("Write is done")
	if ($random(2)) do
	.	do case("Output key entry present")
	.	if ($random(2)) do
	.	.	do case("Output key not empty")
	.	.	if (CUROKEY'="") do
	.	.	.	if ($random(2)) do
	.	.	.	.	do case("Output key and iv are same: key='"_CUROKEY_"'; iv='"_CUROIV_"'")
	.	.	.	.	do use(,CUROKEY_" "_CUROIV)
	.	.	.	.	do:(ERROR'="") error(,ERROR)
	.	.	.	else  do
	.	.	.	.	set c=$random(3)
	.	.	.	.	set key=$select((c'=2):$select(CUROKEY=KEY1:KEY2,1:KEY1),1:CUROKEY)
	.	.	.	.	set iv=$select((c'=1):$select(CUROIV=IV1:IV2,1:IV1),1:CUROIV)
	.	.	.	.	do case("Output key or iv is different: key='"_key_"'; iv='"_iv_"'")
	.	.	.	.	do use(,key_" "_iv)
	.	.	.	.	do:(WRITEDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	.	do:('WRITEDONE)&(ERROR'="") error(,ERROR)
	.	.	.	.	do:('WRITEDONE)&('$$isOutputEncrypted()) error("output to be encrypted","unencrypted output")
	.	.	else  do
	.	.	.	set key=$select($random(2):KEY1,1:KEY2)
	.	.	.	set c=$random(3)
	.	.	.	set iv=$select((c=1):"",(c=2):IV1,1:IV2)
	.	.	.	do use(,key_" "_iv)
	.	.	.	do:(WRITEDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:('WRITEDONE)&(ERROR'="") error(,ERROR)
	.	.	.	do:('WRITEDONE)&('$$isOutputEncrypted()) error("output to be encrypted","unencrypted output")
	.	else  do
	.	.	do case("Output key empty")
	.	.	if ($random(2)) do
	.	.	.	set iv=$select($random(2):IV1,1:IV2)
	.	.	.	do case("Output iv present: key=''; iv='"_iv_"'")
	.	.	.	do use(," "_iv)
	.	.	.	do:(CUROKEY'="")&(WRITEDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:((CUROKEY="")!('WRITEDONE))&(ERROR'="CRYPTNOKEYSPEC") error("CRYPTNOKEYSPEC",ERROR)
	.	.	else  do
	.	.	.	do case("Output iv missing: key=''; iv=''")
	.	.	.	do use(," ")
	.	.	.	do:(CUROKEY'="")&(WRITEDONE)&(ERROR'="CRYPTNOOVERRIDE") error("CRYPTNOOVERRIDE",ERROR)
	.	.	.	do:((CUROKEY="")!('WRITEDONE))&(ERROR'="") error(,ERROR)
	else  do
	.	do case("Output key entry missing")
	.	do use
	.	do:(ERROR'="") error(,ERROR)
	quit

enableEncryption(input)
	new key,iv
	set key=$select($random(2):KEY1,1:KEY2)
	set iv=$select($random(2):IV1,1:IV2)
	if (input) do
	.	set CURIKEY=key
	.	set CURIIV=iv
	.	use FILE:(ikey=key_" "_iv)
	else  do
	.	set CUROKEY=key
	.	set CUROIV=iv
	.	use FILE:(okey=key_" "_iv)
	quit

doRead
	new line
	set READDONE=1
	read line
	quit

doWrite
	set WRITEDONE=1
	write "hello, world",!
	quit

case(text)
	set CASE($increment(CASENUM))=text
	quit

use(ikey,okey)
	set ERROR=""
	do
	.	new $etrap
	.	set $etrap=HANDLER
	.	if ($get(ikey)'="") use FILE:ikey=ikey quit
	.	if ($get(okey)'="") use FILE:okey=okey quit
	.	use FILE
	quit

isInputEncrypted()
	new line
	use FILE:rewind
	read line
	quit line'="hello world"

isOutputEncrypted()
	new line
	use FILE:(rewind:truncate)
	write "hello world",!
	close FILE
	open FILE:chset="M"
	use FILE
	read line
	quit line'="hello world"

error(expected,error)
	new i
	set expected=$get(expected,"no error")
	set error=$get(error,"no error")
	use $principal
	; Since something fails, we want to know the sequence of random selections made, which have
	; been recorded in the CASE variable.
	for i=1:1:$get(CASENUM,0) write CASE(i),!
	write "TEST-E-FAIL, Expected "_expected_"; got "_error,!
	write "    $zstatus is "_$zstatus,!
	write "----------------------------------------------------",!
	zgoto -2
