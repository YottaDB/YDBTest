; Trigger collation test driver. 
; 
; Sets a range of alphabetic subscripts in a global which drives further updates via trigger.
; Collation of the subscripts verified by ZWrite output.

  Set alphas="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  For i=1:1:$Length(alphas) Set ^i=i,c=$Extract(alphas,^i),^collrange(c)=^i
  ZWrite ^collrange,^range
  Quit
