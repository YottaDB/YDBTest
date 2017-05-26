;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7439	;
	write "Call one of the other entryrefs",!
	quit

testbed ;
	new jb,flag,updatecnt,autoswitchlimit,updatesz,maxfilesz,reg,i,offset,len
	set autoswitchlimit=$ztrnlnm("autoswitchlimit")
	set updatesz=$ztrnlnm("updatesz")
	set maxfilesz=autoswitchlimit*512
	; Based on the size of one update and the maximum file size for the given autoswitchlimit, the below math coarsely
	; calculates the number of same sized update that causes the journal file to be "almost" full. By, "almost" full,
	; we are very close to nearing the autoswitch limit.
	; The 65536 indicates the size of the journal file header.
	set updatecnt=((maxfilesz-65536)/updatesz)-100
	set flag=0,reg=$view("REGION","^a")	; because updates are going to "^a" note down its mapping region
	set jb=$$getjb(reg)	; sets "offset" and "len" to offset and lengthn of "freeaddr" member inside "jnl_buff"
	for  quit:flag  do
	. set ^a($incr(i))=$j(i,200)
	. if (i<updatecnt) quit
	. ; We've now reached the coarse limit. After this point, we continue doing the regular updates but after every update
	. ; we check how close we are to the "actual" autoswitch limit. If we have less than 8192 bytes space available in the
	. ; Journal File, the updates are stopped. The parent script then does a few MUPIP EXTENDs each of which ends up writing
	. ; PINI, INCTN and PFIN records one of which ends up "finally" extending the Journal File.
	. set filesz=$zpeek("PEEK:"_jb,offset,len,"U")
	. set flag=((maxfilesz-filesz)<8192)
	quit
getjb(reg)	; routine to get the address of "jb" which will be later used to get jb->freeaddr
	do Init^GTMDefinedTypesInit	; Load field definitions for this version
	new index,struct,member
	set struct="sgmnt_addrs",member="jnl"
	set index=$$fetchfld(struct,member),offset=gtmtypes(struct,index,"off"),len=gtmtypes(struct,index,"len")
	set jpc=$zpeek("CSAREG:"_reg,offset,len,"X")
	;
	set struct="jnl_private_control",member="jnl_buff"
	set index=$$fetchfld(struct,member),offset=gtmtypes(struct,index,"off"),len=gtmtypes(struct,index,"len")
	set jb=$zpeek("PEEK:"_jpc,offset,len,"X")
	;
	set struct="jnl_buffer",member="freeaddr"
	set index=$$fetchfld(struct,member),offset=gtmtypes(struct,index,"off"),len=gtmtypes(struct,index,"len")
	quit jb
fetchfld(struct,member)
	new i,members,fldindex
	set members=gtmtypes(struct,0),fldindex=0
	for i=1:1:members if (gtmtypes(struct,i,"name")=(struct_"."_member)) set fldindex=i  quit
	quit fldindex
