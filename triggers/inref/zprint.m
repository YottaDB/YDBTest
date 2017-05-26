;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; From the design Spec
;ZPRINT ^x#/BREG      : Print           trigger routine user-named "x" in region BREG
;ZPRINT ^x#1#/BREG    : Print           trigger routine auto-named "x#1" in region BREG
;ZPRINT ^x#1#A/BREG   : Print           trigger routine auto-named "x#1", runtime disambiguated by "#A", AND in region BREG
;ZPRINT +1^x#1#A/BREG : Print line 1 of trigger routine auto-named "x#1", runtime disambiguated by "#A", AND in region BREG


zprint	;
	; a.gld    : a*,A*,b*,B* -> AREG ;                      ; * -> DEFAULT
	; b.gld    :                     ; a*,A*,b*,B* -> BREG  ; * -> DEFAULT
	; 3reg.gld : a* -> AREG          ; b* -> BREG           ; A*,B*,* -> DEFAULT
	;
	; bgld.trg : ^b - trig ; ^B - TRIG ; ^auto - <noname> : All goes to BREG
	; agld.trg : ^a - trig ; ^A - TRIG ; ^auto - <noname> : All goes to AREG
	;
	; Load BREG triggers first so that AREG triggers get the runtime disambiguator of "#A"
	set $zgbldir="b.gld" s ^b=1 S ^B=2 s ^auto=1
	set $zgbldir="a.gld" s ^a=1 S ^A=2 s ^auto=1
	set rtn=""
	;for  set rtn=$view("RTNNEXT",rtn) quit:rtn=""  if (rtn["#") w "rtn = ",rtn,?11," : "  zprint @("^"_rtn)
	set $zgbldir="3reg.gld" if $ztrigger("select")

	set $ztrap="goto errorAndCont^errorAndCont"
	set $zgbldir="a.gld"
	write "## zprint without region disambiguator (",$zgbldir,")",!
	write "zprint ^TRIG#      : ",$justify($zgbldir,10)," : " zprint ^TRIG#
	write "zprint ^TRIG#A     : ",$justify($zgbldir,10)," : " zprint ^TRIG#A
	write "zprint ^trig#      : ",$justify($zgbldir,10)," : " zprint ^trig#
	write "zprint ^trig#A     : ",$justify($zgbldir,10)," : " zprint ^trig#A
	write "zprint ^auto#1#    : ",$justify($zgbldir,10)," : " zprint ^auto#1#
	write "zprint ^auto#1#A   : ",$justify($zgbldir,10)," : " zprint ^auto#1#A
	write "zprint +1^auto#1#A : ",$justify($zgbldir,10)," : " zprint ^auto#1#A

	write "## $text() without region disambiguator (",$zgbldir,")",!
	write "$text(^TRIG#)      : ",$justify($zgbldir,10)," : ",$text(^TRIG#),!
	write "$text(^TRIG#A)     : ",$justify($zgbldir,10)," : ",$text(^TRIG#A),!
	write "$text(^trig#)      : ",$justify($zgbldir,10)," : ",$text(^trig#),!
	write "$text(^trig#A)     : ",$justify($zgbldir,10)," : ",$text(^trig#A),!
	write "$text(^auto#1#)    : ",$justify($zgbldir,10)," : ",$text(^auto#1#),!
	write "$text(^auto#1#A)   : ",$justify($zgbldir,10)," : ",$text(^auto#1#A),!
	write "$text(+1^auto#1#A) : ",$justify($zgbldir,10)," : ",$text(^auto#1#A),!

	write "## zbreak without region disambiguator (",$zgbldir,")",!
	write "zbreak ^TRIG#      : ",$justify($zgbldir,10)," : ",! zbreak ^TRIG#:"write ""zbreak ^TRIG#"",!"
	write "zbreak ^TRIG#A     : ",$justify($zgbldir,10)," : ",! zbreak ^TRIG#A:"write ""zbreak ^TRIG#A"",!"
	write "zbreak ^trig#      : ",$justify($zgbldir,10)," : ",! zbreak ^trig#:"write ""zbreak ^trig#"",!"
	write "zbreak ^trig#A     : ",$justify($zgbldir,10)," : ",! zbreak ^trig#A:"write ""zbreak ^trig#A"",!"
	write "zbreak ^auto#1#    : ",$justify($zgbldir,10)," : ",! zbreak ^auto#1#:"write ""zbreak ^auto#1#"",!"
	write "zbreak ^auto#1#A   : ",$justify($zgbldir,10)," : ",! zbreak ^auto#1#A:"write ""zbreak ^auto#1#A"",!"
	write "zbreak +1^auto#1#A : ",$justify($zgbldir,10)," : ",! zbreak ^auto#1#A:"write ""zbreak ^auto#1#A"",!"

	write !
	write "# Test for the below : @TC1",!
	write "# If both runtime disambiguator and region level disambiguator is specified,",!
	write "#     if the runtime disambiguator points to a loaded trigger routine that was",!
	write "#     read from a region different from the specified region name,",!
	write "#     ZPRINT will treat the routine as non-existent and issue a TRIGNAMENF error.",!

	for i=0:1:2 do
	. set:i=0 $zgbldir="a.gld"
	. set:i=1 $zgbldir="b.gld"
	. set:i=2 $zgbldir="3reg.gld"
	. write "## use region disambiguator. (",$zgbldir,")",! ; Region selection means BREG lookups fail",!
	. write "## various zprint cases",!
	. write "zprint ^TRIG#/AREG      : ",$justify($zgbldir,10)," : " zprint ^TRIG#/AREG
	. write "zprint ^TRIG#/BREG      : ",$justify($zgbldir,10)," : " zprint ^TRIG#/BREG
	. write "zprint ^TRIG#A/AREG     : ",$justify($zgbldir,10)," : " zprint ^TRIG#A/AREG
	. write "zprint ^TRIG#A/BREG     : ",$justify($zgbldir,10)," : " zprint ^TRIG#A/BREG
	. write "zprint ^trig#/AREG      : ",$justify($zgbldir,10)," : " zprint ^trig#/AREG
	. write "zprint ^trig#/BREG      : ",$justify($zgbldir,10)," : " zprint ^trig#/BREG
	. write "zprint ^trig#A/AREG     : ",$justify($zgbldir,10)," : " zprint ^trig#A/AREG
	. write "zprint ^trig#A/BREG     : ",$justify($zgbldir,10)," : " zprint ^trig#A/BREG
	. write "zprint ^auto#1#/AREG    : ",$justify($zgbldir,10)," : " zprint ^auto#1#/AREG
	. write "zprint ^auto#1#/BREG    : ",$justify($zgbldir,10)," : " zprint ^auto#1#/BREG
	. write "zprint ^auto#1#A/AREG   : ",$justify($zgbldir,10)," : " zprint ^auto#1#A/AREG
	. write "zprint ^auto#1#A/BREG   : ",$justify($zgbldir,10)," : " zprint ^auto#1#A/BREG
	. write "zprint +1^auto#1#A/AREG : ",$justify($zgbldir,10)," : " zprint ^auto#1#A/AREG
	. write !
	. write "## $text() using the same region disambiguator as zprint above",!
	. write "$text(^TRIG#/AREG)      : ",$justify($zgbldir,10)," : ",$text(^TRIG#/AREG),!
	. write "$text(^TRIG#/BREG)      : ",$justify($zgbldir,10)," : ",$text(^TRIG#/BREG),!
	. write "$text(^TRIG#A/AREG)     : ",$justify($zgbldir,10)," : ",$text(^TRIG#A/AREG),!
	. write "$text(^TRIG#A/BREG)     : ",$justify($zgbldir,10)," : ",$text(^TRIG#A/BREG),!
	. write "$text(^trig#/AREG)      : ",$justify($zgbldir,10)," : ",$text(^trig#/AREG),!
	. write "$text(^trig#/BREG)      : ",$justify($zgbldir,10)," : ",$text(^trig#/BREG),!
	. write "$text(^trig#A/AREG)     : ",$justify($zgbldir,10)," : ",$text(^trig#A/AREG),!
	. write "$text(^trig#A/BREG)     : ",$justify($zgbldir,10)," : ",$text(^trig#A/BREG),!
	. write "$text(^auto#1#/AREG)    : ",$justify($zgbldir,10)," : ",$text(^auto#1#/AREG),!
	. write "$text(^auto#1#/BREG)    : ",$justify($zgbldir,10)," : ",$text(^auto#1#/BREG),!
	. write "$text(^auto#1#A/AREG)   : ",$justify($zgbldir,10)," : ",$text(^auto#1#A/AREG),!
	. write "$text(^auto#1#A/BREG)   : ",$justify($zgbldir,10)," : ",$text(^auto#1#A/BREG),!
	. write "$text(+1^auto#1#A/AREG) : ",$justify($zgbldir,10)," : ",$text(^auto#1#A/AREG),!
	. write !
	. write "## zbreak using the same region disambiguator as zprint above",!
	. write "zbreak ^TRIG#/AREG      : ",$justify($zgbldir,10)," : " zbreak ^TRIG#/AREG:"write ""zbreak ^TRIG#/AREG"",!"
	. write "zbreak ^TRIG#/BREG      : ",$justify($zgbldir,10)," : " zbreak ^TRIG#/BREG:"write ""zbreak ^TRIG#/BREG"",!"
	. write "zbreak ^TRIG#A/AREG     : ",$justify($zgbldir,10)," : " zbreak ^TRIG#A/AREG:"write ""zbreak ^TRIG#A/AREG"",!"
	. write "zbreak ^TRIG#A/BREG     : ",$justify($zgbldir,10)," : " zbreak ^TRIG#A/BREG:"write ""zbreak ^TRIG#A/BREG"",!"
	. write "zbreak ^trig#/AREG      : ",$justify($zgbldir,10)," : " zbreak ^trig#/AREG:"write ""zbreak ^trig#/AREG"",!"
	. write "zbreak ^trig#/BREG      : ",$justify($zgbldir,10)," : " zbreak ^trig#/BREG:"write ""zbreak ^trig#/BREG"",!"
	. write "zbreak ^trig#A/AREG     : ",$justify($zgbldir,10)," : " zbreak ^trig#A/AREG:"write ""zbreak ^trig#A/AREG"",!"
	. write "zbreak ^trig#A/BREG     : ",$justify($zgbldir,10)," : " zbreak ^trig#A/BREG:"write ""zbreak ^trig#A/BREG"",!"
	. write "zbreak ^auto#1#/AREG    : ",$justify($zgbldir,10)," : " zbreak ^auto#1#/AREG:"write ""zbreak ^auto#1#/AREG"",!"
	. write "zbreak ^auto#1#/BREG    : ",$justify($zgbldir,10)," : " zbreak ^auto#1#/BREG:"write ""zbreak ^auto#1#/BREG"",!"
	. write "zbreak ^auto#1#A/AREG   : ",$justify($zgbldir,10)," : " zbreak ^auto#1#A/AREG:"write ""zbreak ^auto#1#A/AREG"",!"
	. write "zbreak ^auto#1#A/BREG   : ",$justify($zgbldir,10)," : " zbreak ^auto#1#A/BREG:"write ""zbreak ^auto#1#A/BREG"",!"
	. write "zbreak +1^auto#1#A/AREG : ",$justify($zgbldir,10)," : " zbreak ^auto#1#A/AREG:"write ""zbreak ^auto#1#A/AREG"",!"
	. write !
	;
	write !
	write "# Test for the below : @TC2",!
	write "#  if say ZPRINT ^x#/XREG is specified and we find a trigger named x in XREG,",!
	write "#     but it corresponds to a global name ^x (spanning or non-spanning) which is",!
	write "#     not mapped to XREG by the current $zgbldir,",!
	write "#     ZPRINT will treat the trigger as invisible and issue a TRIGNAMENF error.",!
	set $zgbldir="3reg.gld"
	write "# @TC2 : ^trig#A is of global ^a residing in AREG",!
	write "#      : ^TRIG#A is of global ^A residing in AREG",!
	write "#      : 3reg.gld maps ^a to AREG but ^A to DEFAULT",!
	write "# ^a maps to AREG and hence the below should print the trigger",!
	write "# @TC2 : zprint ^trig#A/AREG : "  zprint ^trig#A/AREG
	write "# ^A maps to DEFAULT and hence the below should error",!
	write "# @TC2 : zprint ^TRIG#A/AREG : "  zprint ^TRIG#A/AREG
	write "## end ##",!
	quit
