C9K04003264	; test that UNICODEish $Z*() routines work on VMS
  ;
  new (act)
  if '$data(act) new act set act="write !,$zstatus,! zprint $zposition"
  new $etrap
  set $ecode="",$etrap="write !,""FAIL from "",$text(+0),!,$zstatus,! zprint @$zposition"
  if $zascii("ABCD",2)'=$ascii("ABCD",2),$increment(cnt) xecute act
  if $zchar(65,66)'=$char(65,66),$increment(cnt) xecute act
  ;if $zconvert("ABCD","l")'="abcd",$increment(cnt) xecute act ; Wait for this to be supported in VMS
  if $zextract("ABCD",2,3)'=$extract("ABCD",2,3),$increment(cnt) xecute act
  if $zfind("ABCD","B")'=$FIND("ABCD","B"),$increment(cnt) xecute act
  if $zlength("ABCD")'=$length("ABCD"),$increment(cnt) xecute act
  if $zlength("ABCD","B")'=$length("ABCD","B"),$increment(cnt) xecute act
  if $zpiece("ABCD","B",2)'=$piece("ABCD","B",2),$increment(cnt) xecute act
  if $zsubstr("ABCD",2,2)'=$extract("ABCD",2,3),$increment(cnt) xecute act
  if $ztranslate("ABCD","B",2)'=$translate("ABCD","B",2),$increment(cnt) xecute act
  if $zwidth($char(1)_"ABCD")'=$length("ABCD"),$increment(cnt) xecute act
  if $zjustify("ABCD",10)'=$justify("ABCD",10),$increment(cnt) xecute act
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
  quit
