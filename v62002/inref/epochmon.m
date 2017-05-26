;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inspect
	set reg="DEFAULT"
	for i=1:1:1000 w ! do getinfo(reg) hang 1
	quit

showdbuffs(reg,timeinterval,numtorepeat)
	new i

	; setup for displaying fields
	do displayfieldinit
	for i=1:1:numtorepeat do displaycnlfieldonly("wcs_active_lvl") hang timeinterval
	quit

display(reg,timeinterval,numtorepeat)
	for i=1:1:numtorepeat write ! do getinfo(reg) hang timeinterval
	quit


getinfo(reg)
	; setup for displaying fields
	do displayfieldinit
	;
	do displaycnlfield("ref_cnt","Number of Processes in database")
	;
	set fieldname="wcs_timers",displaytext="Number of Timers"
	set index=gtmtypfldindx("node_local",fieldname),offset=gtmtypes("node_local",index,"off"),length=gtmtypes("node_local",index,"len")
	w displaytext_": "_($zpeek("PEEK:"_nl(reg),offset,length,"U")+1),!
	;
	do displaycsdfield("n_bts","Number of Buffers")
	do displaycnlfield("wcs_active_lvl","Dirty Buffers")
	do displaycsdfield("flush_trigger","Flush Trigger")
	do displaycsdfield("n_wrt_per_flu","Number of Writes Per Flush")


	do displayjpcfield("epoch_interval","Epoch Interval")
	if $&gtmposix.gettimeofday(.secs,.usecs,.errno)
	set secs2epoch=($$getjpcfield("next_epoch_time")-secs)
 	write:(secs2epoch>-1) "Seconds until Epoch:"_secs2epoch,!
 	write:(secs2epoch<0) "Seconds until Epoch: No Epoch Pending",!
	do displaycsdfield("jnl_state","Journaling State")
	do displaycnlfield("jnl_file.u.inode","Journal File's Inode")
	do displaycsdfield("jnl_deq","Journal Extension")
	do displaycsdfield("jnl_alq","Journal Allocation")
	do displayjpcfield("dskaddr","Journal File Size")
	write "Autoswitch Limit (bytes):"_($$getcsdfield("autoswitchlimit")*512),!


	quit

displayfieldinit
	; get in the offsets and lengths for the data items
	do Init^GTMDefinedTypesInit
	; get csd
	set csdidx=gtmtypfldindx("sgmnt_addrs","hdr"),csdoff=gtmtypes("sgmnt_addrs",csdidx,"off"),csdlen=gtmtypes("sgmnt_addrs",csdidx,"len")
	set csd(reg)=$zpeek("CSAREG:"_reg,csdoff,csdlen,"X")
	; get nl
	set nlidx=gtmtypfldindx("sgmnt_addrs","nl"),nloff=gtmtypes("sgmnt_addrs",nlidx,"off"),nllen=gtmtypes("sgmnt_addrs",nlidx,"len")
	set nl(reg)=$zpeek("CSAREG:"_reg,nloff,nllen,"X")
	;
	set jnlidx=gtmtypfldindx("sgmnt_addrs","jnl"),jnloff=gtmtypes("sgmnt_addrs",jnlidx,"off"),jnllen=gtmtypes("sgmnt_addrs",jnlidx,"len")
	set jnl(reg)=$zpeek("CSAREG:"_reg,jnloff,jnllen,"X")

	set jpcidx=gtmtypfldindx("jnl_private_control","jnl_buff"),jpcoff=gtmtypes("jnl_private_control",jpcidx,"off"),jpclen=gtmtypes("jnl_private_control",jpcidx,"len")
	set jpc(reg)=$zpeek("PEEK:"_jnl(reg),jpcoff,jpclen,"X")
	quit

displayjpcfield(fieldname,displaytext)
	new index,offset,length
	set index=gtmtypfldindx("jnl_buffer",fieldname),offset=gtmtypes("jnl_buffer",index,"off"),length=gtmtypes("jnl_buffer",index,"len")
	write displaytext_": "_$zpeek("PEEK:"_jpc(reg),offset,length,"U"),!
	quit

getjpcfield(fieldname)
	new index,offset,length
	set index=gtmtypfldindx("jnl_buffer",fieldname),offset=gtmtypes("jnl_buffer",index,"off"),length=gtmtypes("jnl_buffer",index,"len")
	quit $zpeek("PEEK:"_jpc(reg),offset,length,"U")

displaycnlfield(fieldname,displaytext)
	new index,offset,length
	set index=gtmtypfldindx("node_local",fieldname),offset=gtmtypes("node_local",index,"off"),length=gtmtypes("node_local",index,"len")
	write displaytext_": "_$zpeek("PEEK:"_nl(reg),offset,length,"U"),!
	quit

displaycnlfieldonly(fieldname)
	new index,offset,length
	set index=gtmtypfldindx("node_local",fieldname),offset=gtmtypes("node_local",index,"off"),length=gtmtypes("node_local",index,"len")
	write $zpeek("PEEK:"_nl(reg),offset,length,"U"),!
	quit

displaycsdfield(fieldname,displaytext)
	new index,offset,length
	set index=gtmtypfldindx("sgmnt_data",fieldname),offset=gtmtypes("sgmnt_data",index,"off"),length=gtmtypes("sgmnt_data",index,"len")
	write displaytext_": "_$zpeek("PEEK:"_csd(reg),offset,length,"U"),!
	quit

getcsdfield(fieldname)
	new index,offset,length
	set index=gtmtypfldindx("sgmnt_data",fieldname),offset=gtmtypes("sgmnt_data",index,"off"),length=gtmtypes("sgmnt_data",index,"len")
	quit $zpeek("PEEK:"_csd(reg),offset,length,"U")

hexadd(x,y)
	; addr and off are hexadecimal numbers with upper-case A-F (not a-f)
	; Returns addr+off as a hexadecimal number 0x...
	; Not going with decimal conversion as that might overflow the numeric range of GT.M (if hex address > 2**46)
	; Note: x and y need to start with 0x or else this function will not work correctly
	new xlen,ylen,res,tot,carry,remainder,x1,y1,reslen
	if '$data(hex2dec) do
	.	set hex2dec("")=0
	.	set hex2dec("0")=0,hex2dec("1")=1,hex2dec("2")=2,hex2dec("3")=3
	.	set hex2dec("4")=4,hex2dec("5")=5,hex2dec("6")=6,hex2dec("7")=7
	.	set hex2dec("8")=8,hex2dec("9")=9,hex2dec("A")=10,hex2dec("B")=11
	.	set hex2dec("C")=12,hex2dec("D")=13,hex2dec("E")=14,hex2dec("F")=15
	.	set dec2hex(0)="0",dec2hex(1)="1",dec2hex(2)="2",dec2hex(3)="3"
	.	set dec2hex(4)="4",dec2hex(5)="5",dec2hex(6)="6",dec2hex(7)="7"
	.	set dec2hex(8)="8",dec2hex(9)="9",dec2hex(10)="A",dec2hex(11)="B"
	.	set dec2hex(12)="C",dec2hex(13)="D",dec2hex(14)="E",dec2hex(15)="F"
	set xlen=$zlength(x)-2,ylen=$zlength(y)-2
	set x=$zextract(x,3,xlen+2),y=$zextract(y,3,ylen+2),res="",reslen=0,carry=0,quit=0
	for  do  quit:quit
	. if reslen>15 set quit=1 quit
	. if 'carry&(xlen=0) set res=y_res,quit=1 quit
	. if 'carry&(ylen=0) set res=x_res,quit=1 quit
	. set x1=$zextract(x,xlen,xlen),x1=hex2dec(x1)
	. set y1=$zextract(y,ylen,ylen),y1=hex2dec(y1)
	. set tot=x1+y1+carry,remainder=tot#16,carry=tot\16
	. if $incr(reslen)
	. set res=dec2hex(remainder)_res
	. set x=$zextract(x,1,$increment(xlen,-1)),y=$zextract(y,1,$increment(ylen,-1))
	quit "0x"_res
