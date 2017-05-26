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
utffixinit
	; Create utf strings to be used by utffixfollow.m
	; With conditionals and some modifications, this routine could be combined with
	; utfinit.m and utftimeoutinit.m
	; The structure of these routines is the same, but there are differences in
	; the files and strings being created.  The "wait" routine is common, but there
	; are differences in routines such as "modfile".
	do utfinitstr(.utfstr,"utf8_fix_bom")
	do utfinitstr(.utfstr,"utf8_fix_bom_head")
	do utfinitstr(.utfstr,"utf8_fix_bom_tail")
	do utfinitstr(.utfstr,"utf8_fix_nobom")
	do utfinitstr(.utfstr,"utf8_fix_nobom_head")
	do utfinitstr(.utfstr,"utf8_fix_nobom_tail")
	do utfinitstr(.utfstr,"utf8_fix_nobom_head2")
	do utfinitstr(.utfstr,"utf8_fix_nobom_tail2")
	do utfinitstr(.utfstr,"utf8_fix_nobom_head3")
	do utfinitstr(.utfstr,"utf8_fix_nobom_tail3")
	do utfinitstr(.utfstr,"utf8_fix_nobom_fill1")
	do utfinitstr(.utfstr,"utf8_fix_nobom_fill2")
	do utfinitstr(.utfstr,"utf16_fix_bom")
	do utfinitstr(.utfstr,"utf16_fix_bom_head")
	do utfinitstr(.utfstr,"utf16_fix_bom_tail")
	do utfinitstr(.utfstr,"utf16_fix_bom_head2")
	do utfinitstr(.utfstr,"utf16_fix_bom_tail2")
	do utfinitstr(.utfstr,"utf16_fix_nobom")
	do utfinitstr(.utfstr,"utf16_fix_nobom_head")
	do utfinitstr(.utfstr,"utf16_fix_nobom_tail")
	do utfinitstr(.utfstr,"utf16_fix_nobom_head2")
	do utfinitstr(.utfstr,"utf16_fix_nobom_tail2")
	do utfinitstr(.utfstr,"utf16_fix_nobom_head3")
	do utfinitstr(.utfstr,"utf16_fix_nobom_tail3")
	do utfinitstr(.utfstr,"utf16_fix_nobom_head4")
	do utfinitstr(.utfstr,"utf16_fix_nobom_fill1")
	do utfinitstr(.utfstr,"utf16_fix_nobom_fill2")

	; init of files and strings done so set ^a to a
	set outfile=$zcmdline
	write "outfile = ",outfile,!
	write "setting ^a to initdone",!
	set ^a="initdone"
; uncomment all non-comment lines in this file and utffixfollow.m with the word "skip" in them to do a reduced standalone test
;	goto skip
	do wait("cp1")
	do modfile(outfile,"utf8_fix_bom_head","copy")
	set ^a="cp1done"
	do wait("td1")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_bom_tail","tail")
	do wait("cp2")
	do modfile(outfile,"utf8_fix_nobom_head","copy")
	set ^a="cp2done"
	do wait("td2")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_nobom_tail","tail")
	do wait("cp3")
	do modfile(outfile,"utf16_fix_bom_head","copy")
	set ^a="cp3done"
	do wait("td3")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_fix_bom_tail","tail")
	do wait("cp4")
	do modfile(outfile,"utf16_fix_nobom_head","copy")
	set ^a="cp4done"
	do wait("td4")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_fix_nobom_tail","tail")
	do wait("cp5")
	do modfile(outfile,"utf8_fix_bom_head","copy")
	set ^a="cp5done"
	do wait("td5")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_bom_tail","tail")
	do wait("cp6")
	do modfile(outfile,"utf8_fix_nobom_head","copy")
	set ^a="cp6done"
	do wait("td6")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_nobom_tail","tail")
	do wait("cp7")
	do modfile(outfile,"utf16_fix_bom_head","copy")
	set ^a="cp7done"
	do wait("td7")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_fix_bom_tail","tail")
	do wait("cp8")
	do modfile(outfile,"utf16_fix_nobom_head","copy")
	set ^a="cp8done"
	do wait("td8")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_fix_nobom_tail","tail")

	do wait("cp9")
	do modfile(outfile,"utf8_fix_bom_head","copy")
	set ^a="cp9done"
	do wait("tnd1")
	do modfile(outfile,"utf8_fix_bom_tail","tailnodel")
	set ^a="tnd1done"
	do wait("cp10")
	do modfile(outfile,"utf8_fix_nobom_head2","copy")
	set ^a="cp10done"
	do wait("tnd2")
	do modfile(outfile,"utf8_fix_nobom_tail2","tailnodel")
	set ^a="tnd2done"
	do wait("cp11")
	do modfile(outfile,"utf16_fix_bom_head2","copy")
	set ^a="cp11done"
	do wait("tnd3")
	do modfile(outfile,"utf16_fix_bom_tail2","tailnodel")
	set ^a="tnd3done"
	do wait("cp12")
	do modfile(outfile,"utf16_fix_nobom_head2","copy")
	set ^a="cp12done"
	do wait("tnd4")
	do modfile(outfile,"utf16_fix_nobom_tail2","tailnodel")
	set ^a="tnd4done"
	do wait("cp13")
	do modfile(outfile,"utf8_fix_bom","copy")
	set ^a="cp13done"
	do wait("td9")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_nobom","tail")
	do wait("cp14")
	do modfile(outfile,"utf16_fix_bom","copy")
	set ^a="cp14done"
	do wait("td10")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_fix_nobom","tail")
	do wait("cp15")
	do modfile(outfile,"utf8_fix_nobom_head3","copy")
	set ^a="cp15done"
	do wait("td11")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_fix_nobom_tail3","tail")
	do wait("tnd5")
	do modfile(outfile,"utf8_fix_nobom","tailnodel")
	set ^a="tnd5done"
; uncomment all non-comment lines in this file and utffixfollow.m with the word "skip" in them to do a reduced standalone test
;skip
	do wait("cp16")
	do modfile(outfile,"utf8_fix_nobom","copy")
	set ^a="cp16done"
	do wait("td12")
	; add 16 utf
	do modfile(outfile,"utf8_fix_nobom_tail2","tail")
	do modfile(outfile,"utf8_fix_nobom_tail2","tailnodel")
	do wait("cp17")
	do modfile(outfile,"utf8_fix_nobom_head3","copy")
	set ^a="cp17done"
	do wait("tnd6")
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	set ^a="tnd6done"
	do wait("tnd7")
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	set ^a="tnd7done"
	do wait("tnd8")
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	set ^a="tnd8done"
	do wait("tnd9")
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	set ^a="tnd9done"
	do wait("tnd10")
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	set ^a="tnd10done"

	do wait("cp18")
	do modfile(outfile,"utf8_fix_nobom_head3","copy")
	set ^a="cp18done"
	do wait("td13")
	do modfile(outfile,"utf8_fix_nobom_tail3","tail")
	do wait("tnd11")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_tail3","tailnodel")
	do wait("tnd12")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf8_fix_nobom_tail3","tailnodel")
	do wait("cp19")
	do modfile(outfile,"utf8_fix_nobom_head3","copy")
	set ^a="cp19done"
	do wait("td14")
	do modfile(outfile,"utf8_fix_nobom_fill2","tail")
	do modfile(outfile,"utf8_fix_nobom_fill2","tailnodel")
	do wait("tnd13")
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	set ^a="tnd13done"
	do wait("td15")
	do modfile(outfile,"utf8_fix_nobom_fill2","tail")
	do modfile(outfile,"utf8_fix_nobom_fill2","tailnodel")
	do wait("tnd14")
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	set ^a="tnd14done"
	do wait("tnd15")
	do modfile(outfile,"utf8_fix_nobom_head2","tailnodel")
	do modfile(outfile,"utf8_fix_nobom_fill2","tailnodel")
	set ^a="tnd15done"
	do wait("tnd16")
	do modfile(outfile,"utf8_fix_nobom_head3","tailnodel")
	do modfile(outfile,"utf8_fix_nobom_fill2","tailnodel")
	do modfile(outfile,"utf8_fix_nobom_fill2","tailnodel")
	set ^a="tnd16done"

	do wait("cp20")
	do modfile(outfile,"utf16_fix_nobom_head3","copy")
	set ^a="cp20done"
	do wait("td16")
	do modfile(outfile,"utf16_fix_nobom_fill2","tail")
	do wait("tnd17")
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	set ^a="tnd17done"
	do wait("td17")
	do modfile(outfile,"utf16_fix_nobom_fill2","tail")
	do wait("tnd18")
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	set ^a="tnd18done"
	do wait("tnd19")
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	do modfile(outfile,"utf16_fix_nobom_fill1","tailnodel")
	set ^a="tnd19done"
	do wait("tnd20")
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	do modfile(outfile,"utf16_fix_nobom_fill2","tailnodel")
	set ^a="tnd20done"

	do wait("cp21")
	do modfile(outfile,"utf16_fix_nobom_head3","copy")
	set ^a="cp21done"
	do wait("tnd21")
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	set ^a="tnd21done"
	do wait("tnd22")
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	set ^a="tnd22done"
	do wait("tnd23")
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	set ^a="tnd23done"
	do wait("tnd24")
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	set ^a="tnd24done"
	do wait("tnd25")
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_head4","tailnodel")
	set ^a="tnd25done"

	do wait("cp22")
	do modfile(outfile,"utf16_fix_nobom","copy")
	do modfile(outfile,"utf16_fix_nobom","tailnodel")
	set ^a="cp22done"
	do wait("td18")
	do modfile(outfile,"utf16_fix_nobom","tail")
	do modfile(outfile,"utf16_fix_nobom","tailnodel")

	do wait("cp23")
	do modfile(outfile,"utf16_fix_nobom_head3","copy")
	set ^a="cp23done"
	do wait("td19")
	do modfile(outfile,"utf16_fix_nobom_tail3","tail")
	do wait("tnd26")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_tail3","tailnodel")
	do wait("tnd27")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_head3","tailnodel")
	hang 2
	do modfile(outfile,"utf16_fix_nobom_tail3","tailnodel")
	quit

utfinitstr(str,p)
	write "initialize ",p,!
	open p:(newversion:ochset="M")
	use p
	if "utf8_fix_bom"=p do
	. set str(p,1)=$char(239),str(p,2)=$char(187),str(p,3)=$char(191),str(p,4)=$char(213),str(p,5)=$char(135)
	. set str(p,6)=$char(213),str(p,7)=$char(136),str(p,8)=$char(213),str(p,9)=$char(137),str(p,10)=$char(65)
	. set str(p,11)=$char(66),str(p,12)=$char(67),str(p,13)=$char(68),str(p,14)=$char(69),str(p,15)=$char(213)
	. set str(p,16)=$char(143),str(p,17)=$char(213),str(p,18)=$char(144)
	. set str(p,"size")=18
	if "utf8_fix_bom_head"=p do
	. for i=1:1:5 set str(p,i)=str("utf8_fix_bom",i)
	. set str(p,"size")=5
	if "utf8_fix_bom_tail"=p do
	. for i=1:1:13 set str(p,i)=str("utf8_fix_bom",i+5)
	. set str(p,"size")=13
	if "utf8_fix_nobom"=p do
	. for i=1:1:15 set str(p,i)=str("utf8_fix_bom",i+3)
	. set str(p,"size")=15
	if "utf8_fix_nobom_head"=p do
	. for i=1:1:3 set str(p,i)=str("utf8_fix_nobom",i)
	. set str(p,"size")=3
	if "utf8_fix_nobom_tail"=p do
	. for i=1:1:12 set str(p,i)=str("utf8_fix_nobom",i+3)
	. set str(p,"size")=12
	if "utf8_fix_nobom_head2"=p do
	. for i=1:1:4 set str(p,i)=str("utf8_fix_nobom",i)
	. set str(p,"size")=4
	if "utf8_fix_nobom_tail2"=p do
	. for i=1:1:11 set str(p,i)=str("utf8_fix_nobom",i+4)
	. set str(p,"size")=11
	if "utf8_fix_nobom_head3"=p do
	. for i=1:1:6 set str(p,i)=str("utf8_fix_nobom",i)
	. set str(p,"size")=6
	if "utf8_fix_nobom_tail3"=p do
	. for i=1:1:9 set str(p,i)=str("utf8_fix_nobom",i+6)
	. set str(p,"size")=9
	if "utf8_fix_nobom_fill1"=p do
	. set str(p,1)=$char(32)
	. set str(p,"size")=1
	if "utf8_fix_nobom_fill2"=p do
	. set str(p,1)=$char(32),str(p,2)=$char(32)
	. set str(p,"size")=2
	if "utf16_fix_bom"=p do
	. set str(p,1)=$char(254),str(p,2)=$char(255),str(p,3)=$char(5),str(p,4)=$char(71),str(p,5)=$char(5)
	. set str(p,6)=$char(72),str(p,7)=$char(5),str(p,8)=$char(73),str(p,9)=$char(5),str(p,10)=$char(74)
	. set str(p,11)=$char(5),str(p,12)=$char(75),str(p,13)=$char(5),str(p,14)=$char(76)
	. set str(p,"size")=14
	if "utf16_fix_bom_head"=p do
	. for i=1:1:5 set str(p,i)=str("utf16_fix_bom",i)
	. set str(p,"size")=5
	if "utf16_fix_bom_tail"=p do
	. for i=1:1:9 set str(p,i)=str("utf16_fix_bom",i+5)
	. set str(p,"size")=9
	if "utf16_fix_bom_head2"=p do
	. for i=1:1:4 set str(p,i)=str("utf16_fix_bom",i)
	. set str(p,"size")=4
	if "utf16_fix_bom_tail2"=p do
	. for i=1:1:10 set str(p,i)=str("utf16_fix_bom",i+4)
	. set str(p,"size")=10
	if "utf16_fix_nobom"=p do
	. for i=1:1:12 set str(p,i)=str("utf16_fix_bom",i+2)
	. set str(p,"size")=12
	if "utf16_fix_nobom_head"=p do
	. for i=1:1:3 set str(p,i)=str("utf16_fix_nobom",i)
	. set str(p,"size")=3
	if "utf16_fix_nobom_tail"=p do
	. for i=1:1:9 set str(p,i)=str("utf16_fix_nobom",i+3)
	. set str(p,"size")=9
	if "utf16_fix_nobom_head2"=p do
	. for i=1:1:2 set str(p,i)=str("utf16_fix_nobom",i)
	. set str(p,"size")=2
	if "utf16_fix_nobom_tail2"=p do
	. for i=1:1:10 set str(p,i)=str("utf16_fix_nobom",i+2)
	. set str(p,"size")=10
	if "utf16_fix_nobom_head3"=p do
	. for i=1:1:6 set str(p,i)=str("utf16_fix_nobom",i)
	. set str(p,"size")=6
	if "utf16_fix_nobom_tail3"=p do
	. for i=1:1:6 set str(p,i)=str("utf16_fix_nobom",i+6)
	. set str(p,"size")=6
	if "utf16_fix_nobom_head4"=p do
	. for i=1:1:4 set str(p,i)=str("utf16_fix_nobom",i+8)
	. set str(p,"size")=4
	if "utf16_fix_nobom_fill1"=p do
	. set str(p,1)=$char(0),str(p,2)=$char(32)
	. set str(p,"size")=2
	if "utf16_fix_nobom_fill2"=p do
	. set str(p,1)=$char(0),str(p,2)=$char(32),str(p,3)=$char(0),str(p,4)=$char(32)
	. set str(p,"size")=4
	for i=1:1:str(p,"size") write str(p,i)
	set $x=0
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

; The input parameters are all strings.  The purpose is to
; modify the outfile used by utffixfollow.m, in this case the name is rwutffixfile
; str is the name of a string stored in utfstr(str,<offset>) its size is in utfstr(str,"size")
; an example is utfstr("utf8_fix_bom",<1-18>) created by utfinitstr() above.
; it holds 3 bom bytes followed by 3 2-byte utf-8 chars, 5 1-byte utf-8 chars, and 2 2-byte utf-8 chars
; the size is 18 bytes stored in utfstr("utf8_fix_bom","size") and its width would be 10
; operations are: tail, tailnodel, and copy.  The tail operation waits 5 sec before appending from str
; to the outfile.  The tailnodel does the same operation without the wait time.  The copy operation
; truncates the outfile and copies from str into it.
modfile(outfile,str,operation)
	if "tail"=operation do
	. ; wait 5 sec before adding tail so the reader will have to "follow" the input
	. hang 5
	. open outfile:(append:ochset="M")
	if "tailnodel"=operation do
	. ; add tail without delay
	. open outfile:(append:ochset="M")
	if "copy"=operation do
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
