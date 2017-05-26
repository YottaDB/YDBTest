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
; test. It deals with ensuring that encryption-related
; deviceparameters are evaluated left-to-right and are either
; disallowed or applied to corresponding device streams (IKEY
; affects input, OKEY affects output, and KEY affects both).
;
; This routine works by constructing a string of deviceparameter
; assignments on IKEY, OKEY, or KEY, affecting in either case
; only the keyname, only the IV, or both. The number of
; deviceparameters and values specified are chosen randomly.
; With a small probability, some of the deviceparameters may also
; repeat.
;
; When specifying the IV, we sometimes set it to a value that
; exceeds 16 characters, so we note that fact and expect an
; error from the plug-in about that. In cases when we end up
; specifying an IV without a keyname, we expect a respective
; error. In all other cases we expect the OPEN command with the
; cumulative string of chosen deviceparameters to succeed.
;
; Finally, we validate that the correct key and IV were chosen
; for both encryption and decryption by writing and reading back
; a file with corresponding encryption attributes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

devparameval
	new i,j,encryption,used,inputIV,outputIV,iv,inputKey,outputKey,key,params,ikey,okey,iiv,oiv,settings,same
	new numOfParams,canRepeat,index,param,value,name,error,fullError,operation,phrase,line,choice,iv2big
	set name="devparameval.txt"
	set phrase="Hello, world,!"
	set encryption(1)="KEY and IV"
	set encryption(2)="KEY"
	set encryption(3)="IV"
	set encryption(4)="input KEY and IV"
	set encryption(5)="input KEY"
	set encryption(6)="input IV"
	set encryption(7)="output KEY and IV"
	set encryption(8)="output KEY"
	set encryption(9)="output IV"
	; Do a hundred iterations of random choices of keys and IVs.
	for i=1:1:100 do
	.	set choice=$random(4)
	.	set inputIV=$select(choice=0:"0123456789ABCDEF",choice=1:"0123456789ABCDEFGHIJ",choice=2:"0123",1:"012"_$char(3)_"456"_$char(7))
	.	set choice=$random(4)
	.	set outputIV=$select(choice=0:"FEDCBA9876543210",choice=1:"FEDCBA9876543210-1-2",choice=2:"FEDC",1:"FED"_$char(12)_"BA9"_$char(8))
	.	set choice=$random(4)
	.	set iv=$select(choice=0:"7654321089ABCDEF",choice=1:"76543210-189ABCDEFG",choice=2:"7689",1:"765"_$char(4)_"89A"_$char(11))
	.	set inputKey="input"
	.	set outputKey="output"
	.	set key="both"
	.	; Prepare things for a new round.
	.	kill params,used
	.	set (ikey,okey,iiv,oiv,params)=""
	.	set numOfParams=$random(9)+1
	.	for j=1:1:numOfParams do
	.	.	set canRepeat='$random(10)
	.	.	for  set index=$random(9)+1 quit:('$data(used(index)))!(canRepeat)
	.	.	set param=encryption(index)
	.	.	set encryption(index,"used")=1
	.	.	if (param["input") do
	.	.	.	set ikey=$select(param["KEY":inputKey,1:"")
	.	.	.	set iiv=$select(param["IV":inputIV,1:"")
	.	.	.	set params(j)="IKEY="""_ikey_" "_iiv_""""
	.	.	else  if (param["output") do
	.	.	.	set okey=$select(param["KEY":outputKey,1:"")
	.	.	.	set oiv=$select(param["IV":outputIV,1:"")
	.	.	.	set params(j)="OKEY="""_okey_" "_oiv_""""
	.	.	else  do
	.	.	.	set (ikey,okey)=$select(param["KEY":key,1:"")
	.	.	.	set (iiv,oiv)=$select(param["IV":iv,1:"")
	.	.	.	set params(j)="KEY="""_okey_" "_oiv_""""
	.	set iv2big=(($length(iiv)>16)!($length(oiv)>16))
	.	; Aggregate the chosen deviceparameters into one string.
	.	for j=1:1:numOfParams do
	.	.	set params=$select(""'=params:params_":",1:"")_params(j)
	.	; If input key is tested, have something to read.
	.	if (ikey'="")&('iv2big) do
	.	.	open name:(newversion:okey=ikey_" "_$$padIV(iiv))
	.	.	use name
	.	.	write phrase,!
	.	.	close name
	.	else  do
	.	.	open name
	.	.	close name:delete
	.	; Try the command with the aggregated deviceparameter string.
	.	set (error,fullError)=""
	.	do
	.	.	new $etrap
	.	.	set $etrap="set fullError=$zstatus,error=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	.	.	set operation="open """_name_""":("_params_")"
	.	.	xecute "open """_name_""":("_params_")"
	.	; Ensure the presence of CRYPTNOKEYSPEC error when one is warranted.
	.	if ((iiv'="")&(ikey=""))!((oiv'="")&(okey="")) do  quit
	.	.	do:(error'="CRYPTNOKEYSPEC") error(operation,"CRYPTNOKEYSPEC",error)
	.	; Check whether overly long IVs are being detected.
	.	if (iv2big) do  quit
	.	.	do:(fullError'["which is greater than the maximum allowed IVEC length")
	.	.	.	do error(operation,"'Specified IVEC has length X, which is greater than the maximum allowed IVEC length Y'",fullError)
	.	; Otherwise, no error is expected.
	.	do:(error'="") error(operation,,error)
	.	; Ensure that the correct encryption parameters are reported.
	.	zshow "D":zshow
	.	do:($get(zshow("D",3),"")'[name) error("zshow ""D""","file containing """_name_""" in zshow(""D"",3)",$get(zshow("D",3),""))
	.	set settings=""
	.	set same=(ikey'="")&(ikey=okey)&(iiv=oiv)
	.	if (ikey'="") do
	.	.	set settings=settings_$select(same:"KEY=",1:"IKEY=")_ikey_" "
	.	.	set settings=settings_$select(same:"IV=",1:"IIV=")_iiv_" "
	.	if ('same)&(okey'="") do
	.	.	set settings=settings_"OKEY="_okey_" "
	.	.	set settings=settings_"OIV="_oiv_" "
	.	set settings=name_" OPEN RMS "_settings
	.	do:(settings'=$get(zshow("D",3),"")) error("zshow ""D""",settings,$get(zshow("D",3),""))
	.	; Test the input key validity.
	.	if (ikey'="") do
	.	.	use name
	.	.	read line:0
	.	.	do:('$test) error("read line (on ikey)","'"_phrase_"'","a timeout")
	.	.	do:(line'=phrase) error("read line (on ikey)","'"_phrase_"'",line)
	.	; Test the output key validity.
	.	if (okey'="") do
	.	.	use name:(rewind:truncate)
	.	.	write phrase,!
	.	.	close name
	.	.	open name:(ikey=okey_" "_$$padIV(oiv))
	.	.	use name
	.	.	read line:0
	.	.	do:('$test) error("read line (on okey)","'"_phrase_"'","a timeout")
	.	.	do:(line'=phrase) error("read line (on okey)","'"_phrase_"'",line)
	.	close name
	quit

padIV(iv)
	new i,length
	set length=$length(iv)
	for i=length+1:1:16 set iv=iv_$char(0)
	quit iv

error(operation,expected,error)
	use $principal
	write "Operation '"_operation_"' failed: "
	write "Expected "_$get(expected,"no error")_"; got "_error,!
	zhalt 1
	quit
