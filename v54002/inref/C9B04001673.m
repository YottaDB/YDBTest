C9B04001673	; drive boolean test
  ;
  view "nofull_boolean"
  zlink "C9B04001673a.m"
  do ^C9B04001673a
  zlink "C9B04001673b.m"
  do ^C9B04001673b
  view "full_boolean"
  zlink "C9B04001673a.m"
  do ^C9B04001673a
  zlink "C9B04001673c.m"
  do ^C9B04001673c
  quit
d
  view "full_boolwarn"
  zlink "C9B04001673d.m"
  quit