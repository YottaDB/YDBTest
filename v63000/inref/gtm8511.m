;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This test simulates a failure case where DSE is incorrectly used to modify the fileheader. Without
; the current code changes, after corrupting the fileheader, DSE was unable to return and restore
; the correct settings.
;
gtm8511
	set orig="original",name="name",override="override",resp="response"
	set type="sgmnt_data"
	; Do an update to initialize the DB
	set x=$increment(^a)
	; Setup DSE pipe and strip off headers
	set dsepipe="dsepipe"
	open dsepipe:(command="$gtm_dist/dse")::"PIPE"
	use dsepipe
	for i=1:1 read line(i):1 quit:line(i)["DSE>"
	use $principal
	; Get offsets and current values
	do Init^GTMDefinedTypesInit
	if (0=$data(gtmtypes(type))) write "setup broken",! zwrite  halt
	for i=1:1:gtmtypes(type,0) do:gtmtypes(type,i,"name")?1"sgmnt_data."1(1"blk",1"lock_space",1"jnl_buffer")1"_size"
	.	new response,prompt
	.	set target=$piece(gtmtypes(type,i,name),".",2)
	.	set corrupt(target,"offset")=gtmtypes(type,i,"off")
	.	use dsepipe
	.	write @$piece($text(dsecheck^gtm8511),";",2,99),!
	.	read response:1
	.	read prompt:1
	.	use $principal
	.	set corrupt(target,resp)=response
	.	set corrupt(target,orig)=+$extract($tr($piece(response," ",9),"[]",""),3,99)
	.	; Drop block size to the minimum 512 bytes
	.	do:target="blk_size"
	.	.	set corrupt(target,override)=200
	.	; Drop lock space to the minimum 10 pages
	.	do:target="lock_space_size"
	.	.	set corrupt(target,override)=1400
	.	; Increase the journal buffer count by two
	.	do:target="jnl_buffer_size"
	.	.	set corrupt(target,override)=1000
	; Execute DSE via a shell session and grab DSE's output
	set target="",shellpipe="shellpipe"
	open shellpipe:(command="/bin/sh")::"PIPE"
	use shellpipe
	for  set target=$order(corrupt(target)) quit:""=target  do
	.	set value=corrupt(target,override)
	.	write @$piece($text(dsechange^gtm8511),";",2,99),!
	.	write @$piece($text(dsebuff^gtm8511),";",2,99),!
	.	set value=corrupt(target,orig)
	.	write "echo RESTORE ",target,!
	.	write @$piece($text(dsechange^gtm8511),";",2,99),!
	.	write @$piece($text(dsebuff^gtm8511),";",2,99),!
	write "echo ALLDONE",!
	; Now read all the pipe's output and validate it
	for i=1:1  read line(i) quit:line(i)["ALLDONE"
	close shellpipe
	for line=1:1:i  do:$length(line(line))
	.	quit:(line(line)["File")!(line(line)["Region")
	.	set:"RESTORE"=$piece(line(line)," ",1) field=$piece(line(line)," ",2)
	.	set:(line(line)["NLRESTORE")&($data(field))&(line(line)[field) result(field)=1
	for field="blk_size","lock_space_size","jnl_buffer_size" do
	.	write:$get(result(field),0) "PASS ",field,!
	; Verify that the values have been restore correctly
	for i=1:1:gtmtypes(type,0) do:gtmtypes(type,i,"name")?1"sgmnt_data."1(1"blk",1"lock_space",1"jnl_buffer")1"_size"
	.	new response,prompt
	.	set target=$piece(gtmtypes(type,i,name),".",2)
	.	set corrupt(target,"offset")=gtmtypes(type,i,"off")
	.	use dsepipe
	.	write @$piece($text(dsecheck^gtm8511),";",2,99),!
	.	read response:1
	.	read prompt:1
	.	use $principal
	.	if corrupt(target,resp)'=response write response,!
	close dsepipe
	set dbg="debug.txt"
	open dbg:newversion
	use dbg
	zshow "*"
	close dbg
	quit

dsecheck;"change -fileheader -declo="_corrupt(target,"offset")
dsechange;"$gtm_dist/dse change -fileheader -declo="_corrupt(target,"offset")_" -value="_value
dsebuff;"$gtm_dist/dse buff"
