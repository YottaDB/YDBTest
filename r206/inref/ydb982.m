;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
qlength ; # Test $QLENGTH() with supported/unsupported ^# globals with various subscripts, with and without environments
	new $etrap,incrtrapPOST,tnode,tenv,nsubs,tsubs,s
	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	set incrtrapPOST="write !"
	set $etrap="set $ecode="""" do incrtrap^incrtrap"
	;
	set tnode="&t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!
	set tnode="#t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!
	set tnode="^#t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""#TNAME"",""trigger"",""#TNCOUNT"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""#TNAME"",""trigger#1"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 2",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""BHASH"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""CHSET"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""CMD"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""LHASH"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""TRIGNAME"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",1,""EXECUTE"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 3",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",""#COUNT"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 2",!
	write $qlength(tnode),!
	set tnode="^#t(""trigger"",""#CYCLE"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 2",!
	write $qlength(tnode),!
	set tnode="^[""mumps.gld""]#t(""trigger"",""#LABEL"")"
	write "## Test that $QLENGTH("_tnode_") correctly returns 2",!
	write $qlength(tnode),!
	set tnode="^[""trigger.gld""]#t(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QLENGTH("_tnode_") correctly returns 4",!
	write $qlength(tnode),!
	set tnode="^[""trigger.gld""]#T(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!
	set tnode="^[""trigger.gld""]&t(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="["""_tenv_"""]"
	set tnode="^"_tenv_"#t",nsubs=27
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QLENGTH("_tnode_") correctly returns "_nsubs,!
	write $qlength(tnode),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="["""_tenv_"""]"
	set tnode="^"_tenv_"#T",nsubs=$random(32)
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="["""_tenv_"""]"
	set tnode="^"_tenv_"#tt",nsubs=$random(32)
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="["""_tenv_"""]"
	set tnode="^"_tenv_"#"_$$^%RANDSTR($random(31),"65:1:90,97:1:115,117:1:122")
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QLENGTH("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qlength(tnode),!!
	;
	quit
	;
qsubscript ; # Test $QSUBSCRIPT() with supported/unsupported ^# globals with various subscripts, with and without environments
	new $etrap,incrtrapPOST,tnode,tenv,nsubs,tsubs,s,num
	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	set incrtrapPOST="write !"
	set $etrap="set $ecode="""" do incrtrap^incrtrap"
	;
	set tnode="&t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QSUBSCRIPT("_tnode_",0) returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,0),!
	set tnode="#t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QSUBSCRIPT("_tnode_",0) returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,0),!
	set tnode="^#t(""#TNAME"",""trigger"",""#SEQNUM"")"
	write "## Test that $QSUBSCRIPT("_tnode_",1) correctly returns #TNAME",!
	write $qsubscript(tnode,1),!
	set tnode="^#t(""#TNAME"",""trigger"",""#TNCOUNT"")"
	write "## Test that $QSUBSCRIPT("_tnode_",2) correctly returns trigger",!
	write $qsubscript(tnode,2),!
	set tnode="^#t(""#TNAME"",""trigger#1"")"
	write "## Test that $QSUBSCRIPT("_tnode_",1) correctly returns #TNAME",!
	write $qsubscript(tnode,1),!
	set tnode="^#t(""trigger"",1,""BHASH"")"
	write "## Test that $QSUBSCRIPT("_tnode_",3) correctly returns BHASH",!
	write $qsubscript(tnode,3),!
	set tnode="^#t(""trigger"",1,""CHSET"")"
	write "## Test that $QSUBSCRIPT("_tnode_",2) correctly returns 1",!
	write $qsubscript(tnode,2),!
	set tnode="^#t(""trigger"",1,""CMD"")"
	write "## Test that $QSUBSCRIPT("_tnode_",1) correctly returns trigger",!
	write $qsubscript(tnode,1),!
	set tnode="^#t(""trigger"",1,""LHASH"")"
	write "## Test that $QSUBSCRIPT("_tnode_",2) correctly returns 1",!
	write $qsubscript(tnode,2),!
	set tnode="^#t(""trigger"",1,""TRIGNAME"")"
	write "## Test that $QSUBSCRIPT("_tnode_",3) correctly returns TRIGNAME",!
	write $qsubscript(tnode,3),!
	set tnode="^#t(""trigger"",1,""EXECUTE"")"
	write "## Test that $QSUBSCRIPT("_tnode_",1) correctly returns trigger",!
	write $qsubscript(tnode,1),!
	set tnode="^#t(""trigger"",""#COUNT"")"
	write "## Test that $QSUBSCRIPT("_tnode_",2) correctly returns #COUNT",!
	write $qsubscript(tnode,2),!
	set tnode="^#t(""trigger"",""#CYCLE"")"
	write "## Test that $QSUBSCRIPT("_tnode_",1) correctly returns trigger",!
	write $qsubscript(tnode,1),!
	set tnode="^|""mumps.gld""|#t(""trigger"",""#LABEL"")"
	write "## Test that $QSUBSCRIPT("_tnode_",-1) correctly returns mumps.gld",!
	write $qsubscript(tnode,-1),!
	set tnode="^|""mumps.gld""|#t(""trigger"",""#LABEL"")"
	write "## Test that $QSUBSCRIPT("_tnode_",0) correctly returns ^#t",!
	write $qsubscript(tnode,0),!
	set tnode="^|""trigger.gld""|#t(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QSUBSCRIPT("_tnode_",3) correctly returns 1147172657",!
	write $qsubscript(tnode,3),!
	set tnode="^[""trigger.gld""]#T(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QSUBSCRIPT("_tnode_",-1) returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,-1),!
	set tnode="^[""trigger.gld""]&t(""trigger"",""#TRHASH"",1147172657,1)"
	write "## Test that $QSUBSCRIPT("_tnode_",0) returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,0),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#t",nsubs=$random(32)
	set num=$random(nsubs+1)
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QSUBSCRIPT("_tnode_") correctly returns without %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,num),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#T",nsubs=$random(32)
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QSUBSCRIPT("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,num),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#tt",nsubs=$random(32)
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QSUBSCRIPT("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,num),!!
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#"_$$^%RANDSTR($random(31),"65:1:90,97:1:115,117:1:122")
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $QSUBSCRIPT("_tnode_") returns %YDB-E-NOCANONICNAME error",!
	write $qsubscript(tnode,num),!!
	;
	quit
	;
view ; # Test $VIEW("YGVN2GDS") with supported/unsupported ^# globals with various subscripts, with and without environments
	new $etrap,incrtrapPOST,tnode,nsubs,tsubs,s,RESULT
	; Needed to transfer control to next M line after error (instead of stopping execution) in various error cases below
	set incrtrapPOST="write !"
	set $etrap="set $ecode="""" do incrtrap^incrtrap"
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#t",nsubs=$random(32)
	set num=$random(nsubs+1)
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $VIEW(""YGVN2GDS"","_tnode_") correctly returns without %YDB-E-NOCANONICNAME error",!
	set RESULT=$view("ygvn2gds",tnode)
	zwrite:$data(RESULT) RESULT write ! kill RESULT
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#T",nsubs=$random(32)
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $VIEW(""YGVN2GDS"","_tnode_") returns %YDB-E-NOCANONICNAME error",!
	set RESULT=$view("ygvn2gds",tnode)
	zwrite:$data(RESULT) RESULT kill RESULT
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#tt",nsubs=$random(32)
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $VIEW(""YGVN2GDS"","_tnode_") returns %YDB-E-NOCANONICNAME error",!
	set RESULT=$view("ygvn2gds",tnode)
	zwrite:$data(RESULT) RESULT kill RESULT
	;
	set tenv=$$^%RANDSTR($random(19),,"A") set:$length(tenv) tenv="|"""_tenv_"""|"
	set tnode="^"_tenv_"#"_$$^%RANDSTR($random(31),"65:1:90,97:1:115,117:1:122")
	; nsubs can be 0-31, +2 so that $random can't error and subscript 31 is possible, and -1 so that environment is possible
	set num=$random(nsubs+2)-1
	set tsubs="" for s=1:1:nsubs set tsubs=tsubs_""""_$$^%RANDSTR($random(18)+1)_""","
	if nsubs set $extract(tsubs,$length(tsubs))=")",tnode=tnode_"("_tsubs
	write "## Test that $VIEW(""YGVN2GDS"","_tnode_") returns %YDB-E-NOCANONICNAME error",!
	set RESULT=$view("ygvn2gds",tnode)
	zwrite:$data(RESULT) RESULT
	;
	quit
