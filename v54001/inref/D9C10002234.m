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
D9C10002234	; $QLENGTH() and $QSUBSCRIPT() should accept $CHAR() in subscripts
  ;
  new (act)
  if '$data(act) new act set act="write !,val,!,$zstatus,!"
  new $etrap
  set $ecode="",$etrap="write !,""FAIL from "",$text(+0),!,$zstatus,! zprint @$zposition"
  set top=$zlevel
  kill ^a
  for i=0:1:127 set y="$"_$select(0=(i#4):"c",0=(i#3):"C",0=(i#2):"char",1:"CHAR")_"(" do
  . if '(i#29) set x="^a("
  . set w=$length(x),k=1
  . for j=i:1:i+k quit:127<j  set z=$length(y) quit:w+z>240&(","=$extract(y,z))  set y=y_j_","
  . set k=k+1#7,$extract(y,$length(y))=")",x=x_y_")",@x=i,$extract(x,$length(x))=","
  set x="^a("
  for i=.0001:1.1:25 set x=x_i_","
  set $extract(x,$length(x))=")",@x=i
  set ^a(""""_$c(8,9,10)_""";""")=8910
  merge a=^a
  set $etrap="goto err1"
  for x="^|""mumps.gld""|","" set val=$query(@(x_"a("""")")) for  quit:""=val  do
  . set l(val)=$qlength(val),y=$qsubscript(val,0)_"("
  . for i=1:1:l(val) do
  . . set t=$qsubscript(val,i)
  . . set y=y_$zwrite(t)
  . . if '$data(@(y_")")),$increment(cnt) xecute act
  . . set y=y_","
  . set val=$query(@val)
  . quit
  set $etrap="goto err"
  if $increment(cnt,48)
  if $qlength(""),$increment(cnt) xecute act
  if $qlength("^|0.0|a(1)"),$increment(cnt) xecute act
  if $qlength("^|-0|a(1)"),$increment(cnt) xecute act
  if $qlength("^|00|a(1)"),$increment(cnt) xecute act
  if $qlength("^|01|a(1)"),$increment(cnt) xecute act
  if $qlength("^|0a(1)"),$increment(cnt) xecute act
  if $qlength("^|1.1.1|a(1)"),$increment(cnt) xecute act
  if $qlength("^|1,|a(1)"),$increment(cnt) xecute act
  if $qlength("^|,1|a(1)"),$increment(cnt) xecute act
  if $qlength("^|1-1|a(1)"),$increment(cnt) xecute act
  if $qlength("^[0.0]a(1)"),$increment(cnt) xecute act
  if $qlength("^[-0]a(1)"),$increment(cnt) xecute act
  if $qlength("^[00]a(1)"),$increment(cnt) xecute act
  if $qlength("^[01]a(1)"),$increment(cnt) xecute act
  if $qlength("^[0a(1)"),$increment(cnt) xecute act
  if $qlength("^[1.1.1]a(1)"),$increment(cnt) xecute act
  if $qlength("^[1,]a(1)"),$increment(cnt) xecute act
  if $qlength("^[,1]a(1)"),$increment(cnt) xecute act
  if $qlength("^[1-1]a(1)"),$increment(cnt) xecute act
  if $qlength("a(1.1.1)"),$increment(cnt) xecute act
  if $qlength("a(0.0)"),$increment(cnt) xecute act
  if $qlength("a(-0)"),$increment(cnt) xecute act
  if $qlength("a(1-1)"),$increment(cnt) xecute act
  if $qlength("a(1,)"),$increment(cnt) xecute act
  if $qlength("a(,1)"),$increment(cnt) xecute act
  if $qlength("a("),$increment(cnt) xecute act
  if $qlength("a)"),$increment(cnt) xecute act
  if $qlength("a(01)"),$increment(cnt) xecute act
  if $qlength("a(""a"".)"),$increment(cnt) xecute act
  if $qlength("a(,""a"")"),$increment(cnt) xecute act
  if $qlength("a($c(1)"),$increment(cnt) xecute act
  if $qlength("a($c))"),$increment(cnt) xecute act
  if $qlength("a($c))"),$increment(cnt) xecute act
  if $qlength("a($ch(1))"),$increment(cnt) xecute act
  if $qlength("a($cha(1))"),$increment(cnt) xecute act
  if $qlength("a($character(1))"),$increment(cnt) xecute act
  if $qlength("a(-.000000000000000000000000000001)"),$increment(cnt,-1)
  if $qlength("a($zc(1))"),$increment(cnt) xecute act
  if $qlength("a($zcha(1))"),$increment(cnt) xecute act
  if 0=$qlength("a"),$increment(cnt,-1)
  if "a"=$qsubscript("a",0),$increment(cnt,-1)
  if """a"=$qsubscript("^|""""""a"",5.5|b(""c"")",-1),$increment(cnt,-1)
  if "A"=$qsubscript("^|$C(65),""foo""|a(""bar"")",-1),$increment(cnt,-1)
  if "gbldir"=$qsubscript("^[""gbldir""]a(2)",-1),$increment(cnt,-1)
  if "0"=$qsubscript("a(0,1)",1),$increment(cnt,-1)
  if "0"=$qsubscript("a(2,0,1,3)",2),$increment(cnt,-1)
  if $c(26032)=$qsubscript("a($c(26032))",1),$increment(cnt,-1)
  set ^V(1,2,3)="V12345(11,22,33,44,55)",^V(1,2,2)=0,^V(1,2)=2
  set ^VCOMP=$qsubscript(^(2,3),^(2))_" "_^(2)
  if ^VCOMP="V12345 0",$increment(cnt,-1)
  if "UTF-8"=$zchset do badchar
end
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
  quit
badchar
  set cnt=cnt+2
  new $etrap
  set $etrap="goto err2"
  set badchar=$view("badchar"),bad=55296
  view "nobadchar"
  if $c(bad)=$qsubscript("a($c(55296))",1),$increment(cnt,-1)
  set @("b($zch(216,0))")="b",x=$query(b(""))
  xecute "if $zch(216,0)=$qsubscript(x,1),$increment(cnt,-1)"
  view "badchar"
  set c($c(26032,26032,26032))="utf-8"
  set x=$query(c("")),y=$qsubscript(x,1)
  if 3'=$length(y),$increment(cnt) xecute act
  xecute "if 9'=$zlength(y),$increment(cnt) xecute act"
  if $c(bad)=$qsubscript("a($c(55296))",1),$increment(cnt) xecute act
badc
  view $select(badchar:"",1:"no")_"badchar"
  quit
err1
  if $increment(cnt) xecute act if $zstatus["NOCANONICNAME" set val=$query(@val),$ecode=""
  quit
err2
  if $zstatus["INVDLRCVAL" set $ecode="",$zstatus="" goto badc
err
  set loc=$stack($stack,"PLACE"),next=$p(loc,"+")_"+"_($piece(loc,"+",2)+1)
  if $zstatus["NOCANONICNAME" set cnt=cnt-1
  else  set stat="\"_$piece($piece($zstatus,"-",3),",") if "\MAXNRSUBSCRIPTS"[stat xecute act
  else  set cnt=100,next="end" xecute act
  set $ecode=""
  goto @next
