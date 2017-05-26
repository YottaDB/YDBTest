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
gtm7756;
	write "use one the following entryref",!
	quit
accmeth;
	do Init^GTMDefinedTypesInit     ; Load field definitions for this version
	set struct="sgmnt_data",member="acc_meth"
	set members=gtmtypes(struct,0),index=0
	for i=1:1:members if (gtmtypes(struct,i,"name")=(struct_"."_member)) set index=i  quit
	set offset=gtmtypes(struct,index,"off"),len=gtmtypes(struct,index,"len")
	set acc=$zpeek("FHREG:DEFAULT",offset,len,"I")
	write "Access Method=",$select(acc=1:"BG",acc=2:"MM",1:"ERROR - Unexpected access method"),!
	quit
update;
	for i=1:1:1000 set ^x(i)=$j(i,240)
	set updatecnt=1500+$random(501)
	set ^a=1,^b=2
	for i=1:1:updatecnt set ^x(i)=$j(i,240)
	quit
