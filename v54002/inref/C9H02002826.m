;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9H02002826     ;test for proper behavior for edge cases involving canonic number boundaries
	;
	new (act)
	if '$data(act) new act set act="w ! zprint @$zposition zshow ""sv"""
	new $etrap,$estack
	set $etrap="goto err",$ecode=""
	set maxdigits=18
	do t1,t2,t3,t4,t5,t6,t7,t8,t9
end	write !,$select($get(cnt):cnt_" FAILURES",1:"PASS")," from ",$text(+0)
	quit
t1	; check that $order() returns maintain stringiness of noncanonic numeric subscripts
	new $estack
	kill a,x,^a
	set (a(".2"),^a(".2"))=1
	set (a(".123456789012345678901"),^a(".123456789012345678901"))=1
	set x=""
	set x=$o(a(x)) if .2'=x,$increment(cnt) xecute act
	set x=$o(a(x)) if ".123456789012345678901"'=x,$increment(cnt) xecute act
	set x=$o(a(x)) if ""'=x,$increment(cnt) xecute act
	kill a
	set x=""
	set x=$o(^a(x)) if .2'=x,$increment(cnt) xecute act
	set x=$o(^a(x)) if ".123456789012345678901"'=x,$increment(cnt) xecute act
	set x=$o(^a(x)) if ""'=x,$increment(cnt) xecute act
	quit
t2	; check that sorts-after does string comparison even when one number is a non-canonic numeric
	new $estack
	if "a"']]"12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if "1"]]"12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if 1]]"12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if "a"']]".12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if "1"]]".12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if 1]]".12345678901234567890123456789012345678901234567890",$increment(cnt) xecute act
	if "12345678901234567890123456789012345678901234567890"]]"a",$increment(cnt) xecute act
	if "12345678901234567890123456789012345678901234567890"']]"1",$increment(cnt) xecute act
	if "12345678901234567890123456789012345678901234567890"']]1,$increment(cnt) xecute act
	if ".12345678901234567890123456789012345678901234567890"]]"a",$increment(cnt) xecute act
	if ".12345678901234567890123456789012345678901234567890"']]"1",$increment(cnt) xecute act
	if ".12345678901234567890123456789012345678901234567890"']]1,$increment(cnt) xecute act
	quit
t3	; check that non-canonic string subscripts are treated as strings
	new $estack
	kill a,x,^a
	set accur=$p("","0",$length("12345678901234567890123456789012345678901234567890")-maxdigits)
	set accur=$extract("12345678901234567890123456789012345678901234567890",1,maxdigits)_accur
	set a("-12345678901234567890123456789012345678901234567890")=1
	set a("-.12345678901234567890123456789012345678901234567890")=1
	set a("-12345678901234567890123456789012345678901234567.890")=1
	set a("12345678901234567890123456789012345678901234567890")=1
	set a(".12345678901234567890123456789012345678901234567890")=1
	set a("12345678901234567890123456789012345678901234567.890")=1
	kill x set x=""
	set x=$order(a(x)) quit:""=x  set y=+x set:y<0 y=-y set:y<1 y=$extract(y,2,9999) if accur'=y,$increment(cnt) xecute act
	kill a
	set ^a("-12345678901234567890123456789012345678901234567890")=1
	set ^a("-.12345678901234567890123456789012345678901234567890")=1
	set ^a("-12345678901234567890123456789012345678901234567.890")=1
	set ^a("12345678901234567890123456789012345678901234567890")=1
	set ^a(".12345678901234567890123456789012345678901234567890")=1
	set ^a("12345678901234567890123456789012345678901234567.890")=1
	kill x set x=""
	set x=$order(^a(x)) quit:""=x  set y=+x set:y<0 y=-y set:y<1 y=$extract(y,2,9999) if accur'=y,$increment(cnt) xecute act
	kill accur
	quit
t4	; check for correct handling of a decimal point in a non-canonic numeric string - no RPARENMISSING
	new $estack
	kill a,^a
	set a(1234567890123456780)=1
	set a(123456789012345678.0)=1
	set a(123456789012345678.2)=1
	set a(1234567890123456782.3)=1
	set a(12345678901234567824.3)=1
	set a(12345678901234567824.345)=1
	set ^a(1234567890123456780)=1
	set ^a(123456789012345678.0)=1
	set ^a(123456789012345678.2)=1
	set ^a(1234567890123456782.3)=1
	set ^a(12345678901234567824.3)=1
	set ^a(12345678901234567824.345)=1
	quit
t5	; check that zwrite preserves stringiness of non-canonic numeric
	kill a,^a
	set (a("97E12345",1),^a("97E12345",1))=1
	zwrite a("97E12345",1)
	zwrite ^a("97E12345",1)
	write a("97E12345",1),!
	write ^a("97E12345",1),!
	quit
t6	; check that $data(), $increment(), $name() and $qsubscript() maintain the stringiness of non-canonic numeric strings
	new $estack
	kill a,x,^a
	set x="",$p(x,"9",60)=""
	set a("1111111111111111111111111111111111")=-1
	if $increment(a("1111111111111111111111111111111111")),$increment(cnt) xecute act
	kill a
	if $increment(a(x)),1'=a(x),$increment(cnt) xecute act
	if '$data(a(x)),$increment(cnt) xecute act
	kill a
	set a("1111111111111111111111111111111111")=1
	set x=$order(a(""))
	if '$data(a(x)),$increment(cnt) xecute act
	set a=$name(a(x))
	if '$data(@a),$increment(cnt) xecute act
	kill a,x,^a
	set x="",$p(x,"9",60)=""
	set ^a("1111111111111111111111111111111111")=-1
	if $increment(^a("1111111111111111111111111111111111")),$increment(cnt) xecute act
	kill ^a
	if $increment(^a(x)),1'=^a(x),$increment(cnt) xecute act
	if '$data(^a(x)),$increment(cnt) xecute act
	kill ^a
	set ^a("1111111111111111111111111111111111")=1
	set x=$order(^a(""))
	if '$data(^a(x)),$increment(cnt) xecute act
	set a=$name(^a(x))
	if '$data(@a),$increment(cnt) xecute act
	kill a,x,^a
	set a("1111111111111111111111111111111111")=1
	set x=$order(a(""))
	set a=$name(a(x))
	if '$data(@a),$increment(cnt) xecute act
	kill x
	set x=$query(@"a")
	set a=$qsubscript(x,1)
	if '$data(a(a)),$increment(cnt) xecute act
	kill a,x,^a
	set ^a("1111111111111111111111111111111111")=1
	set x=$order(^a(""))
	set a=$name(^a(x))
	if '$data(@a),$increment(cnt) xecute act
	kill x
	set x=$query(@"^a")
	set a=$qsubscript(x,1)
	if '$data(^a(a)),$increment(cnt) xecute act
	quit
t7	; check that trailing decimals with no non-zero fraction are treated as string subscripts
	new $estack
	kill a,x,^a
	set a("123")="1"
	set a("123.")="2"
	set a("123.0")="3"
	set x=""
	for i=1:1:3 set x=$order(a(x)) if i'=$get(a(x)),$increment(cnt) xecute act
	kill a
	set ^a("123")="1"
	set ^a("123.")="2"
	set ^a("123.0")="3"
	set x=""
	for i=1:1:3 set x=$order(^a(x)) if i'=$get(^a(x)),$increment(cnt) xecute act
	kill i
	quit
t8	; check that merge works for both local->global and global->local - S9D06-002331
	new $estack
	kill a,x,^a
	set a(1000000000000000000000000000000)=1
	set a($C(0))=2
	set a("1000000000000000000000000000023")=3
	set x=""
	for i=1:1:3 s x=$order(a(x)) if i'=$get(a(x)),$increment(cnt) xecute act
	merge ^a=a
	set x=""
	for i=1:1:3 s x=$order(^a(x)) if i'=$get(^a(x)),$increment(cnt) xecute act
	kill a,x,^a
	set ^a(1000000000000000000000000000000)=1
	set ^a($C(0))=2
	set ^a("1000000000000000000000000000023")=3
	set x=""
	for i=1:1:3 s x=$order(^a(x)) if i'=$get(^a(x)),$increment(cnt) xecute act
	merge a=^a
	set x=""
	for i=1:1:3 s x=$order(a(x)) if i'=$get(a(x)),$increment(cnt) xecute act
	quit
t9	; check the numeric range for consistent behavior - C9905-001087
	new $estack
	set minexp=43,maxexp=47,bigex=maxexp-maxdigits
	k a,i,x
	for i=1:1:(minexp+1) set x=("1E-"_i) if 0'<x set lrange=i-1 write !,"Max. Neg. Exp.: ",lrange quit
	i minexp'=lrange,$increment(cnt) xecute act
	set smallex="1E-"_(lrange-1),a="9E-"_(lrange-1)
	for i=smallex:smallex set x=a-i if 0'<x do:i'=+a  quit
	. if $increment(cnt) write !,"Min - i underflowed at i=",i xecute act
	for i=-smallex:-smallex set x=a+i if 0'<x do:i'=-a  quit
	. if $increment(cnt) write !,"Min + (-i) underflowed at i=",i xecute act
	set a=1
	for i=1:1:minexp set x=a*("1E-"_i) if 0'<x do:lrange+1'=i  quit
	. if $increment(cnt) write !,"Min * 1E-i underflowed at i=",i xecute act
	for i=1:1:maxexp set x=a/("1E"_i) if 0'<x do:lrange+1'=i  quit
	. if $increment(cnt) write !,"Min / 1Ei underflowed at i=",i xecute act
	for i=1:1:maxexp-1 set x=a\("1E"_i) if 0'=x do:lrange+1'=i  quit
	. if $increment(cnt) write !,"Min \ 1Ei underflowed at i=",i xecute act
	for i=1:1:maxexp-1 set x=a#("1E"_i) if 0'<x do:lrange+1'=i  quit
	. if $increment(cnt) write !,"Min \ 1Ei underflowed at i=",i xecute act
	for i=i:1:maxexp set x=("1E"_i)
	set a="",$p(a,9,maxdigits-1)="",a="9."_a_"8E"_(maxexp-1),a=+a
	set expect="NUMOFLOW"
	set i=maxexp set x=a\("1E"_i) if (0'=x),$increment(cnt) xecute act
	set i=maxexp set x=a#("1E"_i) if (0'=x),$increment(cnt) xecute act
	for i="1E"_bigex:"1E"_bigex:"2E"_bigex set x=a+i if i=+("2E"_bigex),$increment(cnt) xecute act
	for i=-"1E"_bigex:-"1E"_bigex:-"2E"_bigex set x=a-i if i=-("2E"_bigex),$increment(cnt) xecute act
	set a=$translate(a,8,9)
	for i=1:1:2 set x=a*i if 2=i,$increment(cnt) write !,"Max * 2 did not overflow" xecute act
	for i=1:-.1:.9 set x=a/i if .9=i,$increment(cnt) write !,"Max /.9 did not overflow" xecute act
	for i=1:-.1:.9 set x=a\i if .9=i,$increment(cnt) write !,"Max \.9 did not overflow" xecute act
	quit
err	if $estack write:'$stack !,"error handling failed",$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
