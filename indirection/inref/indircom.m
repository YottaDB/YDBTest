indircom ; indirect code for certain commands
	set unix=$zv'["VMS"
	; JOB
	do tjob
	; $TEXT()
	write "***$TEXT()***",!
	for commandasalongname9012345678901="write $TEXT(label1),!","write $TEXT(label1+1),!","write $TEXT(label2),!" do
	. set commandasalongname901234567890="This hasn't got any label to write ;)"
	. xecute commandasalongname9012345678901
	write "",!
	;ZBREAK
	write "***ZBREAK***",!
	do tzbreak
	write "",!
	;ZPRINT
	write "***ZPRINT***",!
	do tzprint
	write "",!
	; Print JOB's Output
	write "***JOB***",!
	do tjobop
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tjob	;
	set startupcom=""
	if 'unix set startupcom="STARTUP=""STARTUP.COM"":" 
	for commandasalongname9012345678901="job label1:("_startupcom_"out=""job1.mjo"":err=""job1.mje"")","job label2:("_startupcom_"out=""job2.mjo"":err=""job2.mje"")" do
	. set commandasalongname901234567890="No Jobs to do... "
	. write commandasalongname9012345678901,!
	. xecute commandasalongname9012345678901
	set wait=1
	for i=1:1:120  quit:'wait  hang 1 if ($get(^label1))&($get(^label2)) set wait=0
	if 120=i write "TEST-E-TIMEOUT, the children did not start at all or not finish",! halt
	; The children have definitely started and done their processing, we still need to ensure
	; the processes have rundown completely.
	set unix=$zversion'["VMS"
	for lblgbl="^label1","^label2"  do
	. if unix set com="$gtm_tst/com/wait_for_proc_to_die.csh "_@lblgbl
	. else  set com="@gtm$test_common:wait_for_proc_to_die.com "_$$FUNC^%DH(@lblgbl)
	. zsystem com
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tzbreak ; ZBREAK
	for commandasalongname9012345678901="zbreak label5","zbreak label4","zbreak label3" do
	. set commandasalongname901234567890="This will literally break :( "
	. xecute commandasalongname9012345678901
	. ZSHOW "B"
	;after the loop
	set commandasalongname9012345678901="ZBREAK -*"
	set commandasalongname901234567890="This is not a command to xecute!!!"
	xecute commandasalongname9012345678901
	ZSHOW "B":var
	if 0'=$DATA(var) write "TEST-E-ERROR, ZBREAK -* did not work",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tzprint	; ZPRINT
	for commandasalongname9012345678901="zprint label1:label2+-1","zprint label3:label4+-1" do
	. set commandasalongname901234567890="Print this and you fail..."
	. xecute commandasalongname9012345678901
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tjobop	; Output of the JOBbed task
	if unix zsystem "$convert_to_gtm_chset job1.mje; $convert_to_gtm_chset job2.mje"
	for out="job1.mjo","job1.mje","job2.mjo","job2.mje" do
        . set file=out
        . open file:(exception="QUIT:$ZEOF=1  ZSHOW ""*"" HALT")
	. for  quit:$zeof=1  do
	. . use file
	. . read line
	. . use $p
	. . write line,!
        . close file
	. use $p
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
label1	write "This is label1",!
	write "This is label1+1",!
	set ^label1=$JOB ; To communicate the jobid of the first job to the parent
	quit
label2	write "This is label2",!
	set ^label2=$JOB ; To communicate the jobid of the second job to the parent
	quit
label3	;just to test zbreak and zprint
	write "This is label3",! quit
label4	;to test zbreak
	write "This is label4",! quit
label5	;to test zbreak
	write "This is label5",! quit
