D9D10002376 ; check for NOLVNULLSUBS detection
  ;
  new (act)
  if '$d(act) new act set act="write !,loc,! zprint @loc write !"
  set cnt=0,a(42)="" ; Need a to have something in it so don't get shortcut code that doesn't check stuff in op_fnquery
  new $etrap
  set $etrap="goto error"
  set lvnull=$VIEW("LVNULLSUBS")
  set act2="set cnt($stack($stack-1,""PLACE""))=$stack($stack-1,""MCODE"")"
  write !,"LVNULLSUBS is ",$select(2=lvnull:"NEVER",1=lvnull:"ALWAYS",1:"EXIST")
  set cnt=cnt+$select(2=lvnull:8,1=lvnull:-8,1:-6),act1=$select(2=lvnull:act2,1:"set cnt=cnt+1")
  set x=$order(a("")),x=$order(a(1,"")),x=$query(a("")),x=$query(a(1,"")) ; should all work
  set x=$order(a("",1)) x act1
  set x=$query(a("",1)) x act1
  set x=$data(a("",1)) x act1
  set x=$get(a("",1)) x act1
  set a("",1)=1 x $select(0=lvnull:act2,1:act1)
  kill a("",1) x act1
  zkill a("",1) x act1
  merge x=a("",1) x act1
end  write !,$select('cnt:"PASS",1:"FAIL")," from ",$text(+0),!
  if cnt zwrite cnt
  quit
error
  set loc=$stack($stack,"PLACE")
  if $zstatus[$select(1=lvnull:"UNDEF",1:"LVNULLSUBS") set cnt=cnt-1,next=$p(loc,"+")_"+"_($piece(loc,"+",2)+1)
  else  set cnt=9,next="end" xecute act2,act
  set $ecode=""
  goto @next
