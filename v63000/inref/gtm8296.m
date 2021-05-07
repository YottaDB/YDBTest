;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8296
	; Setting $ztrap so that it doesn't rethrow the error (therefore terminate gtm8296) and proceeds to the next command
	set $ztrap="set $ecode="""" write $zstatus,!"
	; Verify that PEEKBYNAME accesses gd_segment fields without opening the database.
	; There is a later check of gd_region.jnl_state that will work correctly only if the db was not open.
	; So doing the gd_segment field accesses BEFORE the gd_region.jnl_state access will not only ensure the
	; output is correct but also that it happens without opening the db.
	write "# Pass gd_segment.fname : BEFORE DB open",!
	write:"mumps.dat"=$ZPIECE($$^%PEEKBYNAME("gd_segment.fname","DEFAULT"),$ZCHAR(0),1) "PASS",!
	write "# Pass gd_segment.blk_size : BEFORE DB open",!
	write:4096=$$^%PEEKBYNAME("gd_segment.blk_size","DEFAULT") "PASS",!
	; Note gd_segment.global_buffers is not applicable for MM access method which the test framework can randomly choose
	; so we do not check that here to keep the check simple.
	write "# Pass gd_segment.mutex_slots : BEFORE DB open",!
	write:1024=$$^%PEEKBYNAME("gd_segment.mutex_slots","DEFAULT") "PASS",!
	write "# Pass gd_segment.lock_space : BEFORE DB open",!
	write:220=$$^%PEEKBYNAME("gd_segment.lock_space","DEFAULT") "PASS",!
	;
	; Since V63001A, $zpeek does not open the database region to access "gd_region.*" fields.
	; But we want gd_region.jnl_state to be reported correctly and that is filled in only after db open time.
	; So check that before db open, the field is 0 and after the db open, it is 2.
	write "# Pass gd_region.jnl_state : BEFORE DB open",!
	write:0=$$^%PEEKBYNAME("gd_region.jnl_state","DEFAULT") "PASS",!
	if $view("GVFILE","DEFAULT")	; to open DEFAULT region
	write "# Pass gd_region.jnl_state : AFTER  DB open",!
	write:2=$$^%PEEKBYNAME("gd_region.jnl_state","DEFAULT") "PASS",!
	write "# Pass gd_region.jnl_file_name",!
	write:$find($$^%PEEKBYNAME("gd_region.jnl_file_name","DEFAULT"),"mumps.mjl")'=0 "PASS",!
	write "# Pass gd_region.max_key_size",!
	write:$$^%PEEKBYNAME("gd_region.max_key_size","AREG")=125 "PASS",!
	write "# Pass repl_inst_hdr.inst_info.this_instname",!
	write:$$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname","","s")="INSTANCE1" "PASS",!
	write "# Pass gtmsrc_lcl.secondary_instname",!
	write:$$^%PEEKBYNAME("gtmsrc_lcl.secondary_instname",0,"s")="INSTANCE2" "PASS",!
	write "# Pass sgmnt_data.label with a base address",!
	set base=$$^%PEEKBYNAME("sgmnt_addrs.hdr","DEFAULT")
	write:$$^%PEEKBYNAME("sgmnt_data.label",base)["GDSDYNUNX" "PASS",!
	; ERROR CASES BELOW
	write "# Pass gd_region.max_key_size without region. Expect error.",!
	write $$^%PEEKBYNAME("gd_region.max_key_size"),!
	write:$zgbldir["gtmhelp.gld" "TEST-E-FAIL $zgbldir is not restored correctly: "_$zgbldir
	write "# Pass repl_inst_hdr.inst_info.this_instname with region. Expect error.",!
	write $$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname","AREG"),!
	write "# Pass foo.foo. Expect error.",!
	write $$^%PEEKBYNAME("foo.foo"),!
	write "# Pass repl_inst_hdr.inst_info.foo. Expect error.",!
	write $$^%PEEKBYNAME("repl_inst_hdr.inst_info.foo"),!
	write "# Pass gtmsrc_lcl.secondary_instname with a region name. Expect error.",!
	write $$^%PEEKBYNAME("gtmsrc_lcl.secondary_instname","DEFAULT"),!
	write "# Pass gtmsrc_lcl.secondary_instname without an index. Expect error.",!
	write $$^%PEEKBYNAME("gtmsrc_lcl.secondary_instname"),!
	write "# Pass repl_inst_hdr.inst_info.this_instname with an index. Expect error.",!
	write $$^%PEEKBYNAME("repl_inst_hdr.inst_info.this_instname",0),!
	write "# Pass gd_region.jnl_state with an index. Expect error.",!
	write $$^%PEEKBYNAME("gd_region.jnl_state",0),!
	if $zver'["HP-UX" do
	.	write "# Pass gtmsrc_lcl.secondary_instname with a base address. Expect error.",!
	.	write $$^%PEEKBYNAME("gtmsrc_lcl.secondary_instname",$select($zver["AIX":"0x10000000",1:"0x1")),!
	write "# Pass without a first argument",!
	write $$^%PEEKBYNAME("","DEFAULT"),!
	write "# Verify LISTALL^%PEEKBYNAME and LIST^%PEEKBYNAME",!
	do LIST^%PEEKBYNAME(.out)
	set file="peeklistall.txt"
	open file
	use file
	do LISTALL^%PEEKBYNAME
	use file:rewind
	do Init^GTMDefinedTypesInit
	; Gather structs used in %PEEKBYNAME
	for i=1:1  set line=$text(struct+i^%PEEKBYNAME) quit:""=line  set structname($piece(line,";",2))=""
	set struct=""
	for  set struct=$order(structname($get(struct))) quit:""=struct  do
	.   for i=1:1  set fieldname=$get(gtmtypes(structname(struct),i,"name")) quit:""=fieldname  read line do
	.   .	if line'=fieldname use $p write "TEST-E-FAIL LISTALL^%PEEKBYNAME output is incorrect check "_file,! zwrite line,fieldname,structname halt
	.   .	if $data(out(line))=0 use $p write "TEST-E-FAIL LIST^%PEEKBYNAME output is incorrect check the out value dumped below and "_file,! zwrite out halt
	close file
	quit
