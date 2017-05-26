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
viewregionAndGvstats	; Test that $VIEW("REGION") touches the correct # of regions
	write "$view(""REGION"",""^a"")=",$view("REGION","^a"),!
	write "$view(""REGION"",""^a(1)"")=",$view("REGION","^a(1)"),!
	write "$view(""REGION"",""^a(1,2)"")=",$view("REGION","^a(1,2)"),!
	write "$view(""REGION"",""^a(1,2,3)"")=",$view("REGION","^a(1,2,3)"),!
	;
	; ----------------------------------------------------------------------------
	; Test that do operations like $GET, $ORDER etc. touches correct # of regions
	;
	; To test kill, make sure all regions spanned by ^a have a non-zero GVT tree
	do init
	for str="^a","^a(1)","^a(1,2)","^a(1,2,3)" do
	. write "-------------- Testing operations on ",str," ---------------",!
	. view "RESETGVSTATS" write "$data(",str,")=",$data(@str),!  do zshowgdump
	. view "RESETGVSTATS" write "$get(",str,")=",$get(@str),!  do zshowgdump
	. view "RESETGVSTATS" write "$order(",str,")=",$order(@str),!  do zshowgdump
	. view "RESETGVSTATS" write "$order(",str,",-1)=",$order(@str,-1),!  do zshowgdump
	. view "RESETGVSTATS" write "$query(",str,")=",$query(@str),!  do zshowgdump
	. view "RESETGVSTATS" write "merge x=",str,!  merge x=@str  do zshowgdump
	. view "RESETGVSTATS" write "kill ",str,!  kill @str  do zshowgdump
	. do init ; restore ^a to state before the kill for following operations
	;
	; Test query for a few more cases
	quit
zshowgdump;
	new x
	zshow "G":x
	set subs=0
	for   set subs=$order(x("G",subs))  quit:subs=""  write $piece($piece(x("G",subs),",LKS"),".gld,",2),!
	write !
	quit
init	;
	set ^a(1)=1,^a(1,2)=1,^a(1,2,3)=1,^a(2)=2,^a(1,3)=3
	quit
