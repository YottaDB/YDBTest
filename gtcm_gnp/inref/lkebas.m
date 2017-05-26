lkebas	; simple locks
	write !,"Starting lkebas...",!
	write "simple locks",!
	set fncnt=0
	set waittim=5
	set unix=$zv'["VMS"

	lock:waittim    
	if 1	; $truth is not touched by the lock:waittim command so set it to 1 as exam^lkebas prints it
	do exam^lkebas(0,".",".",".",".",1,1,1,1)
	do lkeexam(0,".",".",".",".",0)
	lock ^a:waittim
	do exam^lkebas(1,"^a",".",".",".",1,1,1,1)	
	do lkeexam(1,"^a",".",".",".",1)	
	lock ^c:waittim
	do exam^lkebas(3,".",".","^c",".",1,1,1,1)	
	do lkeexam(3,"^c",".",".",".",1)	
	lock ^b:waittim
	do exam^lkebas(2,".","^b",".",".",1,1,1,1)	
	do lkeexam(2,"^b",".",".",".",1)	
	lock (^a,^b,^c,^d):waittim
	do exam^lkebas(4,"^a","^b","^c","^d",1,1,1,1)
	do lkeexam(4,"^a","^b","^c","^d",4)
	lock:waittim
	if 1	; $truth is not touched by the lock:waittim command so set it to 1 as exam^lkebas prints it
	do exam^lkebas(5,".",".",".",".",1,1,1,1)
	do lkeexam(5,".",".",".",".",0)


incr	write !,"incremental locks",!
	lock ^a:waittim
	do exam^lkebas(11,"^a",".",".",".",1,1,1,1)	
	do lkeexam(11,"^a",".",".",".",1)
	lock +^b:waittim
	do exam^lkebas(12,"^a","^b",".",".",1,1,1,1)	
	do lkeexam(12,"^a","^b",".",".",2)	
	lock +^a:waittim,^b:waittim,^c:waittim
	do exam^lkebas(13,".",".","^c",".",1,1,1,1)
	do lkeexam(3,"^c",".",".",".",1)
	lock +(^a,^b,^c,^d):waittim 
	do exam^lkebas(14,"^a","^b","^c","^d",1,1,2,1)
	do lkeexam(14,"^a","^b","^c","^d",4)
	lock:waittim    
	if 1	; $truth is not touched by the lock:waittim command so set it to 1 as exam^lkebas prints it
	do exam^lkebas(15,".",".",".",".",1,1,1,1)
	do lkeexam(15,".",".",".",".",0)


decr	write !,"decremental locks",!
	lock ^a:waittim 
	do exam^lkebas(21,"^a",".",".",".",1,1,1,1)	
	do lkeexam(21,"^a",".",".",".",1)	
	lock +^b:waittim 
	do exam^lkebas(22,"^a","^b",".",".",1,1,1,1)	
	do lkeexam(22,"^a","^b",".",".",2)	
	lock -^a:waittim 
	if 1	; $truth is not touched by the above lock -^a:waittim command so set it to 1 as exam^lkebas prints it
	do exam^lkebas(23,".","^b",".",".",1,1,1,1)
	do lkeexam(23,"^b",".",".",".",1)
	lock +(^a,^b,^c,^d):waittim 
	do exam^lkebas(24,"^a","^b","^c","^d",1,2,1,1)
	do lkeexam(24,"^a","^b","^c","^d",4)
	lock -(^a,^b,^c,^d):waittim  
	if 1	; $truth is not touched by the above lock -(^a,...):waittim command so set it to 1 as exam^lkebas prints it
	do exam^lkebas(25,".","^b",".",".",1,1,1,1)
	do lkeexam(25,"^b",".",".",".",1)

local	write !,"local locks",!
	lock a:waittim
	do exam^lkebas(31,"a",".",".",".",1,1,1,1)
	do lkeexam(31,"a",".",".",".",1)
	lock b:waittim
	do exam^lkebas(32,".","b",".",".",1,1,1,1)
	do lkeexam(32,"b",".",".",".",1)
	lock c:waittim
	do exam^lkebas(33,".",".","c",".",1,1,1,1)
	do lkeexam(33,"c",".",".",".",1)
	lock (a,b,c):waittim
	do exam^lkebas(34,"a","b","c",".",1,1,1,1)
	do lkeexam(34,"a","b","c",".",3)
	lock:waittim
	if 1	; $truth is not touched by the lock:waittim command so set it to 1 as exam^lkebas prints it
	write !,"End of lock test",!
	quit

exam(k,e0,e1,e2,e3,l0,l1,l2,l3,zalarg)
	set truth=$T
	if 'unix write "=========================================================",!
	write "exam(",k,",",e0,",",e1,",",e2,",",e3,") "
	write truth,!
	if 'unix zsystem "@gtm$test_common:sec_shell_gtcm"
	quit
	write "LKE does not work yet (on the client). Enable once it is fixed."
	kill x
	kill y
	set y(1)="LOCK "_e0_" LEVEL="_l0
	set y(2)="LOCK "_e1_" LEVEL="_l1
	set y(3)="LOCK "_e2_" LEVEL="_l2
	set y(4)="LOCK "_e3_" LEVEL="_l3
	set tomatch=0
	f i=0:1:3 set tmpx="e"_i i @tmpx'="." set tomatch=tomatch+1
	set tocheck=5
	zshow "l":x
	i $d(x("L",1))=0  set x("L",1)="LOCK . LEVEL=1"
	i $d(x("L",2))=0  set x("L",2)="LOCK . LEVEL=1"
	i $d(x("L",3))=0  set x("L",3)="LOCK . LEVEL=1"
	i $d(x("L",4))=0  set x("L",4)="LOCK . LEVEL=1"
	;zwr x w "-------",!  zwr y
	set match=0,nulmatch=0
	for i=1:1:4 do
	. for j=1:1:4 do
	. . ;write !,"==>",y(i)," ==>",x("L",j)
	. . if y(i)=x("L",j) if y(i)="LOCK . LEVEL=1" set nulmatch=nulmatch+1
	. . if y(i)=x("L",j) if y(i)'="LOCK . LEVEL=1" do
	. . . set match=match+1
	. . . ;write "matched:",i," ",j,y(i)
	. . ;else  write "no match:",y(i),"<===>",x("L",j),!
	;write "expected match:",tomatch,"actual match:",match," nulmatch:",nulmatch," tonulmatch:",(5-tomatch)**2,!
	if match'=tomatch,nulmatch'=(5-tomatch)**2 write !,k,"** GTM MISMATCH",!
	e  write !,k,"   GTM MATCH"   quit
	;write !,"EXP:" f i=1:1:4 write "<",i,": ",y(i),">"
	;write !,"ACT:" f i=1:1:4 write "<",i,": ",x("L",i),">"
	;write !
	write "         computed <",x("L",1),"> expected <",y(1),">",!
	write "         computed <",x("L",2),"> expected <",y(2),">",!
	write "         computed <",x("L",3),"> expected <",y(3),">",!
	write "         computed <",x("L",4),"> expected <",y(4),">",!
	quit



lkeexam(k,e0,e1,e2,e3,lcnt)
	quit
	set fncnt=fncnt+1
	set fname="lkebas"_fncnt_".out"
	set cnt=0
	set unix=$zv'["VMS"
	set y="Owned by PID"
	if unix do
	.  SET zscmd="zsystem ""$LKE show -all -OUTPUT="_fname_""""
	.  xecute zscmd
	.  set x="which is an existing process"
	else  do
	.  SET zscmd="zsystem ""$LKE show /all 2>"_fname_" > "_fname_""""
	.  xecute zscmd
	.  set x="which is"

	set line=""
	set locks=""
	set explocks=""
	for i=0:1:3  do
	. set xi="e"_i
	. if (@xi'=".") set explocks=explocks_@xi
	;set explocks=e0_","_e1_","_e2_","_e3
	set fmatch=""
	open fname:READONLY  
	use fname  
	if e0=".",e1=".",e2=".",e3="."  do
	.  for  quit:$ZEOF  do
	.  . if (line'["No matching locks were found in")&(line'="") set fmatch="bad match"_line 
	.  . read line 
	.  close fname
	.  if lcnt write !,k,"   LKE MISMATCH  -- wrong count" quit
	.  if fmatch="" write !,k,"   LKE MATCH" quit
	.  write !,k,"   LKE MISMATCH  -- there are some locks!"
	.  quit
	else  do
	.  for  quit:$ZEOF  do
	.  . read line
	.  . ;u $P write line,!,$F(line," "),!,$E(line,1,$F(line," ")-1),! u fname
	.  . if line[y,line[x   do
	.  .  . set locks=locks_$E(line,1,$F(line," ")-1)_",",oldcnt=cnt
	.  .  . ;write $E(line,1,$F(line," ")-1),!
	.  .  . if $find(line,e0)=($length(e0)+1),line[y,line[x set cnt=cnt+1 
	.  .  . if $find(line,e1)=($length(e1)+1),line[y,line[x set cnt=cnt+1
	.  .  . if $find(line,e2)=($length(e2)+1),line[y,line[x set cnt=cnt+1
	.  .  . if $find(line,e3)=($length(e3)+1),line[y,line[x set cnt=cnt+1
	.  .  . if oldcnt=cnt set cnt=cnt+10 ;u $P write "how bad is that",! u fname
	.  close fname
	.  ;write "lcnt:",lcnt," cnt:",cnt,!
	.  if lcnt=cnt write !,k,"   LKE MATCH" quit
	.  else  write !,k,"   LKE FAIL.",!,"Was expecting   ->",explocks,!,"But actual locks ->",locks
	quit
