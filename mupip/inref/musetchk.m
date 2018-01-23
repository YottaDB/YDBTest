;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; capture select DSE DUMP -FILEHEADER output and compare with expected results
	;
musetchk(file)
	new etrap
	set $ecode="",$etrap="zgoto "_$zlevel_":error^"_$text(+0)
	open file:(newversion:exception="goto badfile")
	use file:rewind
	new d,label,reg
	do dump^%DSEWRAP("*",.d,"fileheader","all")
	set keep=$piece($text(keep),";",2,99)_$piece($text(keep+1),";",2,99),(label,reg)=""
	for  set reg=$order(d(reg)) quit:""=reg  do
	. for  set label=$order(d(reg,label)) quit:""=label  zwrite:keep[label d(reg,label)
	close file
	quit
keep	;Access method;Defer allocation;Extension Count;Global Buffers;Lock space;Maximum key size;Maximum record size;
	;Mutex Queue Slots;Mutex Sleep Spin Count;Quick database rundown is active;Reserved Bytes;Spin sleep time mask
badfile	close file
	write !,"Error with ",file,!,$zstatus
	quit
error	set fname=$io
	close fname
	use $principal
	write !,$zstatus,!
	new zl,info
	for zl=$stack(-1):1:0 for info="PLACE","MCODE","ECODE" write !,$stack(zl,info)
	set $ecode=""
	quit
dochk(before,after)
	new goodcnt,badcnt,file,i,j,label,reg,x
	new etrap
	set $ecode="",$etrap="zgoto "_$zlevel_":error"
	set (label,reg)=""
	; The # of file header fields we expect to see is 72 in total.
	; 6 lines (3 lines for "before" label and 3 lines for "after" label)
	; And in each line we expect to see 12 fields.
	set expectgoodcnt=72
	for file=before,after do
	. new d
	. open file:(readonly:exception="zgoto -1:badfile")
	. use file:(rewind:exception="goto eof")
	. for  read x set @x
eof	. close file
	. if $zstatus'["EOF" zgoto -1:error
	. for i=0:1 set reg=$order(d(reg)) quit:""=reg  do
	. . set expect=$select(file["after":$text(after+i),1:$text(before+i))
	. . for j=2:1 set label=$order(d(reg,label)) quit:""=label  do
	. . . set e=$piece(expect,";",j)
	. . . if $incr(goodcnt)
	. . . quit:"XX"=e!(e=d(reg,label))
	. . . if $increment(badcnt) write !,"For region: ",reg," and label: ",label," expected: ",e," but got: ",d(reg,label)
	set fail=0
	if (+$get(goodcnt)'=expectgoodcnt) write !,"FAIL from goodcnt : Expected ",expectgoodcnt," : Actual "_+$get(goodcnt) set fail=1
	if +$get(badcnt) write !,"FAIL from badcnt : Expected 0 : Actual "_+$get(badcnt) set fail=1
	if fail=0 write !,"PASS from ",$text(+0)
	quit
before	;XX;XX;100;1024;0x00000028;64;256;1024;128;XX;0;0x00000000
	;XX;XX;100;1024;0x00000028;64;256;1024;128;XX;0;0x00000000
	;XX;XX;100;1024;0x00000028;64;256;1024;128;XX;0;0x00000000
after	;BG;FALSE;2000;2048;0x00000FA0;255;2048;1500;4;TRUE;7;0x00003000
	;BG;FALSE;100;3096;0x00000FA0;255;256;1500;128;TRUE;7;0x00000000
	;BG;FALSE;100;3096;0x00000FA0;255;256;1500;128;TRUE;7;0x00000000
