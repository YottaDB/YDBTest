;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb700	;
	set lf=$c(10)
	write "# Test multi-line trigger with no trailing "">>"". Expect no errors.",!
	set trigstr="+^a(sub1=0:100) -command=set -name=trig1 -xecute=<<"_lf_" write sub1,!"_lf
	do runtrig(trigstr)
	;
	write "# Test multi-line trigger with trailing "">>"". Expect no errors.",!
	set trigstr="+^b(sub1=0:100) -command=set -name=trig2 -xecute=<<"_lf_" write sub1,!"_lf_">>"
	do runtrig(trigstr)
	;
	write "# Test multi-line trigger with trailing "">>\n"". Expect no errors.",!
	set trigstr="+^c(sub1=0:100) -command=set -name=trig3 -xecute=<<"_lf_" write sub1,!"_lf_">>"_lf
	do runtrig(trigstr)
	;
	write "# Test valid multi-line trigger with -pieces and -delim coming after -xecute. Expect no errors.",!
	do multilinetrig(.trigstr,0)
	do runtrig(trigstr)
	;
	write "# Test multi-line trigger not terminated with a >>. Expect error due to missing >>.",!
	do multilinetrig(.trigstr,1)
	do runtrig(trigstr)
	;
	write "# Test valid multi-line trigger containing invalid M code. Expect errors.",!
	do multilinetrig(.trigstr,2)
	do runtrig(trigstr)
	;
	write "# Test trigger with multi-line trigger suffix [\n>>\n] but no [-xecute<<\n] prefix.",!
	write "#  --> Test -xecute AFTER -name. Expect error.",!
	set trigstr="+^c(sub1=0:100) -command=set -name=trig3"_lf_">>"_lf_" -xecute=""write 123"",!"
	do runtrig(trigstr)
	write "#  --> Test -xecute BEFORE -name. Expect error.",!
	set trigstr="+^c(sub1=0:100) -command=set -xecute=""write 123,!"" -name=trig3"_lf_">>"_lf_"abcd"
	do runtrig(trigstr)
	;
	quit

multilinetrig(trigstr,invalid)
	set trigstr="+^USPresidents"_invalid_"(sub1=*,sub2=*) -command=set -xecute=<<"_lf
	set trigstr=trigstr_" for i=1:1:$zlength($ztupdate,"","") set p=$piece($ztupdate,"","",i) do"_lf
	set trigstr=trigstr_" . set q=$piece($ztoldval,$ztdelim,p)"_lf
	set trigstr=trigstr_" . if $data(^d(p,q,sub1,sub2))#10 zkill ^(sub2) zkill:1>$increment(^d(-p,q),-1) ^(q)"_lf
	set trigstr=trigstr_" . set q=$piece($ztvalue,$ztdelim,p) zwrite"_lf
	set trigstr=trigstr_" . if '$data(^d(p,q,sub1,sub2)) set ^(sub2)="""" if $increment(^d(-p,q))"_lf
	set:(2=invalid) trigstr=trigstr_" . abcd"_lf
	set:(1'=invalid) trigstr=trigstr_">>"_lf
	set trigstr=trigstr_" -pieces=1:3 -delim=""|"""
	quit

runtrig(trigstr)
	zwrite trigstr
	write $ztrigger("item",trigstr),!
	quit
