D9804000754 ; Verify $RANDOM() doesn't fail for large values
  ;
  new (act)
  if '$data(act) new act set act="if $increment(cnt) write !,i,!,$status"
  set $ecode="",$etrap="goto end"
  for i=2:1:64 set x=$random(2**i-1)
end
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
  quit
  