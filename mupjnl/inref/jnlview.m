jnlview ;
	set unix=$zv'["VMS"
	Set output="pid.out",error="jnlview.mje0"
        Open output:newversion,error:newversion
        Use output
	if unix  W "PID: ",$J,!
	else  w $ZGETJPI("","PRCNAM")
        Close output
	f i=1:1:12000 s ^a(i)=$J(i,200)
	view "JNLWAIT"
	set signal="done.out"
	open signal:newversion
	use signal
	w "done",!
	close signal
	for  h 1	; wait indefinitely for parent to kill us
	;zsy "$gtm_tst/com/gtm_crash.csh"
	q

track	;
	set value=0
	set status=1
	for  quit:(value=12000)!(status=0)  do
	.	set status=$$track1^jnlview(value)	; wait for 150 seconds for some change to ^a to happen
	.	if status=0 write "TEST-E-TIMEOUT background process took more than 150 seconds for a single db update",! zshow "*"
	.	set value=$order(^a(""),-1)
	if status=0 set $etrap="goto et",x=1/0	; simulate a fatal error so we will return error status from GTM
	quit

et	;
	quit

track1(value);
	; wait for 150 seconds for some update to ^a to happen
	new i
	for i=1:1:150  quit:$order(^a(""),-1)'=value  hang 1
	if i'=150 quit 1
	quit 0

dverify ;
	f i=1:1:12000  d
        . i ^a(i)'=$j(i,200) w "** FAIL ",!,"^a(",i,") = ",^a(i),! q
	if i=12000 w "VERIFICATION PASSED",!
        q	
everify ;
	s extract="mumps.mjf"
        o extract:(readonly)
        u extract:exception="G eof"
        s num=1
        s gbl="^a"
        s failed=0
	s done=0
        f  do  q:(failed!done)
        . u extract
        . r line
        . s type=$p(line,"\",1)
        . if type="05" do  q:failed
        .. s value=$piece(line,"\",$length(line,"\")) ; The value is always the last piece
        .. s left=$p(value,"=",1)
        .. s right=$p(value,"=",2)
        .. s lvalue=gbl_"("_num_")"
        .. s rvalue=""""_$j(num,200)_""""
        .. if (left'=lvalue)!(right'=rvalue)  d
	... u $p w "VERIFICATION FAILED at",value,!
        ... s failed=1
	.. s num=num+1
	.. if num>12000 s done=1
        ;q
eof	;
	close extract
	u $p
	if num=12001&done w "VERIFICATION PASSED",!
	q
view1	;
	s unix=$zv'["VMS"
	if unix s reg="DEFAULT"
	else  s reg="$DEFAULT"
	s ^x=1
 	w $view("JNLFILE",reg)
 	w $view("JNLACTIVE",reg)
 	w $view("JNLTRANSACTION")
	q
view2	;
	s unix=$zv'["VMS"
	if unix s reg="DEFAULT"
        else  s reg="$DEFAULT"
 	w $view("JNLFILE",reg)
 	w $view("JNLACTIVE",reg)
 	w $view("JNLTRANSACTION")
	q
