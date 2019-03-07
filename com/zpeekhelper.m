;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017,2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test $ZPEEK() function. Obtain fields from each supported control block type plus
; some adhoc queries based on extracted addresses. The fields are formatted in various ways.
; Added as part of GTM-7421 (InfoHub) but the functionality can certainly be useful outside
; InfoHub.
;
peekaboo	;
	Do init
	Quit
;
; Fetch a single field and return its value
;
getfld(base,fldname,fmt)	;
	;
	; Do initialization if not already done
	;
	If '$data(bigendian) Do init
	Set val=$Select((0=$Data(fmt)):$$fetchfld(base,fldname),1:$$fetchfld(base,fldname,fmt))
	Quit val

;
; Fetch a series of values in a chain with the value returned from each supplying the address for the
; next search until the last field in the series is fetched with the given format and returned.
; The format for fldlst is of the form "type.fldname|type.fldname|..".
;
getfldmulti(base,fldlst,fmt)
	New i,elem,nextelem,addr
	If '$data(bigendian) Do init	; Do initialization if not already done
	Set nextelem=$Piece(fldlst,"|",1)
	For i=1:1  Set elem=nextelem,nextelem=$Piece(fldlst,"|",i+1)  Quit:nextelem=""  Do
	. Set addr=$$fetchfld(base,elem,"X"),base="PEEK:"_addr
	Set val=$Select((0=$Data(fmt)):$$fetchfld(base,elem),1:$$fetchfld(base,elem,fmt))
	Quit val

;
; Initialization
;
init
	Set origlvl=$ZLevel
	Set $ETrap="ZShow ""*"" ZHalt 1"
	;
	; Determine the endianness of this process. Do this in a DO group so all the vars (except
	; bigendian) disappear when done. Values are endian|64bit.
	;
	Do
	. New env,gtmver,gtmos,gtmarch
	. Set env("AIX","RS6000")="1|1"
	. Set env("CYGWIN","x86")="0|0"
	. Set env("HP-UX","HP-PA")="1|0"
	. Set env("HP-UX","IA64")="1|1"
	. Set env("Linux","IA64")="0|1"
	. Set env("Linux","S390X")="1|1"
	. Set env("Linux","aarch64")="0|0"
	. Set env("Linux","armv7l")="0|0"
	. Set env("Linux","armv6l")="0|0"
	. Set env("Linux","x86")="0|0"
	. Set env("Linux","x86_64")="0|1"
	. Set env("OS390","S390")="1|1"
	. Set env("OSF1","AXP")="0|0"
	. Set env("Solaris","SPARC")="1|1"
	. Set gtmver=$ZVersion
	. Set gtmos=$ZPiece(gtmver," ",3)
	. Set gtmarch=$ZPiece(gtmver," ",4)
	. If (0=$Data(env(gtmos,gtmarch))) Do
	. . Write "Unknown configuration for:",gtmos," on ",gtmarch,!!
	. . ZHalt 1
	. Set bigendian=$ZPiece(env(gtmos,gtmarch),"|",1)
	. Set gtm64=$ZPiece(env(gtmos,gtmarch),"|",2)
	Quit

;
; Routine to extract the offset/length needed to fetch a given field and fetch it.
;
fetchfld(base,fldname,fmt)
	New val,region
	Set region=$Piece(base,":",2)
	Set val=$$^%PEEKBYNAME(fldname,region,$get(fmt))
	If ('bigendian&(0<$Data(fmt))&("Z"=fmt)) Do	; For this case, byte order of output is wrong - compensate
	. New i,len,newval
	. Set len=$ZLength(val)
	. For i=1:2:len-1 Set $ZExtract(newval,i,i+1)=$ZExtract(val,(len-i),(len-i+1))
	. Set val=newval
	Quit val
