compute	;;
	; calculate avg, std.dev. for multi test runs
	; also keep history (server.dat) and total (n, x, x^2 in server.csv and server.glo)
	s prevdev=$IO
	s newspeedf=^hostn_".m"
	set comma=","
	o newspeedf:new
	u newspeedf
	w ^hostn,!
	w "       ;",image,!
	u prevdev
	w "For this set of runs:",!
	for k="QUE039","QUE055","QUE096"  d
	. s run=^run(k)
	. s sum=0.0
	. f i=1:1:run s sum=sum+^value(k,i)
	. s avg=sum/run
	. s diffsum=0.0
	. f i=1:1:run  d
	. . set diff=^value(k,i)-avg 
	. . set diffsq=diff*diff 
	. . set diffsum=diffsum+diffsq 
	. set stddev=$$FUNC^%SQROOT(diffsum/run)
	. s zzzref=avg+(2*stddev)
	. w k," AVG:",avg," STDDEV:",stddev," ACCPT:",zzzref,!
	. u newspeedf
	. w "        s ^zzzavg(""",k,""")=",$J(avg,0,2)," s ^zzzstddev(""",k,""")=",$J(stddev,0,2),!
	. u prevdev 
	; at the end, write (x, x^2, and n (totals) to server.dat)
	s csvfil=^hostn_".csv"
	o csvfil:new
	u csvfil
	f varname="^totalx","^totalsq","^totaln"  d
	. s tmp1=varname
	. f  S tmp1=$Q(@tmp1) q:tmp1=""  d
        . . w varname,comma,$J(@tmp1,0,2)
        . . s i=2  f  s x=$P(tmp1,"""",i)  q:x=""  W comma,x  s i=i+2
        . . w !
	u prevdev
	c newspeedf
	q
