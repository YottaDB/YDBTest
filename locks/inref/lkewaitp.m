lkewaitp;  Test locks which are waiting for other process to release it
	; also test lke clear	
	SET $ZT="s $ZT="""" g ERROR"
	new i
	kill ^a,^b,^c,^pid1,^pid2,^pid3,^flag2,^flag3,^q2,^q3
	SET ^fncnt=0
	;	
	w !,"Test lke wait:",!
	s unix=$zv'["VMS"
	if unix set ^pid1=$JOB
	else  set ^pid1=$$FUNC^%DH($JOB,0)

	l (^a,^b)

	w !,"^a, ^b owned by main",!

	;second process will loc ^a
	if unix do
	. job ^lkewait2:(nodet:out="lkewait2.mjo":error="lkewait2.mje":gbl="mumps.gld")
	else  do
	. job ^lkewait2:(nodet:out="lkewait2.mjo":error="lkewait2.mje":gbl="mumps.gld":startup="startup.com")

	;wait until ^pid2 is set by 2nd proc 
	for i=1:1:120 quit:$data(^pid2)  h 1 
	if i=120 w "TEST-E-lkewaitp-Time out, job2 did not start",!  q
	;
	W "Step 1: LKE will check that parent owns ^a,^b, Job2 waits for ^a",!
	do lkeexam1(^pid1,"^a","^b",".")
	do lkeexam1(^pid2,".",".",".")
	do lkeexam2(^pid1,".",".",".")
	do lkeexam2(^pid2,"^a",".",".")
	;
	l -^a    	; main released ^a
	W !,"Step 2: ^a is released by main, wait for 2nd process to get it...",!
	;
	; wait for 2nd process to get ^a, should not take more than 60 seconds
	set str=^pid2_" got ^a"
	for i=1:1:60 quit:$data(^flag2)  h 1
	if i=60 w "TEST FAILED, Waited too long for Job2 to get lock of ^a",!  q
	if ^flag2'=str w "^flag2=",^flag2,!,str,!,"TEST-E-lkewaitp ^flag2 has wrong value",!  q
	w "Job2 acquired lock ^a",!

	W "Step 3: LKE will check that parent owns ^b, Job2 owns for ^a",!
	do lkeexam1(^pid1,".","^b",".")
	do lkeexam1(^pid2,"^a",".",".")
	do lkeexam2(^pid1,".",".",".")
	do lkeexam2(^pid2,".",".",".")



	w !,"2nd Pass of lke wait/clear test:",!

	; A third process wants ^a,^b,^c
	if unix do
	. job ^lkewait3:(nodet:out="lkewait3.mjo":error="lkewait3.mje":gbl="mumps.gld")
	else  do
	. job ^lkewait3:(nodet:out="lkewait3.mjo":error="lkewait3.mje":gbl="mumps.gld":startup="startup.com")

	for i=1:1:120 quit:$data(^pid3)  h 1 
	if i=120 w "TEST-E-Time out, job3 did not start: I am parent",!  q
	;
	W "Step 4: LKE will check that parent owns ^b, Job2 owns for ^a and Job3 waits for ^a,^b,^c",!
	do lkeexam1(^pid1,".","^b",".")
	do lkeexam1(^pid2,"^a",".",".")
	do lkeexam1(^pid3,".",".",".")
	do lkeexam2(^pid1,".",".",".")
	do lkeexam2(^pid2,".",".",".")
	do lkeexam2(^pid3,"^b",".",".")
	do lkeexam3(^pid2,^pid1,^pid3,"^a","^b","^b")

	if unix do
	.  set cmd1="$LKE clear -nointeractive -pid="_^pid1
	.  set cmd2="$LKE clear -nointeractive -pid="_^pid2
	else  do
	.  set cmd1="$LKE clear /nointeractive /pid="_^pid1
	.  set cmd2="$LKE clear /nointeractive /pid="_^pid2
	zsystem cmd1
	zsystem cmd2
	w "Step 5: Cleared all locks of Parent and Job2...",!

	; wait for 3rd process to get ^a, ^b, should not take more than 60 seconds
	set str=^pid3_" got ^a,^b"
	for i=1:1:60 quit:$data(^flag3)  h 1
	if i=60 w "TEST FAILED, Waited too long for Job3 ",!  q
	if ^flag3'=str w "^flag3=",^flag3,!,str,!,"TEST-E-lkewaitp ^flag3 has wrong value",!  q
	W "Step 5: LKE will check that Job3 got all locks on ^a,^b,^c ",!
	do lkeexam1(^pid1,".",".",".")
	do lkeexam1(^pid2,".",".",".")
	do lkeexam1(^pid3,"^a","^b","^c")
	do lkeexam2(^pid1,".",".",".")
	do lkeexam2(^pid2,".",".",".")
	do lkeexam2(^pid3,".",".",".")

	set ^q2="quit2" ; Job2 can quit now
	set ^q3="quit3" ; Job3 can quit now
	h 5
	q

lkeexam1(proc,l1,l2,l3)
	set unix=$zv'["VMS"
	set fail=0
	new dummy set dummy=$I(^fncnt)
	set fname="lkewait"_^fncnt_".out"
	set y="Owned by PID"
	if unix do
	.  SET zscmd="zsystem ""$LKE show -all -OUTPUT="_fname_"; $convert_to_gtm_chset "_fname_""""
	.  x zscmd
	else  do
	.  SET zero="",$p(zero,"0",8-$l(proc)+1)="",proc=zero_proc ; zero fill prefix
	.  SET zscmd="zsystem ""pipe $LKE show /all 2>"_fname_" > "_fname_""""
	.  x zscmd

	set line="----"
	open fname:(READONLY)
	use fname  
	for  quit:line["DEFAULT"!$ZEOF  read line
	if line'["DEFAULT" close fname   w !,"Check REGION Name"  q
	if unix,'$ZEOF read line

	set str1="Owned by PID= "_proc_" which is"
	set str2="Owned by PID= "_proc_" which is"
	set str3="Owned by PID= "_proc_" which is"

	set t1=line
	if l1'=".",'(line[str1&(line[l1)) set fail=1  
	if '$ZEOF read line
	set t2=line
	if fail=0,l2'=".",'(line[str2&(line[l2)) set fail=1 
	if '$ZEOF read line
	set t3=line
	if fail=0,l3'=".",'(line[str3&(line[l3)) set fail=1 
	close fname
	if fail=1  w !,"   FAIL",!,"Found:",!,"1:",t1,!,"2:",t2,!,"3:",t3,!,"Expected",!,str1,!,str2,!,str3,! 
	else  w !,"   PASS"
	q


lkeexam2(proc,w1,w2,w3)
	set unix=$zv'["VMS"
	set fail=0
	new dummy set dummy=$I(^fncnt)
	set fname="lkewait"_^fncnt_".out"
	if unix do
	.  SET zscmd="zsystem ""$LKE show -wait -OUTPUT="_fname_"; $convert_to_gtm_chset "_fname_""""
	.  x zscmd
	else  do
	.  SET zero="",$p(zero,"0",8-$l(proc)+1)="",proc=zero_proc ; zero fill prefix
	.  SET zscmd="zsystem ""pipe $LKE show /wait 2>"_fname_" > "_fname_""""
	.  x zscmd
	;
	set line="----"
	open fname:(READONLY)
	use fname  
	for  quit:line["DEFAULT"!$ZEOF  read line
	if line'["DEFAULT" close fname   w !,"Check REGION Name"  q

	if unix,'$ZEOF read line

	set str1="Request  PID= "_proc_" which is"
	set str2="Request  PID= "_proc_" which is"
	set str3="Request  PID= "_proc_" which is"

	set t1=line
	if w1'=".",'(line[str1&(line[w1)) set fail=1 
	if '$ZEOF read line
	set t2=line
	if fail=0,w2'=".",'(line[str2&(line[w2)) set fail=1 
	if '$ZEOF read line
	set t3=line
	if fail=0,w3'=".",'(line[str3&(line[w3)) set fail=1 
	close fname
	if fail=1  w !,"   FAIL",!,"Found:",!,"1:",t1,!,"2:",t2,!,"3:",t3,!,"Expected",!,str1,!,str2,!,str3,! 
	else  w !,"   PASS"
	q

lkeexam3(proc1,proc2,proc3,w1,w2,w3)
	set unix=$zv'["VMS"
	set fail=0
	new dummy set dummy=$I(^fncnt)
	set fname="lkewait"_^fncnt_".out"
	if unix do
	.  w !,"lke show -all -wait",!
	.  SET zscmd="zsystem ""$LKE show -all -wait -output="_fname_"; $convert_to_gtm_chset "_fname_""""
	.  x zscmd
	else  do
	.  SET zero="",$p(zero,"0",8-$l(proc1)+1)="",proc1=zero_proc1 ; zero fill prefix
	.  SET zero="",$p(zero,"0",8-$l(proc2)+1)="",proc2=zero_proc2 ; zero fill prefix
	.  SET zero="",$p(zero,"0",8-$l(proc3)+1)="",proc3=zero_proc3 ; zero fill prefix
	.  w !,"lke show /all /wait",!
	.  SET zscmd="zsystem ""pipe $LKE show /all /wait 2>"_fname_" > "_fname_""""
	.  x zscmd
	set line="----"
	open fname:(READONLY)
	use fname  
	for  quit:line["DEFAULT"!$ZEOF  read line
	if line'["DEFAULT" close fname   w !,"Check REGION Name"  q

	if unix,'$ZEOF read line

	set str1="Owned by PID= "_proc1_" which is"
	set str2="Owned by PID= "_proc2_" which is"
	set str3="Request  PID= "_proc3_" which is"

	set t1=line
	if w1'=".",'(line[str1&(line[w1)) set fail=1 
	if '$ZEOF read line
	set t2=line
	if fail=0,w2'=".",'(line[str2&(line[w2)) set fail=1 
	if '$ZEOF read line
	set t3=line
	if fail=0,w3'=".",'(line[str3) set fail=1 
	close fname
	if fail=1  w !,"   FAIL",!,"Found:",!,"1:",t1,!,"2:",t2,!,"3:",t3,!,"Expected",!,str1,!,str2,!,str3,! 
	else  w !,"   PASS"
	q

ERROR	;	
	ZSHOW "*"
	q
