;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utftimeoutinit
	; Create utf strings to be used by utffollowtimeout.m
	; With conditionals and some modifications, this routine could be combined with
	; utffixinit.m and utfinit.m
	; The structure of these routines is the same, but there are differences in
	; the files and strings being created.  The "wait" routine is common, but there
	; are differences in routines such as "modfile".
	do ^sstepgbl
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	do utfinitstr(.utfstr,"utf8_timeout_with_bom")
	do utfinitstr(.utfstr,"utf8_timeout_just_bom")
	do utfinitstr(.utfstr,"utf8_timeout_no_bom")
	do utfinitstr(.utfstr,"utf16_timeout_with_bom")
	do utfinitstr(.utfstr,"utf16_timeout_no_bom")
	do utfinitstr(.utfstr,"utf16_timeout_just_bom")

	; init of files and strings done so set ^a to initdone
	set outfile=$zcmdline
	write "outfile = ",outfile,!
	write "setting ^a to initdone",!
	set ^a="initdone"

	do wait("td1")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_no_bom","tail")
	do wait("td2")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_just_bom","tail",,0)
	; wait 5 more sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_no_bom","tail",0)
	do wait("td3")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_timeout_just_bom","tail",,0)
	; wait 5 more sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_timeout_no_bom","tail",0)
	do wait("cp1")
	do modfile(outfile,"utf8_timeout_with_bom","copy")
	do wait("cp2")
	do modfile(outfile,"utf16_timeout_with_bom","copy")
	do wait("cp3")
	do modfile(outfile,"utf8_timeout_just_bom","copy")
	do wait("cp4")
	do modfile(outfile,"utf16_timeout_just_bom","copy")
	do wait("td4")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_no_bom","tail")
	do wait("td5")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_just_bom","tail",,0)
	; wait 5 more sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf8_timeout_no_bom","tail",0)
	do wait("td6")
	; wait 5 sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_timeout_just_bom","tail",,0)
	; wait 5 more sec before adding tail so the reader will have to "follow" the input
	do modfile(outfile,"utf16_timeout_no_bom","tail",0)
	do wait("cp5")
	do modfile(outfile,"utf8_timeout_with_bom","copy")
	do wait("cp6")
	do modfile(outfile,"utf16_timeout_with_bom","copy")
	do wait("cp7")
	do modfile(outfile,"utf8_timeout_just_bom","copy")
	do wait("cp8")
	do modfile(outfile,"utf16_timeout_just_bom","copy")
	quit

utfinitstr(str,p)
	write "initialize ",p,!
	open p:(newversion:ochset="M":key=key_" "_iv)
	use p
	if "utf8_timeout_with_bom"=p do
	. set str(p,1)=$char(239),str(p,2)=$char(187),str(p,3)=$char(191),str(p,4)=$char(213),str(p,5)=$char(135)
	. set str(p,6)=$char(213),str(p,7)=$char(136),str(p,8)=$char(213),str(p,9)=$char(137)
	. set str(p,"size")=9
	if "utf8_timeout_just_bom"=p do
	. for i=1:1:3 set str(p,i)=str("utf8_timeout_with_bom",i)
	. set str(p,"size")=3
	if "utf8_timeout_no_bom"=p do
	. for i=1:1:6 set str(p,i)=str("utf8_timeout_with_bom",i+3)
	. set str(p,"size")=6
	if "utf16_timeout_with_bom"=p do
	. set str(p,1)=$char(254),str(p,2)=$char(255),str(p,3)=$char(5),str(p,4)=$char(71),str(p,5)=$char(5)
	. set str(p,6)=$char(72),str(p,7)=$char(5),str(p,8)=$char(73)
	. set str(p,"size")=8
	if "utf16_timeout_just_bom"=p do
	. for i=1:1:2 set str(p,i)=str("utf16_timeout_with_bom",i)
	. set str(p,"size")=2
	if "utf16_timeout_no_bom"=p do
	. for i=1:1:6 set str(p,i)=str("utf16_timeout_with_bom",i+2)
	. set str(p,"size")=6
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
modfile(outfile,str,operation,doOpen,doClose)
	set doOpen=$get(doOpen,1)
	set doClose=$get(doClose,1)
	if "tail"=operation do
	. ; wait 5 sec before adding tail so the reader will have to "follow" the input
	. hang 5
	. open:doOpen outfile:(append:ochset="M":key=key_" "_iv)
	if "tailnodel"=operation do
	. ; add tail without delay
	. open:doOpen outfile:(append:ochset="M":key=key_" "_iv)
	if "copy"=operation do
	. open:doOpen outfile:(truncate:write:ochset="M":key=key_" "_iv)
	use outfile
	; convert to a string
	new outstr
	set outstr=""
	for i=1:1:utfstr(str,"size") set outstr=outstr_utfstr(str,i)
	write outstr
	set:doClose $x=0
	close:doClose outfile
	quit
