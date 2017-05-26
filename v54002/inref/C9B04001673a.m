;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9B04001673a ; test boolean side-effect behavior for $r and evidence of what ran
  ;
  new (act)
  if '$data(act) new act d
  . set act="s l=$st($st,""place"")'[""^"" w !,a,?2,$d(b)!$d(^b),?4,$g(c),?7,$g(d),?9,$g(i),?12,$g(r),?25,$st($st-l,""place""),!,$st($st-l,""mcode"")"
  new $etrap
  set $ecode="",$etrap="goto err",zl=$zl
  kill ^a,^b,^c
  set (bz,c,c(1),^c,^c(1),^c(1,1),c0,^a(1,2,1),^bz)=1,type=$select($view("full_boolean")'["short":"full",1:"nofull")
  ; this first section tests the behavior of $REFERENCE (and by inference the naked reference) for some functions that deal
  ; specifically with indirection - these are the ones easy to test because they have single argument forms but all of them
  ; use similar techniques
  for a=0,1 do
  . for b=0,1 set ^b=b do
  .. if ^c set d='(a!$$comp(^b)),r=$reference if r'="^b"!(d'='(a!'^b)),$increment(cnt) xecute act
  .. if ^c set d='(a&$$comp(^b)),r=$reference if r'="^b"!(d'='(a&'^b)),$increment(cnt) xecute act
  .. set d=0 if ^c,'(a!$$comp(^b)) set d=1
  .. set r=$reference if r'="^b"!(d'='(a!'^b)),$increment(cnt) xecute act
  .. set d=0 if ^c,'(a&$$comp(^b)) set d=1
  .. set r=$reference if r'="^b"!(d'='(a&'^b)),$increment(cnt) xecute act
  .. if ^c set d=(a&'a&b)!($$comp(^b)),r=$reference if r'="^b"!(d=b),$increment(cnt) xecute act
  .. if ^c set d=(a!'a!b)&($$comp(^b)),r=$reference if r'="^b"!(d=b),$increment(cnt) xecute act
  .. set d=0 if ^c,(a&'a&b)!($$comp(^b)) set d=1
  .. set r=$reference if r'="^b"!(d=b),$increment(cnt) xecute act
  .. set d=0 if ^c,(a!'a!b)&($$comp(^b)) set d=1
  .. set r=$reference if r'="^b"!(d=b),$increment(cnt) xecute act
  .. set d=0 if (a&a&^b)!($$one) set d=1
  .. set r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  .. set d=1 if (a!a!^b)&($$zero) set d=0
  .. set r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  .. set ^c(a)=a,^c('a)='a,b="^c"
  .. set d=1 if @b@(a)&@b@(0)&@b@(^b) set d=0
  .. set r=$reference if r'=("^c("_^b_")")!'d,$increment(cnt) xecute act
  .. set d=0 if @b@(a)!@b@(1)!@b@(^b) set d=1
  .. set r=$reference if r'=("^c("_^b_")")!'d,$increment(cnt) xecute act
  .. for i=0:1:3 do
  ... set d=1 if '(@b@(i\2)!@b@(i#2)) set d=0
  ... if 'i=d,$increment(cnt) xecute act
  . for b="c","^c" set ^b=b do
  .. set ^a(1,2)=1,d=a!$data(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$data(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!$data(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$data(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!$get(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$get(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!$get(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$get(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!($name(@b)=b),r=$reference if r'="^a(1,2)"!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&($name(@b)=b),r=$reference if r'="^a(1,2)"!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!($name(@^b)=b),r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&($name(@^b)=b),r=$reference if r'="^b"!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!($order(@b)="c0"),r=$reference if r'=$select("^c"=b:"",1:"^a(1,2)")!(d'=("c"=b!a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a&($order(@b)="c0"),r=$reference if r'=$select("^c"=b:"",1:"^a(1,2)")!(d'=("c"=b&a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a!($order(@^b)="c0"),r=$reference if r'=$select("^c"=b:"",1:"^b")!(d'=("c"=b!a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a&($order(@^b)="c0"),r=$reference if r'=$select("^c"=b:"",1:"^b")!(d'=("c"=b&a)),$increment(cnt) x act
  .. ; the following $QUERY() section shows behavior that does not appear to meet the standard for $REFERENCE maintenance
  .. set ^a(1,2)=1,d=a!($query(@b)="c(1)"),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!(d'=("c"=b!a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a&($query(@b)="c(1)"),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!(d'=("c"=b&a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a!($query(@^b)="c(1)"),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!(d'=("c"=b!a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a&($query(@^b)="c(1)"),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!(d'=("c"=b&a)),$increment(cnt) x act
  .. if "c"=b do
  ... set ^a(1,2)=1,d=a!$length($zahandle(@b)),r=$reference if r'="^a(1,2)"!'d,$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a&$length($zahandle(@b)),r=$reference if r'="^a(1,2)"!(d'=a),$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a!$length($zahandle(@^b)),r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a&$length($zahandle(@^b)),r=$reference if r'="^b"!(d'=a),$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 set:a!$length($zahandle(@b)) d=1 set r=$reference if r'="^a(1,2)"!'d,$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 set:a&$length($zahandle(@b)) d=1 set r=$reference if r'="^a(1,2)"!(d'=a),$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 set:a!$length($zahandle(@^b)) d=1 set r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 set:a&$length($zahandle(@^b)) d=1 set r=$reference if r'="^b"!(d'=a),$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 if a!$length($zahandle(@b)) set d=1
  ... set r=$reference if r'="^a(1,2)"!'d,$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 if a&$length($zahandle(@b)) set d=1
  ... set r=$reference if r'="^a(1,2)"!(d'=a),$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 if a!$length($zahandle(@^b)) set d=1
  ... set r=$reference if r'="^b"!'d,$increment(cnt) xecute act
  ... set d=0,^a(1,2)=1 if a&$length($zahandle(@^b)) set d=1
  ... set r=$reference if r'="^b"!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!$zdata(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$zdata(@b),r=$reference if r'=$select("^c"=b:"^c",1:"^a(1,2)")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!$zdata(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!'d,$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&$zdata(@^b),r=$reference if r'=$select("^c"=b:"^c",1:"^b")!(d'=a),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a!($zprevious(@b)="bz"),r=$reference if r'=$select("^c"=b:"",1:"^a(1,2)")!(d'=("c"=b!a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a&($zprevious(@b)="bz"),r=$reference if r'=$select("^c"=b:"",1:"^a(1,2)")!(d'=("c"=b&a)),$increment(cnt) x act
  .. set ^a(1,2)=1,d=a!($zprevious(@^b)="bz"),r=$reference if r'=$select("^c"=b:"",1:"^b")!(d'=("c"=b!a)),$increment(cnt) xecute act
  .. set ^a(1,2)=1,d=a&($zprevious(@^b)="bz"),r=$reference if r'=$select("^c"=b:"",1:"^b")!(d'=("c"=b&a)),$increment(cnt) xecute act
  .. if "^c"=b do
  ... set ^a(1,2)=1,d=a!$zqgblmod(@b),r=$reference if r'="^c"!'d,$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a&$zqgblmod(@b),r=$reference if r'="^c"!(d'=a),$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a!$zqgblmod(@^b),r=$reference if r'="^c"!'d,$increment(cnt) xecute act
  ... set ^a(1,2)=1,d=a&$zqgblmod(@^b),r=$reference if r'="^c"!(d'=a),$increment(cnt) xecute act
  ; the following section tests intermixing of other operators with booleam combinations
  set i="@^a",^a="1N",y=(type="full")
  for a=0,1 do
  . for b="c","^c" set ^b=b do
  .. set rexpect2=$select((b="c"):"^b",1:"^c"),rexpect=$select((type'="full"):"^dummy",1:rexpect2)
  .. set rexpect3=$select((type="full")&'a&(b'="^c"):"^b",1:"^c")
  .. set b=1,d=(@^b[1)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b[1)!$select(a:$$one(.b),1:$$zero(.b),1:^dummy),r=$reference if (r'=rexpect)!'d!b,$i(cnt) x act
  .. kill uu set b=1,bb="a",d=(@^b[1)!$select(a:@bb,1:$incr(uu)),r=$reference if (r'=rexpect2)!'d!'b!($data(uu)=a),$i(cnt) x act
  .. set b=1,bb="^c",d=(@^b[1)!$select(a:@bb,1:0),r=$reference if (r'=rexpect3)!'d!'b,$i(cnt) x act
  .. set b=1,d=(@^b[1)!$select(a:1,1:0,1:$incr(dummy)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!($get(dummy)),$i(cnt) x act
  .. set b=1,d=(@^b[1)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b[1)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b[1)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d='''(@^b[1)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d='''(@^b[1)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d='''(@^b[1)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d='''(@^b[1)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b[1)!'''$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b[1)&'''$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b[1)'!'''$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b[1)'&'''$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b=1)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b=1)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b=1)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b=1)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b]0)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b]0)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b]0)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b]0)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b="1")!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b="1")&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b="1")'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b="1")'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b?1N)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b?1N)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b?1N)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b?1N)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b?@i)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'="^a"!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b?@i)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'="^a"!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b?@i)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'="^a"!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b?@i)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'="^a"!(d=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b]]0)!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b]]0)&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=(@^b]]0)'!$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!(b=y),$i(cnt) x act
  .. set b=1,d=(@^b]]0)'&$select(a:$$one(.b),1:$$zero(.b)),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b[1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b[1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b[1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b[1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b=1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b=1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b=1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b=1),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b="1"),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b="1"),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b="1"),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b="1"),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b?1N),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b?1N),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b?1N),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b?1N),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))!(@^b]]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!'d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))&(@^b]]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d'=a)!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'!(@^b]]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!d!b,$i(cnt) x act
  .. set b=1,d=$select(a:$$one(.b),1:$$zero(.b))'&(@^b]]0),r=$reference if r'=$select("^c"=^b:"^c",1:"^b")!(d=a)!b,$i(cnt) x act
  .. set b='a if @"a"&(@"^b"&@"b"),$increment(cnt) x act
  .. set b='a if @"a"&(@"b"&@"^b"),$increment(cnt) x act
  .. set b='a if @"a"&(@"^b"&@"b")!1
  .. else  if $increment(cnt) x act
  .. set b='a if @"a"&(@"b"&@"^b")!1
  .. else  if $increment(cnt) x act
   if "full"=type for a=0,1 do
  . set c=a if (c!(0&$$zero(.c))),c,$increment(cnt) xecute act
  . set c=a if (c&(1!$$zero(.c))),c,$increment(cnt) xecute act
  . set c=a,d=(c!(0&$$zero(.c))) if d=c,$increment(cnt) xecute act
  . set c=a,d=(c&(1!$$zero(.c))) if d=c,$increment(cnt) xecute act
  . if $select(2=$get(^c(3)):0,1:c=$get(^c(2))),$increment(cnt) xecute act
  . if ($$extrin(.b)<0)!(($$extrin(.b)=1)!($$extrin(.b)'=3)),$increment(cnt) xecute act
  . ; the next section tests the use of $test in booleans, requiring a funky structure so it has the intended value
  . if a do
  .. do
  ... set b=1,d=$test!$$one(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$one(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test!$$zero(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$zero(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)&$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)&$test if d!b,$increment(cnt) xecute act
  . else  do
  .. do
  ... set b=1,d=$test!$$one(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$one(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test!$$zero(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$zero(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)&$test if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)!$test if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)&$test if d!b,$increment(cnt) xecute act
  . set b=a,d=a!$$zero(.b)=1 if (d'=a)!(b=a),$increment(cnt) xecute act
  . set b=a,^b=1,d=a!$$extrin(.b),r=$reference if r'="^c"!'d!(b-1'=a),$increment(cnt) xecute act
  . set b=a,^b=1,d=a&$$extrin(.b),r=$reference if r'="^c"!(d'=a)!(b-1'=a),$increment(cnt) xecute act
  . set b=a,d='b!$increment(b,b) if 'd!(2*a'=b),$increment(cnt) xecute act
  . set b=a,d='b&$increment(b,b) if d!(2*a'=b),$increment(cnt) xecute act
  . set b=a,d=a!(1+$$one(.b)) if 'd!(b=a),$increment(cnt) xecute act
  . set b=a,d=a&(1+$$one(.b)) if (d'=a)!(b=a),$increment(cnt) xecute act
  . set b=a,d=(b!$$one(.b))&(a=b) if d!(b=a),$increment(cnt) xecute act
  . set b=a,d=(b&$$one(.b))&(a=b) if d!(b=a),$increment(cnt) xecute act
  . set b=a,d=(b!$$zero(.b))&(a=b) if d!(b=a),$increment(cnt) xecute act
  . set b=a,d=(b&$$zero(.b))&(a=b) if d!(b=a),$increment(cnt) xecute act
  . set b=a,d=b!$$one(.b)&$$one(.b) if 'd!(b'=a),$increment(cnt) xecute act
  . set b=a,d=b&$$one(.b)&$$one(.b) if (d'=a)!(b'=a),$increment(cnt) xecute act
  . set b=a,d=b!$$zero(.b)&$$one(.b) if (d'=a)!(b'=a),$increment(cnt) xecute act
  . set b=a,d=b&$$zero(.b)&$$one(.b) if d!(b'=a),$increment(cnt) xecute act
  . kill b,^b set ^a(1,2)=1,d=a!$$extrin(.b),r=$reference if r'="^c"!(1'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$$extrin($increment(b,^a(1,2))),r=$reference if r'="^c"!(1'=$d(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$$extring,r=$reference if r'="^b",$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extrin(.b),r=$reference if r'="^c"!(1'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extrin($increment(b,^a(1,2))),r=$reference if r'="^c"!(1'=$d(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extring,r=$reference if r'="^b",$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$increment(b,^c),r=$reference if r'="^c"!(1'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$increment(^b,^c),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$increment(b,^c),r=$reference if r'="^c"!(1'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$increment(^b,^c),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  . kill b,^b set (a,^c)=1,^a(1,2)=1,d='a&$increment(^b,^c),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  . ; from here to the next for are tests of which some won't pass in earlier verisons
  . set b=a,d='b!$$one(.b) if 'd!(b=a),$increment(cnt) xecute act
  . set b=a,d='b&$$one(.b) if (d=a)!(b=a),$increment(cnt) xecute act
  . set b=a,d='b!$$zero(.b) if (d=a)!(b=a),$increment(cnt) xecute act
  . set b=a,d='b&$$zero(.b) if d!(b=a),$increment(cnt) xecute act
  . set b=a,d=b!$find($$one(.b),1) if 'd!(b=a),$increment(cnt) xecute act
  . set b=a,d=b&$find($$one(.b),1) if (d'=a)!(b=a),$increment(cnt) xecute act
  . set b=a,(^a(1,2),li(2),li(1))=1,d=b!$i(b($i(l(b),li($$extrin(.b)))),b),r=$reference if r'="^c"!(d'=a)!(a+1'=b),$i(cnt) x act
  . set b=a,(^a(1,2),li(2),li(1))=1,d=b&$i(b($i(l(b),li($$extrin(.b)))),b),r=$reference if r'="^c"!'d!(a+1'=b),$i(cnt) x act
  . for i="c","^c" d
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(b,@i),r=$reference if r'=$select("c"=i:"^a(1,2)",1:"^c")!(1'=$data(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(^b,@i),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(b,@i),r=$reference if r'=$select("c"=i:"^a(1,2)",1:"^c")!(1'=$data(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(^b,@i),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(b,@i@(1)),r=$reference if r'=$s("c"=i:"^a(1,2)",1:"^c(1)")!(1'=$d(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(^b,@i@(1)),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(b,@i@(1)),r=$reference if r'=$s("c"=i:"^a(1,2)",1:"^c(1)")!(1'=$d(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(^b,@i@(1)),r=$reference if r'="^b"!(1'=$data(^b)),$increment(cnt) x act
  .. quit
  . for c="b","^b" do
  .. set i="",^b=1
  .. set (b,^a)=a,d=a!$$one(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!(a=b)!'d,$increment(cnt) xecute act
  .. set (b,^a)=a,d=a!$$zero(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!(a=b)!'d,$increment(cnt) xecute act
  .. set (b,^a)=a,d=a&$$one(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!(a=b)!'d,$increment(cnt) xecute act
  .. set (b,^a)=a,d=a&$$zero(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!(a=b)!(d=a&("b"=c)),$increment(cnt) xecute act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(@c,^c),r=$reference if r'=$select("b"=c:"^c",1:"^b")!(1'=$d(@c))!'d,$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(@c,^c),r=$reference if r'=$select("b"=c:"^c",1:"^b")!(1'=$d(@c))!(d'=a),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(@c@(1),^c),r=$r if r'=$s("b"=c:"^c",1:"^b(1)")!(1'=$d(@c@(1)))!'d,$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(@c@(1),^c),r=$r if r'=$s("b"=c:"^c",1:"^b(1)")!(1'=$d(@c@(1)))!(d'=a),$i(cnt) x act
  .. for i="c","^c" d
  ... kill b,^b set ^a(1,2)=1,d=a!$i(@c,@i),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)",1:"^c")!(1'=$data(@c)),$i(cnt) x act
  ... kill b,^b set ^a(1,2)=1,d=a&$i(@c,@i),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)",1:"^c")!(1'=$data(@c)),$i(cnt) x act
  ... kill b,^b set ^a(1,2)=1,d=a!$i(@c,@i@(1)),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)",1:"^c(1)")!(1'=$data(@c)),$i(cnt) x act
  ... kill b,^b set ^a(1,2)=1,d=a&$i(@c,@i@(1)),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)",1:"^c(1)")!(1'=$data(@c)),$i(cnt) x act
  ... kill b,^b set ^a(1,2)=1,d=a!$i(@c,@i@($$c)),r=$r if r'=$s(("b"=c)&("^c"=i):"^c(1)",1:"^b")!(1'=$data(@c))!'d,$i(cnt) x act
  ... kill b,^b set ^a(1,2)=1,d=a&$i(@c,@i@($$c)),r=$r if r'=$s(("b"=c)&("^c"=i):"^c(1)",1:"^b")!(1'=$data(@c))!(d'=a),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c@(1),@i),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)",1:"^c")!(1'=$d(@c@(1)))!(d'=(a!("^c"=i))),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c@(1),@i),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)",1:"^c")!(1'=$d(@c@(1)))!(d'=(a!("^c"=i))),$i(cnt) x act
  ... k b,^b set ^a(1,2)=1,d=a!$i(@c@(1),@i@(1)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)",1:"^c(1)")!(1'=$d(@c@(1)))!'d,$i(cnt) x act
  ... k b,^b set ^a(1,2)=1,d=a&$i(@c@(1),@i@(1)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)",1:"^c(1)")!(1'=$d(@c@(1)))!(d'=a),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c@(1),@i@($$c)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^b",1:"^c(1)")!(1'=$d(@c@(1)))!'d,$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a&$i(@c@(1),@i@($$c)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^b",1:"^c(1)")!(1'=$d(@c@(1)))!(d'=a),$i(cnt) x act
   ... quit
  .. quit
  . quit
  else  set type="short-circuit" for a=0,1 do
  . ; the next section tests the use of $test in booleans, requiring a funky structure so it has the intended value
  . if a do
  .. do
  ... set b=1,d=$test!$$one(.b) if 'd!'b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$one(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test!$$zero(.b) if 'd!'b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$zero(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)&$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)&$test if d!b,$increment(cnt) xecute act
  . else  do
  .. do
  ... set b=1,d=$test!$$one(.b) if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$one(.b) if d!'b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test!$$zero(.b) if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$test&$$zero(.b) if d!'b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)!$test if 'd!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$one(.b)&$test if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)!$test if d!b,$increment(cnt) xecute act
  .. do
  ... set b=1,d=$$zero(.b)&$test if d!b,$increment(cnt) xecute act
  . set b=a,d=a!$$zero(.b)=1 if (d'=a)!'b,$increment(cnt) xecute act
  . set b=a,^b=1,d=a!$$extrin(.b),r=$reference if r'=$select('a:"^c",1:"^b")!'d!'b,$increment(cnt) xecute act
  . set b=a,^b=1,d=a&$$extrin(.b),r=$reference if r'=$select(a:"^c",1:"^b")!(d'=a)!(2*a'=b),$increment(cnt) xecute act
  . set b=a,d='b!$increment(b,b) if 'd!(2*a'=b),$increment(cnt) xecute act
  . set b=a,d='b&$increment(b,b) if d!(a'=b),$increment(cnt) xecute act
  . set b=a,d=a!(1+$$one(.b)) if 'd!'b,$increment(cnt) xecute act
  . set b=a,d=a&(1+$$one(.b)) if (d'=a)!b,$increment(cnt) xecute act
  . set b=a,d=(b!$$one(.b))&(a=b) if (d'=a)!'b,$increment(cnt) xecute act
  . set b=a,d=(b&$$one(.b))&(a=b) if d!b,$increment(cnt) xecute act
  . set b=a,d=(b!$$zero(.b))&(a=b) if (d'=a)!'b,$increment(cnt) xecute act
  . set b=a,d=(b&$$zero(.b))&(a=b) if d!b,$increment(cnt) xecute act
  . set b=a,d=b!$$one(.b)&$$one(.b) if 'd!b,$increment(cnt) xecute act
  . set b=a,d=b&$$one(.b)&$$one(.b) if (d'=a)!(b'=a),$increment(cnt) xecute act
  . set b=a,d=b!$$zero(.b)&$$one(.b) if (d'=a)!(b=a),$increment(cnt) xecute act
  . set b=a,d=b&$$zero(.b)&$$one(.b) if d!b,$increment(cnt) xecute act
  . set b=a if (($$extrin(.b)<0)&($$extrin(.b)=1)!($$extrin(.b)'=3))&(2'=b),$increment(cnt) xecute act
  . kill b,^b set ^a(1,2)=1,d=a!$$extrin(.b),r=$reference if r'=$select(a:"^a(1,2)",1:"^c")!(a=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$$extrin($increment(b,^c(1))),r=$reference if r'="^c(1)"!(a=$d(b)),$i(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$$extring,r=$reference if r'=$select(a:"^a(1,2)",1:"^b"),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extrin(.b),r=$reference if r'=$select('a:"^a(1,2)",1:"^c")!(a'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extrin($increment(b,^c(1))),r=$reference if r'="^c(1)"!(a'=$d(b)),$i(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$$extring,r=$reference if r'=$select('a:"^a(1,2)",1:"^b"),$increment(cnt) x act
  . kill b set ^a(1,2)=1,d=a!$increment(b,^c),r=$reference if r'="^c"!(a=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$increment(^b,^c),r=$reference if r'="^b"!(a=$data(^b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a!$increment(^b,^(2)),r=$reference if r'="^b"!(a=$data(^b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$increment(b,^c),r=$reference if r'="^c"!(a'=$data(b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$increment(^b,^c),r=$reference if r'="^b"!(a'=$data(^b)),$increment(cnt) x act
  . kill b,^b set ^a(1,2)=1,d=a&$increment(^b,^(2)),r=$reference if r'="^b"!(a'=$data(^b)),$increment(cnt) x act
  . kill b,^b set (a,^c)=1,^a(1,2)=1,d='a&$increment(^b,^c),r=$reference if r'="^b"!(a=$data(^b)),$increment(cnt) x act
  . set b=a,d=b!$find($$one(.b),1) if 'd!'b,$increment(cnt) xecute act
  . set b=a,d=b&$find($$one(.b),1) if (d'=a)!b,$increment(cnt) xecute act
  . s b=a,(^a(1,2),li(2),li(1))=1,d=b!$i(b($i(l(b),li($$extrin(.b)))),b),r=$r if r'=$s(a:"^a(1,2)",1:"^c")!'d!'b,$i(cnt) x act
  . s b=a,(^a(1,2),li(2),li(1))=1,d=b&$i(b($i(l(b),li($$extrin(.b)))),b),r=$r if r'=$s('a:"^a(1,2)",1:"^c")!(d'=a)!(a*2'=b),$i(cnt) x act
  .for c="b","^b" do
  .. set ^b=1
  .. set (b,^a)=a,d=a!$$one(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!'b!'d,$increment(cnt)  xecute act
  .. set (b,^a)=a,d=a!$$zero(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!'b!(d'=(a!("^b"=c))),$increment(cnt) xecute act
  .. set (b,^a)=a,d=a&$$one(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!b!(d'=(a!("^b"=c))),$increment(cnt) xecute act
  .. set (b,^a)=a,d=a&$$zero(.b)!@c,r=$reference if r'=$select("b"=c:"^a",1:"^b")!b!(d'=(a!("^b"=c))),$increment(cnt) xecute act
  .. quit
  . for i="c","^c","^(2)" do
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(b,@i),r=$r if r'=$select("^c"=i:"^c",1:"^a(1,2)")!(a=$data(b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(^b,@i),r=$r if r'="^b"!(a=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(b,@i),r=$r if r'=$select("^c"=i:"^c",1:"^a(1,2)")!(a'=$data(b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(^b,@i),r=$r if r'="^b"!(a'=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$i(b,@i@(1)),r=$r if r'=$s("^c"=i:"^c(1)","c"=i:"^a(1,2)",1:"^a(1,2,1)")!(a=$d(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(^b,@i@(1)),r=$r if r'="^b"!(a=$data(^b)),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$i(b,@i@(1)),r=$r if r'=$s("^c"=i:"^c(1)","c"=i:"^a(1,2)",1:"^a(1,2,1)")!(a'=$d(b)),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(^b,@i@(1)),r=$r if r'="^b"!(a'=$data(^b)),$increment(cnt) x act
  .. quit
  . for c="b","^b" do
  .. set i=""
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(@c,^c),r=$r if r'=$select("^b"=c:"^b",1:"^c")!'$data(@c)!'d,$increment(cnt) xecute act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(@c,^c),r=$r if r'=$select("^b"=c:"^b",1:"^c")!'$data(@c)!(d'=a),$increment(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(@c@(1),^c),r=$r if r'=$select("^b"=c:"^b(1)",1:"^c")!'$data(@c@(1))!'d,$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(@c@(1),^c),r=$r if r'=$select("^b"=c:"^b(1)",1:"^c")!'$data(@c@(1)),(d'=a),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$increment(@c,^(2)),r=$r if r'=$select("^b"=c:"^b",1:"^a(1,2)")!'$data(@c)!'d,$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$increment(@c,^(2)),r=$r if r'=$select("^b"=c:"^b",1:"^a(1,2)")!'$data(@c)!(d'=a),$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a!$i(@c@(1),^(2)),r=$r if r'=$select("^b"=c:"^b(1)",1:"^a(1,2)")!'$data(@c@(1))!'d,$i(cnt) x act
  .. kill b,^b set ^a(1,2)=1,d=a&$i(@c@(1),^(2)),r=$r if r'=$select("^b"=c:"^b(1)",1:"^a(1,2)")!'$data(@c@(1))!(d'=a),$i(cnt) x act
  .. for i="c","^c","^(2)" do
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c,@i),r=$r if r'=$s("^b"=c:"^b","^c"=i:"^c",1:"^a(1,2)")!'$d(@c)!(d'=(a!@c)),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c,@i@(1)),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)","^c"=i:"^c(1)",1:"^a(1,2,1)")!'$d(@c)!(d'=(a!@c)),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a&$i(@c,@i@(1)),r=$r if r'=$s("^b"=c:"^b","c"=i:"^a(1,2)","^c"=i:"^c(1)",1:"^a(1,2,1)")!(d'=(a&@c)),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c@(1),@i),r=$r if r'=$s("^b"=c:"^b(1)","^c"=i:"^c",1:"^a(1,2)")!'$d(@c@(1))!(d'=(a!@c@(1))),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a&$i(@c@(1),@i),r=$r if r'=$s("^b"=c:"^b(1)","^c"=i:"^c",1:"^a(1,2)")!'$d(@c@(1))!(d'=(a&@c@(1))),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a!$i(@c@(1),@i@(1)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)","^c"=i:"^c(1)",1:"^a(1,2,1)")!'$d(@c@(1))!(d'=(a!@c@(1))),$i(cnt) x act
  ... k b,^b s ^a(1,2)=1,d=a&$i(@c@(1),@i@(1)),r=$r if r'=$s("^b"=c:"^b(1)","c"=i:"^a(1,2)","^c"=i:"^c(1)",1:"^a(1,2,1)")!'$d(@c@(1))!(d'=(a&@c@(1))),$i(cnt) x act
 ... quit
  .. quit
  . quit
end write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)," ",type
  quit
c()
  quit '$get(^b)
extrin(x)
  quit $increment(x,^c)
extring()
  quit $get(^b)
one(x)
  set x='$get(x)
  quit 1
zero(x)
  set x='$get(x)
  quit 0
comp(x)
  quit '$get(x)
err
  write !,$zstatus
  xecute act
  if $increment(cnt) set $ecode=""
  set lab=$piece($piece($zstatus,"+"),",",2)
  if "err"=lab zgoto zl:end
  goto @(lab_"+"_($piece($zstatus,"+",2)+1))
