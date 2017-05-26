C9B04001673d	;demonstrate $view() and compiler warnings for boolean side-effects
  ;
  write !,$view("full_boolean")
  quit
  kill ^b
  set d=$i(^b)!^b
  set d=$i(^b,-1)&^b
  set d=^b!$i(^b)
  set d=^b&$i(^b,-1)
  set d=$$ef(^b)!^b
  set d=$$ef(^b)&^b
  set d=^b!$$ef(^b)
  set d=^b&$$ef(^b)
  set d=$&ec(^b)!^b
  set d=$&ec(^b)&^b
  set d=^b!$&ec(^b)
  set d=^b&$&ec(^b)
  set d=(1<$i(^b))!^b&$&ec(^b)
  set d=(1]]$&ec(^b))&$$ef(^b)!^b
  set d=^b&$&ec(^b)&(1<$i(^b))
  set d=$$ef(^b)!^b!(1]]$&ec(^b))
  set d=(1<$i(^b))
  set d=(1=$$ef(^b))
  set d=(1>$&ec(^b))
  set d=(1[$i(b))
  set d=(1]$$ef(^b))
  set d=(1]]$&ec(^b))
  set d=d<$$ef(^b=b)
  set d=d<$$ef(^b&b)
  quit
ef(x) 
  set b=$i(x,^c) 
  quit b