;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; This M program parses stdin which contains detailed journal extract lines.
	; And determines 6 variables and writes them to "setvar.csh" which is later sourced by caller test.
	;	$before1 : -BEFORE time in previous generation jnl file (mumps.mjl_*)
	;	$before2 : -BEFORE time in current  generation jnl file (mumps.mjl)
	;	$since1  : -SINCE  time in previous generation jnl file (mumps.mjl_*)
	;	$since2  : -SINCE  time in current  generation jnl file (mumps.mjl)
	;	$resync1 : -RESYNC seqno corresponding to a jnlrecord in previous generation jnl file (mumps.mjl_*)
	;	$resync2 : -RESYNC seqno corresponding to a jnlrecord in current  generation jnl file (mumps.mjl)
	; SET updates are all in previous generation. TSET updates are all in current generation.
	new i,max
	for  read line($incr(i))  quit:$zeof
	kill line(i)  if $incr(i,-1)
	set max=i
	; line(i) now points to an array of journal extract lines
	; The journal extract would contain the following in that order
	;
	; Previous generation mjl file
	; ------------------------------
	; EPOCH\63840,48616\65536\1315246500\17547\0\1\0\98\101\1		<-- since1
	; SET\63840,48621\65536\1357066667\17670\0\1\0\0\0\0\^nontp(1)="1"	<-- before1
	; SET\63840,48622\65537\1921142181\17670\0\2\0\0\0\0\^nontp(2)="2"
	; SET\63840,48623\65538\1126562180\17670\0\3\0\0\0\0\^nontp(3)="3"	<-- resync1
	; EPOCH\63840,48624\65539\3683185203\17670\0\4\0\96\101\1
	; EPOCH\63840,48624\65539\3090979264\17696\0\4\0\96\101\1
	;
	; Current generation mjl file
	; -----------------------------
	; EPOCH\63840,48624\65539\2806990291\17696\0\4\0\96\101\1
	; TSET\63840,48624\65539\3152882788\17697\0\4\0\0\1\0\^tp(1)="1"	<-- since2
	; TSET\63840,48625\65540\1223565813\17697\0\5\0\0\1\0\^tp(2)="2"	<-- resync2
	; TSET\63840,48626\65541\885625867\17697\0\6\0\0\1\0\^tp(3)="3"		<-- before2
	; EPOCH\63840,48627\65542\2256871614\17697\0\7\0\94\101\1
	;
	; The code below also accounts for PFIN (although above extract listing does not show it)
	; because that is the last journal record in mjl file and could have a higher timestamp than
	; the last EPOCH. The last timestamp is needed to accurately determine the delta times for
	; the before1, before2, etc.
	set prev=0,num("EPOCH")=0,num("SET")=0,num("TSET")=0,num("PFIN")=0
	for i=1:1:max do
	. set type=$piece(line(i),"\",1)
	. if '$data(num(type))  write "TEST-E-FAIL : Found a jnl record that is not EPOCH, SET, TSET or PFIN",!  halt
	. if $incr(num(type))
	. set time=$piece(line(i),"\",2)
	. set seqno=$piece(line(i),"\",7)
	. if (type="EPOCH")&(1=num(type)) set since1=time
	. if (type="SET") do
	. . if (1=num(type)) set before1=time
	. . if (3=num(type)) set resync1=seqno
	. if (type="TSET") do
	. . if (1=num(type)) set since2=time
	. . if (2=num(type)) set resync2=seqno
	. . if (3=num(type)) set before2=time
	set maxtime=time
	set file="setvar.csh"
        open file:(newversion)
        use file
	write "set before1=""0 00:00:"_$$^difftime(maxtime,before1),"""",!	; write before1
	write "set before2=""0 00:00:"_$$^difftime(maxtime,before2),"""",!	; write before2
	write "set since1=""0 00:00:"_$$^difftime(maxtime,since1),"""",!	; write since1
	write "set since2=""0 00:00:"_$$^difftime(maxtime,since2),"""",!	; write since2
	write "set resync1="_resync1,!						; write resync1
	write "set resync2="_resync2,!						; write resync2
        close file
	quit
