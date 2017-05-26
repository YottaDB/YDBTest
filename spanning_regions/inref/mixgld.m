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
mixgld	;
	do ^job("child^mixgld",20,"""""")
	quit
mixgldtp	;
	set jmaxwait=0
	do ^job("tp^mixgld",2,"""""")
	hang 10
	set ^stop=1 do wait^job
	quit
child	;
	for cnt=1:1:100 do
	. for i=1:1:3 do
	. . set $zgbldir="mixgld"_i_".gld"
	. . for j=1:1:30 set ^a(j,cnt,jobindex)=i_" "_j_" "_cnt_" "_jobindex
	for cnt=1:1:100 do
	. for i=1:1:3 do
	. . set $zgbldir="mixgld"_i_".gld"
	. . for j=1:1:30 if ^a(j,cnt,jobindex)'=(i_" "_j_" "_cnt_" "_jobindex) write "VERIFY FAIL",!  zshow "vs"  halt
	quit
tp	;
	for  quit:$data(^stop)  do
	. set cnt=$incr(cnt)
	. tstart i:serial
	. for i=1:1:100 do
	. . if (1=jobindex) set ^a(10,i)=cnt_":"_i_":"_jobindex
	. . if (2=jobindex) set ^a(15,i)=cnt_":"_i_":"_jobindex
	. w:0'=$trestart "$TRESTART:",$trestart," @ ",cnt,!
	. tcommit
	quit
subset	;
	set $zgbldir="mixgld2.gld"
	write "$zgbldir : ",$zgbldir,!
	for i=19:1:23 write "^a("_i_") = "_^a(i,1,1),!
	set $zgbldir="mixgld3.gld"
	write "$zgbldir : ",$zgbldir,!
	for i=19:1:23 write "^a("_i_") = "_^a(i,1,1),!
	quit
subsetextended	;
	set $zgbldir="mixgld1.gld"
	set gld2="mixgld2.gld"
	set gld3="mixgld3.gld"
	write "Using Extended references",!
	for i=19:1:23 do
	. write gld2_" : ^a("_i_",2) = "_^[gld2]a(i,2,2),!
	. write gld3_" : ^a("_i_",2) = "_^|gld3|a(i,2,2),!
	quit
subsetnaked	;
	set $zgbldir="mixgld1.gld"
	set gld2="mixgld2.gld"
	set gld3="mixgld3.gld"
	write "Using naked references",!
	for i=19:1:23 do
	. set ^|gld2|a(i)=gld2_" naked reference test"
	. write "^("_i_",3) = "_^(i,3,3),!
	write "$reference : "_$reference,!
	for i=19:1:23 do
	. set ^[gld3]a(i)=gld3_" naked reference test"
	. write "^("_i_",3) = "_^(i,3,3),!
	write "$reference : "_$reference,!
	quit
