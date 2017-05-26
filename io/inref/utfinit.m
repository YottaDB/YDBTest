;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utfinit
	; Create utf strings to be used by utfdiskfollow.m
	; With conditionals and some modifications, this routine could be combined with
	; utffixinit.m and utftimeoutinit.m
	; The structure of these routines is the same, but there are differences in
	; the files and strings being created.  The "wait" routine is common, but there
	; are differences in routines such as "modfile".
	do utfinitstr(.utfstr,"utf8_bom")
	do utfinitstr2(.utfstr,"utf8_bom_head")
	do utfinitstr(.utfstr,"utf8_bom_tail")
	do utfinitstr(.utfstr,"utf8_nobom")
	do utfinitstr2(.utfstr,"utf8_nobom_head")
	do utfinitstr2(.utfstr,"utf8_nobom_noeol")
	do utfinitstr(.utfstr,"utf8_nobom_tail")
	do utfinitstr(.utfstr,"utf16_bom")
	do utfinitstr2(.utfstr,"utf16_bom_head")
	do utfinitstr(.utfstr,"utf16_nobom")
	do utfinitstr2(.utfstr,"utf16_nobom_noeol")
	do utfinitstr(.utfstr,"utf16_bom_tail")
	do utfinitstr2(.utfstr,"utf16_nobom_head")
	do utfinitstr(.utfstr,"utf16_nobom_tail")
	; init of files and strings done so set ^a to a
	set outfile=$zcmdline
	write "outfile = ",outfile,!
	write "setting ^a to initdone",!
	set ^a="initdone"
	do wait("cp1")
	do modfile(outfile,"utf8_bom_head","copy")
	set ^a="cp1done"
	do wait("td1")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_bom_tail","tail")
	do wait("cp2")
	do modfile(outfile,"utf8_nobom_head","copy")
	set ^a="cp2done"
	do wait("td2")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_nobom_tail","tail")
	do wait("cp3")
	do modfile(outfile,"utf16_bom_head","copy")
	set ^a="cp3done"
	do wait("td3")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_bom_tail","tail")
	do wait("cp4")
	do modfile(outfile,"utf16_nobom_head","copy")
	set ^a="cp4done"
	do wait("td4")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_nobom_tail","tail")
	do wait("cp5")
	do modfile(outfile,"utf8_bom_head","copy")
	set ^a="cp5done"
	do wait("td5")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_bom_tail","tail")
	do wait("cp6")
	do modfile(outfile,"utf8_nobom_head","copy")
	set ^a="cp6done"
	do wait("td6")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_nobom_tail","tail")
	do wait("cp7")
	do modfile(outfile,"utf16_bom_head","copy")
	set ^a="cp7done"
	do wait("td7")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_bom_tail","tail")
	do wait("cp8")
	do modfile(outfile,"utf16_nobom_head","copy")
	set ^a="cp8done"
	do wait("td8")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_nobom_tail","tail")
	do wait("cp9")
	do modfile(outfile,"utf8_bom","copy")
	set ^a="cp9done"
	do wait("cp10")
	do modfile(outfile,"utf8_nobom","copy")
	set ^a="cp10done"
	do wait("cp11")
	do modfile(outfile,"utf16_bom","copy")
	set ^a="cp11done"
	do wait("cp12")
	do modfile(outfile,"utf16_nobom","copy")
	set ^a="cp12done"
	do wait("cp13")
	do modfile(outfile,"utf8_nobom_noeol","copy")
	set ^a="cp13done"
	do wait("td9")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_nobom_noeol","tail")
	do wait("cp14")
	do modfile(outfile,"utf16_nobom_noeol","copy")
	set ^a="cp14done"
	do wait("td10")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_nobom_noeol","tail")
	quit

utfinitstr(str,p)
	write "initialize ",p,!
	open p:(newversion:ochset="M")
	use p
	if "utf8_bom"=p do
	. set str(p,1)=$char(239),str(p,2)=$char(187),str(p,3)=$char(191),str(p,4)=$char(213),str(p,5)=$char(135)
	. set str(p,6)=$char(213),str(p,7)=$char(136),str(p,8)=$char(213),str(p,9)=$char(137),str(p,10)=$char(65)
	. set str(p,11)=$char(66),str(p,12)=$char(67),str(p,13)=$char(213),str(p,14)=$char(143)
	. set str(p,15)=$char(213),str(p,16)=$char(144),str(p,17)=$char(10)
	. set str(p,"size")=17
	if "utf8_bom_tail"=p do
	. for i=1:1:12 set str(p,i)=str("utf8_bom",i+5)
	. set str(p,"size")=12
	if "utf8_nobom"=p do
	. for i=1:1:14 set str(p,i)=str("utf8_bom",i+3)
	. set str(p,"size")=14
	if "utf8_nobom_tail"=p do
	. for i=1:1:11 set str(p,i)=str("utf8_nobom",i+3)
	. set str(p,"size")=11
	if "utf16_bom"=p do
	. set str(p,1)=$char(254),str(p,2)=$char(255),str(p,3)=$char(5),str(p,4)=$char(71),str(p,5)=$char(5)
	. set str(p,6)=$char(72),str(p,7)=$char(5),str(p,8)=$char(73),str(p,9)=$char(5),str(p,10)=$char(74)
	. set str(p,11)=$char(0),str(p,12)=$char(10)
	. set str(p,"size")=12
	if "utf16_bom_tail"=p do
	. for i=1:1:7 set str(p,i)=str("utf16_bom",i+5)
	. set str(p,"size")=7
	if "utf16_nobom"=p do
	. for i=1:1:10 set str(p,i)=str("utf16_bom",i+2)
	. set str(p,"size")=10
	if "utf16_nobom_tail"=p do
	. for i=1:1:7 set str(p,i)=str("utf16_nobom",i+3)
	. set str(p,"size")=7
	for i=1:1:str(p,"size") write str(p,i)
	set $x=0
	close p
	quit

utfinitstr2(str,p)
	write "initialize2 ",p,!
	set $x=0
	open p:(newversion:fix:ochset="M")
	if "utf8_bom_head"=p do
	. for i=1:1:5 set str(p,i)=str("utf8_bom",i)
	. set str(p,"size")=5
	if "utf8_nobom_head"=p do
	. for i=1:1:3 set str(p,i)=str("utf8_nobom",i)
	. set str(p,"size")=3
	if "utf8_nobom_noeol"=p do
	. for i=1:1:13 set str(p,i)=str("utf8_nobom",i)
	. set str(p,"size")=13
	if "utf16_bom_head"=p do
	. for i=1:1:5 set str(p,i)=str("utf16_bom",i)
	. set str(p,"size")=5
	if "utf16_nobom_head"=p do
	. for i=1:1:3 set str(p,i)=str("utf16_nobom",i)
	. set str(p,"size")=3
	if "utf16_nobom_noeol"=p do
	. for i=1:1:8 set str(p,i)=str("utf16_nobom",i)
	. set str(p,"size")=8
	use p:width=str(p,"size")
	for i=1:1:str(p,"size") write str(p,i)
	close p
	quit

wait(avalue)
	new cnt
	set cnt=0
	for  quit:avalue=^a  do
	. hang 1
	. set cnt=1+cnt
	. if 1800'>cnt use $p write "no change in 30 min so exiting",! halt
	quit

; modify the file
modfile(outfile,str,operation)
	if "tail"=operation do
	. ; wait 5 sec before adding tail so the reader will have to "follow" the input
	. hang 5
	. open outfile:(append:ochset="M")
	else  do
	. open outfile:(truncate:write:ochset="M")
	use outfile
	; convert to a string
	new outstr
	set outstr=""
	for i=1:1:utfstr(str,"size") set outstr=outstr_utfstr(str,i)
	write outstr
	set $x=0
	close outfile
	quit
