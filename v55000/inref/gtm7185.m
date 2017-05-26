GTM7185 ; test for proper termination with subscripted local specification
  new (act)
  if '$data(act) new act set act="zshow ""SV"""
  set ^a(1)=1,^a(2)=2 for i=1:^a(1):^a(2) if $increment(^a(1)),$increment(^a(2),^a(1))>10 quit
  if i'=2,$increment(cnt) xecute act
  set a(1)=1,a(2)=2 for i=1:a(1):a(2) if $increment(a(1)),$increment(a(2),a(1))>10 quit
  if i'=2,$increment(cnt) xecute act
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
  quit