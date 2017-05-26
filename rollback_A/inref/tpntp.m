tpntp(jobcnt);
	set jmaxwait=0		; Child process will continue in background. So do not wait, just return.
	do ^job("jobs^tpntp",jobcnt,"""""")
	q

jobs;
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	SET jobno=(jobindex#3)+1
	If $zv["VMS" DO ^jobname(jobno)
	SET jname="job"_jobno
	SET maxcnt=10000000000
	d @jname
	q
job1;
	SET dummy=1_$j(1,200)
	SET ^val(jobno)=dummy
	For jjj=1:3:maxcnt DO
	. TStart ():(serial:transaction="BA")
	. s ^gtp(jjj)=dummy
	. s ^htp(jjj)=dummy
	. s ^itp(jjj)=dummy
	. s ^jtp(jjj)=dummy
	. for kkk=1:1:5 DO
	. . s ^gtp(jjj,kkk)=dummy
	. . s ^htp(jjj,kkk)=dummy
	. . s ^itp(jjj,kkk)=dummy
	. . s ^jtp(jjj,kkk)=dummy
	. TC
	quit
job2;
	SET dummy=1_$j(1,200)
	SET ^val(jobno)=dummy
	For jjj=2:3:maxcnt DO
	. TStart ():(serial:transaction="BA")
	. s ^etp(jjj)=dummy 
	. s ^ftp(jjj)=dummy
	. s ^gtp(jjj)=dummy
	. s ^htp(jjj)=dummy
	. for kkk=1:1:5 DO
	. . s ^etp(jjj,kkk)=dummy 
	. . s ^ftp(jjj,kkk)=dummy
	. . s ^gtp(jjj,kkk)=dummy
	. . s ^htp(jjj,kkk)=dummy
	. TC
	quit
job3	;
	SET dummy="NTP"
	SET ^val(jobno)=dummy
	SET cnt=1
	For jjj=3:3:maxcnt DO
	. s ^antp(jjj)=dummy
	. s ^bntp(jjj)=dummy
	. s ^cntp(jjj)=dummy
	. s ^dntp(jjj)=dummy
	quit
verify;
	set dummy=^val(1)
	set lastj=$ZPREVIOUS(^itp(""))
	for jjj=1:3:lastj DO
	. if $GET(^gtp(jjj))'=dummy write "Verify failed for ^gtp index ",jjj,!
	. if $GET(^htp(jjj))'=dummy write "Verify failed for ^htp index ",jjj,!
	. if $GET(^itp(jjj))'=dummy write "Verify failed for ^itp index ",jjj,!
	. if $GET(^jtp(jjj))'=dummy write "Verify failed for ^jtp index ",jjj,!
	. for kkk=1:1:5 DO
	. . if $GET(^gtp(jjj,kkk))'=dummy write "Verify failed for ^gtp index ",jjj,!
	. . if $GET(^htp(jjj,kkk))'=dummy write "Verify failed for ^htp index ",jjj,!
	. . if $GET(^itp(jjj,kkk))'=dummy write "Verify failed for ^itp index ",jjj,!
	. . if $GET(^jtp(jjj,kkk))'=dummy write "Verify failed for ^jtp index ",jjj,!
	;
	set dummy=^val(2)
	set lastj=$ZPREVIOUS(^etp(""))
	for jjj=2:3:lastj DO
	. if $GET(^etp(jjj))'=dummy write "Verify failed for ^etp index ",jjj,!
	. if $GET(^ftp(jjj))'=dummy write "Verify failed for ^ftp index ",jjj,!
	. if $GET(^gtp(jjj))'=dummy write "Verify failed for ^gtp index ",jjj,!
	. if $GET(^htp(jjj))'=dummy write "Verify failed for ^htp index ",jjj,!
	. for kkk=1:1:5 DO
	. . if $GET(^etp(jjj,kkk))'=dummy write "Verify failed for ^etp index ",jjj,!
	. . if $GET(^ftp(jjj,kkk))'=dummy write "Verify failed for ^ftp index ",jjj,!
	. . if $GET(^gtp(jjj,kkk))'=dummy write "Verify failed for ^gtp index ",jjj,!
	. . if $GET(^htp(jjj,kkk))'=dummy write "Verify failed for ^htp index ",jjj,!
	;
	set dummy=^val(3)
	set lastj=$ZPREVIOUS(^antp(""))
	For jjj=3:3:lastj DO
	. if $GET(^antp(jjj))'=dummy write "Verify failed for ^antp index ",jjj,!
	set lastj=$ZPREVIOUS(^bntp(""))
	For jjj=3:3:lastj DO
	. if $GET(^bntp(jjj))'=dummy write "Verify failed for ^bntp index ",jjj,!
	set lastj=$ZPREVIOUS(^cntp(""))
	For jjj=3:3:lastj DO
	. if $GET(^cntp(jjj))'=dummy write "Verify failed for ^cntp index ",jjj,!
	set lastj=$ZPREVIOUS(^dntp(""))
	For jjj=3:3:lastj DO
	. if $GET(^dntp(jjj))'=dummy write "Verify failed for ^dntp index ",jjj,!
	w "Verify Done",!
	q
