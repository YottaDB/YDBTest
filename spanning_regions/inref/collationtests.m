;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrongcoll	;
	set $ztrap="goto errorAndCont^errorAndCont",(zrealstor(1),zrealstor(2))=$zrealstor
	new i for i=1:1:2 do
	. write ^efgh(1,2,"efgh"),!
	. write ^mnop(1),!
	. set zrealstor(i)=$zrealstor   ; test that memory leaks dont happen due to repetitive errors
	write:zrealstor(1)'=zrealstor(2) "$zrealstor not the same : zrealstor(1)=",zrealstor(1),"zrealstor(2)="
	quit
gbldeftests	;
	write "# Test that $$get^%GBLDEF gets stuff from",!
	write "#  - the directory tree (e.g. ^efgh and REG5 or REG6)",!
	write "#  - OR gld (e.g. ^efgh and REG2 thru REG4)",!
	write "#  - OR db file hdr (^reg5 or ^reg6)",!
	write "# Also test that in case of ^efgh and REG1, the collation properties get lifted from gld even though",!
	write "# db file header has invalid/incorrect collation (i.e. test that gld gets picked ahead of db file header).",!
	write "^efgh collation            = ",$$get^%GBLDEF("^efgh"),!
	write "^efgh collation in REG1    = ",$$get^%GBLDEF("^efgh","REG1"),!
	write "^efgh collation in REG2    = ",$$get^%GBLDEF("^efgh","REG2"),!
	write "^efgh collation in REG3    = ",$$get^%GBLDEF("^efgh","REG3"),!
	write "^efgh collation in REG4    = ",$$get^%GBLDEF("^efgh","REG4"),!
	write "^efgh collation in REG5    = ",$$get^%GBLDEF("^efgh","REG5"),!
	write "^efgh collation in REG6    = ",$$get^%GBLDEF("^efgh","REG6"),!
	write "^efgh collation in DEFAULT = ",$$get^%GBLDEF("^efgh","DEFAULT"),!
	write "^reg3 collation in REG3    = ",$$get^%GBLDEF("^reg3","REG3"),!
	; The below will error out (and print 0) because dse change -fi -def=2 will not set def_coll_ver
	; and will continue to be 0. coll_straight has collation incompatibility between ver0 and ver3
	write "^reg4 collation in REG4    = ",$$get^%GBLDEF("^reg4","REG4"),!
	write "^reg5 collation in REG5    = ",$$get^%GBLDEF("^reg5","REG5"),!
	; The below should print 0,2,3 because def_coll_ver too was modified in fileheader
	write "^reg6 collation in REG6    = ",$$get^%GBLDEF("^reg6","REG6"),!
	quit
ygldcolltests	;
	write "# Tests for $VIEW(""YGLDCOLL"",""gname"")",!
	write "# If no collation properties are defined in the gld for this global (even if defined in db hdr), it returns 0",!
	write "$VIEW(""YGLDCOLL"",^efgh)  = ",$VIEW("YGLDCOLL","^efgh"),!
	write "$VIEW(""YGLDCOLL"",^reg5)  = ",$VIEW("YGLDCOLL","^reg5"),!
	write "$VIEW(""YGLDCOLL"",^reg5a) = ",$VIEW("YGLDCOLL","^reg5a"),!
	write "$VIEW(""YGLDCOLL"",^reg6)  = ",$VIEW("YGLDCOLL","^reg6"),!
	write "$VIEW(""YGLDCOLL"",^abcd)  = ",$VIEW("YGLDCOLL","^abcd"),!
	write "$VIEW(""YGLDCOLL"",^mnop)  = ",$VIEW("YGLDCOLL","^mnop"),!
	quit
ycollatetests	;
	write "# Tests for $VIEW(""YCOLLATE"",coll) and $VIEW(""YCOLLATE"",coll,ver)",!
	write "# Check version compatibility for reverse collation (1), which is backward compatible",!
	write $VIEW("YCOLLATE",1),!
	write $VIEW("YCOLLATE",1,1),!
	write $VIEW("YCOLLATE",1,6),!
	write "# Check version compatibility for straight collation (2), which has strict compatibility check",!
	write $VIEW("YCOLLATE",2),!
	write $VIEW("YCOLLATE",2,1),!
	write $VIEW("YCOLLATE",2,6),!
	quit
viewregs	;
	write "# Check $VIEW(""REGION"",""^gblname"") returns the correct multi-region list if applicable",!
	write $VIEW("REGION","^efgh"),!                         ; expect REG1,REG2,REG3,REG4,REG5,REG6
	write $VIEW("REGION","^efgh(1)"),!                      ; expect REG1,REG2,REG3,REG4,REG5
	write $VIEW("REGION","^efgh(1,2)"),!                    ; expect      REG2,REG3,REG4
	write $VIEW("REGION","^efgh(1,2,20)"),!                 ; expect                REG4
	write $VIEW("REGION","^efgh(1,3)"),!                    ; expect                     REG5
	write $VIEW("REGION","^efgh(""gtm"")"),!                ; expect REG1
	write $VIEW("REGION","^efgh($zchar(25))"),!             ; expect      REG2
	write $VIEW("REGION","^efgh($char(75))"),!              ; expect           REG3
	write $VIEW("REGION","^nocol(""gtm"")"),!               ; expect REG1
	write $VIEW("REGION","^nocol($zchar(25))"),!            ; expect     REG2
	write $VIEW("REGION","^nocol($char(75))"),!             ; expect           REG3,REG4,REG5
	write $VIEW("REGION","^nocol($char(75),$zchar(75))"),!  ; expect           REG3,     REG5
	write $VIEW("REGION","^abcd(1,3)"),!                    ; expect                               DEFAULT
	write $VIEW("REGION","^abcd"),!                         ; expect                               DEFAULT
	quit
gbldef2	;
	write "# Test that 0 collation defined in ADD -GBLNAME does override any non-zero collation defined in db file header",!
	write "^reg5  collation in REG5    = ",$$get^%GBLDEF("^reg5","REG5"),!
	write "^reg5a collation in REG5    = ",$$get^%GBLDEF("^reg5a","REG5"),!
	set ^reg5(1,"abcd")="zz"
	set ^reg5a(1,"abcd")="zz"
	write "^reg5  collation in REG5    = ",$$get^%GBLDEF("^reg5","REG5"),!
	write "^reg5a collation in REG5    = ",$$get^%GBLDEF("^reg5a","REG5"),!
	quit
