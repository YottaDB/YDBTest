gtm6957	; Check $ZTRNLNM() keyword handling
  ;
  new (act)
  if '$data(act) new act set act="write ! zprint @$zposition write $zstatus,! zwrite"
  new $etrap
  set $ecode="",$etrap="write !,""FAIL from "",$text(+0),!,$zstatus,! zprint @$zposition"
  for ev="foo","bar","sailor" do
 . for kw="ACCESS_MODE","CONCEALED","CONFINE","FULL","LENGTH","MAX_INDEX","NO_ALIAS","TABLE","TABLE_NAME","TERMINAL","VALUE","" do
 .. for case="U","L" set r=$ztrnlnm(ev,,,,,$zconvert(kw,case)) do
 ... if "FULL"=kw!("VALUE"=kw)!(""=kw) do  quit
 .... if $select("foo"=ev:"bar",1:"")'=r,$increment(cnt) xecute act
 ... if "LENGTH"=kw do  quit
 .... if $select("foo"=ev:3,"bar"=ev:"",1:0)'=r,$increment(cnt) xecute act
 ... if "NO_ALIAS"=kw do  quit
 .... if 1'=r,$increment(cnt) xecute act
 ... if "TABLE_NAME"=kw do  quit
 .... if ""'=r,$increment(cnt) xecute act
 ... if "TERMINAL"=kw do  quit
 .... if $select("bar"'=ev:1,1:0)'=r,$increment(cnt) xecute act
 ... if $select("bar"'=ev:0,1:"")'=r,$increment(cnt) xecute act
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
  quit
