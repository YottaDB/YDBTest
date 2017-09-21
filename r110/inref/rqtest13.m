;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See u_inref/rqtest13.csh for purpose of test. Also see reference file outref/rqtest13.txt for a better picture.
;
rqtest13;
	set dir=+$piece($zcmdline," ",1)
	if dir=1 do
	. write " --> Testing $query <--- ",!
	. set y="^a" for  set nexty=$query(@y,dir) write "$query(",y,",",dir,")=",nexty,!  quit:nexty=""  set y=nexty
	. write " --> Testing $order <--- ",!
	. set subs="" for  set nextsubs=$order(^a(subs),dir) write "$order(^a(",$zwrite(subs),"),",dir,")=",nextsubs,!  quit:nextsubs=""  set subs=nextsubs
	else  do
	. write " --> Testing reverse $query <--- ",!
	. set y="^a(""z"")" for  set prevy=$query(@y,dir) write "$query(",y,",",dir,")=",prevy,!  set y=prevy  quit:y=""
	. write " --> Testing reverse $order <--- ",!
	. set subs="" for  set prevsubs=$order(^a(subs),dir) write "$order(^a(",$zwrite(subs),"),",dir,")=",prevsubs,!  quit:prevsubs=""  set subs=prevsubs
	quit
creategld;
	set file="mumps.gde"
	open file:(newversion)
	use file
	write "template -region -std",!
	write "template -segment -block_size=4096",!
	write "template -region -record_size=4096",!
	write "change -region DEFAULT -std",!
	write "change -segment DEFAULT -block_size=4096",!
	write "change -region DEFAULT -record_size=4096",!
	write "change -segment DEFAULT -file=mumps.dat",!
	write "add -name a -region=areg",!
	write "add -region areg -dyn=aseg",!
	write "add -segment aseg -file=a",!
	write "add -name b -region=breg",!
	write "add -region breg -dyn=bseg",!
	write "add -segment bseg -file=b",!
	write "add -name c -region=creg",!
	write "add -region creg -dyn=cseg",!
	write "add -segment cseg -file=c",!
	for i=1:1:20  do
	. write "add -name a(",i,") -reg=",$$pickreg(),!
	close file
	quit
pickreg()	;
	new rand
	set rand=$random(4)
	if rand=0 quit "areg"
	if rand=1 quit "breg"
	if rand=2 quit "creg"
	if rand=3 quit "default"
	quit
init	;
	new i
	set val1=1,val2=$j(1,4096)	; randomly choose spanning nodes
	for i=1:1:20 do set("^a("_i_")")
	quit
set(str);
	set val=$select($random(2):val1,1:val2)
	set @str=val
	quit
