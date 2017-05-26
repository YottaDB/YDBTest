;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8558 ; verify that an empty 2nd argument does not leave a $FNUMBER() result vulnerable to trashing
	;
	kill cnt,tmp,good
	for i=1:1:50000 do
	. set a=$$key("T",3),b=$$key("N",8),c=$$key("N",4),d=$fnumber(0.01,"",2)
	. set tmp(a,b,c)=d
	. if "0.01"'=tmp(a,b,c) zwrite tmp(a,b,c)
	write !,"starting scan",!
	set (i,j,k)=""
	for  set i=$order(tmp(i)) quit:""=i  do
	. for  set j=$order(tmp(i,j)) quit:""=j  do
	. . for  set k=$order(tmp(i,j,k)) quit:""=k  do
	. . . if "0.01"'=tmp(i,j,k),$increment(cnt) zwrite tmp(i,j,k)
	. . . else  if $increment(good)
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)," ",$fnumber(+$get(good),",")," good items out of 50,000",!
	quit
key(type,length);
	new i,key
	for i=1:1:length set key=$get(key)_$select("N"=type:$random(9),1:$char($random(25)+65))
	quit key
