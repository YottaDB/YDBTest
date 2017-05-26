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
trigreload	;
	set $zgbldir="a.gld"
	if $ztrigger("item","+^a -commands=set -name=x -xecute=""write """"NON-SPANNING trigger on ^a user-named x in a.dat"""",!""")
	set $zgbldir="b.gld"
	if $ztrigger("item","+^a -commands=set -name=x -xecute=""write """"NON-SPANNING trigger on ^a user-named x in b.dat"""",!""")
	for value="a","b" set $zgbldir=value_".gld" set ^a=value
	set rtn=""  for  set rtn=$view("RTNNEXT",rtn) quit:rtn=""  if (rtn'="trigreload")&(rtn'="GTM$DMOD") write "rtn = ",rtn,?11," : "  zprint @("^"_rtn)
	quit
update  ;
	set $zgbldir="a.gld"
	if $ztrigger("item","-^a -commands=set -name=x -xecute=""write """"NON-SPANNING trigger on ^a user-named x in a.dat"""",!""")
	for value="a","b" set $zgbldir=value_".gld" set ^a=value
	quit
testreload	;
	set $ztrap="goto errorAndCont^errorAndCont"
	do trigreload
	write "# zprint,$text of ^x#A and ^x# should print the corresponding M routine",!
	write "# zprint ^x#A : " zprint ^x#A
	write "# zprint ^x#  : " zprint ^x#
	write "# $text(^x#A) : ",$text(^x#A),!
	write "# $text(^x#)  : ",$text(^x#A),!
	write "# zbreak should work fine",!
	write "# zbreak ^x#  : ",! zbreak ^x#:"write ""zbreak ^x# works"",!"
	write "# using zsystem, run another routine that deletes trigger ^x#",!
	zsystem ("$gtm_exe/mumps -run update^trigreload")
	write "# Though ^x# is deleted, zprint and $text of ^x# should still print the previously loaded M routine",!
	write "# zprint ^x#  : " zprint ^x#
	write "# $text(^x#)  : ",$text(^x#),!
	write "# setting zbreak should work fine",!
	write "# zbreak ^x#  : ",! zbreak ^x#:"write ""zbreak ^x# works"",!"
	write "# set ^a and do zprint/$text/zbreak",!
	set ^a=$zgbldir
	write "# zprint ^x#  : " zprint ^x#
	write "# $text(^x#)  : ",$text(^x#),!
	write "# zbreak ^x#  : ",! zbreak ^x#:"write ""zbreak ^x# works"",!"
	write !,"# Do the same after setting $zgbldir to a.gld",!
	set $zgbldir="a.gld"
	write "# zprint ^x#  : " zprint ^x#
	write "# $text(^x#)  : ",$text(^x#),!
	write "# zbreak ^x#  : ",! zbreak ^x#:"write ""zbreak ^x# works"",!"
	write "# set ^a and do zprint/$text/zbreak",!
	set ^a=$zgbldir
	write "# zprint ^x#  : ",! zprint ^x#
	write "# $text(^x#)  : ",$text(^x#),!
	write "# zbreak ^x#  : ",! zbreak ^x#:"write ""zbreak ^x# works"",!"
	quit
