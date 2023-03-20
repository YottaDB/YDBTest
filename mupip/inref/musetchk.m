;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
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
	new fldval,label,reg
	set keep=$zpiece($text(keep),";",2,99)_$zpiece($text(keep+1),";",2,99),(label,reg)=""
	set where=$zpiece($text(where),";",2,99)_$zpiece($text(where+1),";",2,99),(label,reg)=""
	set fldfmt=$zpiece($text(fldfmt),";",2,99)_$zpiece($text(fldfmt+1),";",2,99),(label,reg)=""
	set reg=""
	for  set reg=$view("GVNEXT",reg) quit:""=reg  do
	. for pieceidx=1:1  set label=$zpiece(where,";",pieceidx) quit:label=""  do
	. . set fldval=$$^%PEEKBYNAME("sgmnt_data."_label,reg)
	. . set fldfmter=$zpiece(fldfmt,";",pieceidx)
	. . set:fldfmter'="0" @("fldfmted=$$"_fldfmter_"(fldval)")
	. . set:fldfmter=0 fldfmted=fldval
	. . set flddesc=$zpiece(keep,";",pieceidx)
	. . set d(reg,flddesc)=fldfmted
	. . zwrite d(reg,flddesc)
	close file
	quit

	;
	; Following are the field descriptions. The old $$^%DSEWRAP() script used to use these names as the indexes so in order
	; to not have to redesign the whole test, we still use these names as indexes when we create the array. Note the index
	; is the same amongst the keep/where/fldfmt arrays.
	;
keep	;Access method;Defer allocation;Extension Count;Global Buffers;Lock space;Maximum key size;Maximum record size;
	;Mutex Queue Slots;Mutex Sleep Spin Count;Quick database rundown is active;Reserved Bytes;Spin sleep time mask

	;
	; Following are the field names in sgmnt_data we need to fetch for each region - indexed same as keep().
	;
where	;acc_meth;defer_allocate;extension_size;n_bts;lock_space_size;max_key_size;max_rec_size;
	;mutex_spin_parms.mutex_que_entry_space_size;mutex_spin_parms.mutex_sleep_spin_count;mumps_can_bypass;reserved_bytes;mutex_spin_parms.mutex_spin_sleep_mask

	;
	; Following is a list of routines to call to format the values fetched by PEEKBYNAME or 0 if value is formatted
	; correctly already.
	;
fldfmt	;fmtaccmeth;fmtboolean;0;0;fmtlockspace;0;0;
	;0;0;fmtboolean;0;fmthex

;
; Routine fmtaccmeth to turn raw fetched value into BG or MM
;
fmtaccmeth(fmt)
	quit $select("1"=fmt:"BG","2"=fmt:"MM")		; Anything unexpected causes a select error

;
; Routine fmtboolean to turn raw boolean value into "TRUE" or "FALSE"
;
fmtboolean(bool)
	quit $select("0"=bool:"FALSE",1:"TRUE")

;
; Routine fmtlockspace to turn lock space bytes into 512 blocks but as a hex value
;
fmtlockspace(bytes)
	quit $$fmthex(bytes/512)

;
; Routine fmthex to turn fetched decimal values into hex values
;
fmthex(dec)
	quit "0x"_$$FUNC^%DH(dec,8)

;
; Error routines
;
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

;
; Check values saved before and after test
;
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
before	;XX;XX;100;1024;0x000000DC;64;256;1024;128;XX;0;0x00000000
	;XX;XX;100;1024;0x000000DC;64;256;1024;128;XX;0;0x00000000
	;XX;XX;100;1024;0x000000DC;64;256;1024;128;XX;0;0x00000000
after	;BG;FALSE;2000;2048;0x00000FA0;255;2048;1500;4;TRUE;7;0x00003000
	;BG;FALSE;100;3096;0x00000FA0;255;256;1500;128;TRUE;7;0x00000000
	;BG;FALSE;100;3096;0x00000FA0;255;256;1500;128;TRUE;7;0x00000000
