; Verify zdata works with spanning nodes
; This script is called from basic.csh

zdata
	set a=$justify(" ",2500),*b(1)=a,*c=d
	if $zdata(a)'=101 write "zdata failed (1)",!
	if $zdata(c)'=100 write "zdata failed (2)",!
	if $zdata(d)'=100 write "zdata failed (3)",!
	if $zdata(b(1))'=101 write "zdata failed (4)",!
	set b(1,"111")=$justify(" ",2500)
	if $zdata(b(1))'=111 write "zdata failed (5)",!
	quit
