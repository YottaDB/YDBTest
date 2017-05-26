	;;; myfill.m 
fill1(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=1
	s length=1
	f i=2:1:1024   D 
	. s from=from#50+1
	. s length=length#30+1
	. s x="^"_$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="kill"  k @x
	. i act="set"   s @x=y  
	. i act="ver"   do CHECK(x,y,@x)
	Write $Select(cnt:"FAIL",1:"PASS")," from fill1^",$Text(+0),"(""",act,""")",!
	q
fill2(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=10
	s length=10
	f i=2:1:2048   D 
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="kill"  k ^data(x)
	. i act="set"   s ^data(x)=y  
	. i act="ver"   do CHECK("^data("_x_")",y,^data(x))
	Write $Select(cnt:"FAIL",1:"PASS")," from fill2^",$Text(+0),"(""",act,""")",!
	q
fill3(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=20
	s length=20
	f i=2:1:8192   D 
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="kill"  k ^data(x,3)
	. i act="set"   s ^data(x,3)=y 
	. i act="ver"   do CHECK("^data("_x_",3)",y,^data(x,3))
	Write $Select(cnt:"FAIL",1:"PASS")," from fill3^",$Text(+0),"(""",act,""")",!
	q
fill4(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=30
	s length=30
	f i=2:1:1000   D 
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="kill"  k ^bing(x)      k ^cing(x)
	. i act="set"   s ^bing(x)=y    s ^cing(x)=y
	. i act="ver"   do CHECK("^bing("_x_")",y,^bing(x))   do CHECK("^cing("_x_")",y,^cing(x))
	Write $Select(cnt:"FAIL",1:"PASS")," from fill4^",$Text(+0),"(""",act,""")",!
	q
fill5(act)
	s cnt=0
	f i=1:1:100 d
	. i act="kill" k ^aaaaaaaaaa(i)  k ^bbbbbbbbbb(i)
	. i act="right" s ^aaaaaaaaaa(i)="right"  s ^bbbbbbbbbb(i)="right"  s ^cc(i)="right"
	. i act="wrong" s ^aaaaaaaaaa(i)="wrong"  s ^bbbbbbbbbb(i)="wrong"  s ^cc(i)="wrong"
	. i act="ver"   d CHECK("^aaaaaaaaaa("_i_")","right",^aaaaaaaaaa(i))  d CHECK("^bbbbbbbbbb("_i_")","right",^bbbbbbbbbb(i)) 
	Write $Select(cnt:"FAIL",1:"PASS")," from fill5^",$Text(+0),"(""",act,""")",!
	q
fill6(act)
	s cnt=0
	f i=1:1:100 d
	. i act="kill" k ^ccccc(i)  k ^ddddd(i)
	. i act="right" s ^ccccc(i)="right"  s ^ddddd(i)="right"
	. i act="wrong" s ^ccccc(i)="wrong"  s ^ddddd(i)="wrong"
	. i act="ver"   d CHECK("^ccccc("_i_")","right",^ccccc(i))  d CHECK("^ddddd("_i_")","right",^ddddd(i)) 
	Write $Select(cnt:"FAIL",1:"PASS")," from fill6^",$Text(+0),"(""",act,""")",!
	q
fill7(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=30
	s length=30
	; it used to go up to 200000, used only in mu_integ
	f i=2:1:200   D 	
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="kill"  k ^aing(x)
	. i act="set"   s ^aingfillingdatabase(x)=y
	. i act="ver"   do CHECK("^aingfillingdatabase("_x_")",y,^aingfillingdatabase(x)) 
	Write $Select(cnt:"FAIL",1:"PASS")," from fill7^",$Text(+0),"(""",act,""")",!
	q
fill8(act)
	s cnt=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s from=30 
	s length=30
	s ^stophere="",^error=0
	f i=2:1:100000   D 
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="init"  s ^a(x)="init",^b(x)="init",^c(x)="init"
	. i act="kill"  k ^a(x)  k ^b(x)  k ^c(x)
	. i act="set"   s ^a(x)=y,^b(x)=y,^c(x)=y
	. i act="ver"   do OLCHECK("^a("_x_")",y,^a(x))  do OLCHECK("^b("_x_")",y,^b(x))  do OLCHECK("^c("_x_")",y,^c(x)) 
	Write $Select(cnt:"FAIL",1:"PASS")," from fill8^",$Text(+0),"(""",act,""")",!
	q
fill9(act,val)
        s cnt=0,from=30,length=30,done=0
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	i act="init"  s ^config("finished")=0,^config("backupdone")="FALSE"
	i act="init"  f val="AA","BB","CC","DD","EE","FF","GG","HH"  s ^stophere(val)="",^error(val)=0
	f i=2:1:50000   D  q:done=1 
	. s from=from#50+1
	. s length=length#10+1
	. s x=$e(template,from,from+length)_"("_i_")"
	. s y=$e(template,from+1,from+length)
	. i act="init"  f val="AA","BB","CC","DD","EE","FF","GG","HH"  s ^a(x,val)="init",^b(x,val)="init",^c(x,val)="init"
	. i act="kill"  f val="AA","BB","CC","DD","EE","FF","GG","HH"  k ^a(x,val),^b(x,val),^c(x,val) 
	. i act="set"   s ^a(x,val)=y,^b(x,val)=y,^c(x,val)=y  s:^config("backupdone")="TRUE" done=1
	. i act="ver"   f val="AA","BB","CC","DD","EE","FF","GG","HH"  d
	. . do MOCHECK("^a("_x_","_val_")",y,^a(x,val),val)  
	. . do MOCHECK("^b("_x_","_val_")",y,^b(x,val),val)  
	. . do MOCHECK("^c("_x_","_val_")",y,^c(x,val),val) 
	i act="set"  lock +^config  s ^config("finished")=^config("finished")+1  lock -^config
	Write $Select(cnt:"FAIL",1:"PASS")," from fill9^",$Text(+0),"(""",act,""")",!
	q
fill21(act)
	s cnt=0
	f i=5,3,7,9  d
	. i act="kill"   k ^a(i_$j(i,60)_i)
	. i act="set"    s ^a(i_$j(i,60)_i)=$j(i,400) 
	. i act="ver"    d CHECK("ERROR",$j(i,400),$g(^a(i_$j(i,60)_i))) 
	Write $Select(cnt:"FAIL",1:"PASS")," from fill21^",$Text(+0),"(""",act,""")",!
	q
fill22(act)
	s cnt=0
	f i=1:1:300 d
	. i act="kill"   k ^b(i_$j(i,20)_i)
	. i act="set"    s ^b(i_$j(i,20)_i)=$j(i,200)
	. i act="ver"    d CHECK("ERROR",$j(i,200),$g(^b(i_$j(i,20)_i)))
	Write $Select(cnt:"FAIL",1:"PASS")," from fill22^",$Text(+0),"(""",act,""")",!
	q
fill23(act)
	s cnt=0
	f i=1:1:100  d
	. i act="kill"   k ^c(i_$j(i,8)_i)
	. i act="set"    s ^c(i_$j(i,8)_i)=$j(i,9)
	. i act="ver"    d CHECK("ERROR",$j(i,9),$g(^c(i_$j(i,8)_i)))
	Write $Select(cnt:"FAIL",1:"PASS")," from fill23^",$Text(+0),"(""",act,""")",!
	q

CHECK(a,b,c)
	i b=c q
	s cnt=cnt+1
	w a," is ",c," not ",b,!
	q
OLCHECK(a,b,c)
	i $l(^stophere)=0  d  q
	. i b=c  q
	. i c="init"  s ^stophere=a  q
	. s ^error=^error+1,cnt=cnt+1  i ^error<10  w !,"ERROR: ",a," is ",c,", which is neither the init value nor the newly set value.",!
	i c="init"  q
	s ^error=^error+1,cnt=cnt+1  i ^error<10  w !,"ERROR: ",a," is ",c,", and it should be ""init""",!
	q
MOCHECK(a,b,c,d)
	i $l(^stophere(d))=0  d  q
	. i b=c  q
	. i c="init"  s ^stophere(d)=a  q
	. s ^error(d)=^error(d)+1,cnt=cnt+1  i ^error(d)<10  w !,"ERROR: ",a," is ",c,", which is neither the init value nor the newly set value.",!
	i c="init"  q
	s ^error(d)=^error(d)+1,cnt=cnt+1  i ^error(d)<10  w !,"ERROR: ",a," is ",c,", and it should be ""init""",!
	q
