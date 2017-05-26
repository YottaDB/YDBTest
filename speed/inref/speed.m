speed	; Multi or Single Process SPEED test
	; Called for ^typestr as LCL, GBLS, GBLM, GBLREORG
	;
	set $ZT="g ERROR^speed"
	new prime,unix,str,jobno,elapfrom,elapto
	; jobcnt = number of jobs
	; typestr:	LCL = local variable, 
	; 		GBLREORG = global with reorg, 
	;		GBL = global without reorg
	; jnlstr :	JNL : Journaling is on, 
	;		NOJNL : No journaling
	; order:	SEQOP:sequentially 
	;		RANDOP:randomly generated index
	set $ZT="g ERROR^speed"
	set ^opname(1)="SETOP"
        set ^opname(2)="READOP"
        set ^opname(3)="GETOP"
        set ^opname(4)="DATAOP"
        set ^opname(5)="ORDEROP"
        set ^opname(6)="ZPREVOP"
        set ^opname(7)="QUERYOP"
        set ^opname(8)="KILLOP"      
	;
	set ^totdata=^totname*^jobcnt*(^prime-1)*^repeat
	write "Total Data=",^totdata,!
	set timeout=^totdata/10+30
	write "Timeout =",timeout," sec",!
	set ^opno=$GET(^opno)+1	; Not used for LCL
	set opno=^opno	; Not used for LCL
	set jobcnt=^jobcnt
	set typestr=^typestr
	set jnlstr=^jnlstr
	set order=^order
	set unix=^unix
	set prime=^prime
	lock +^permit
	write "Main Starts at :",$ZDate($Horolog,"24:60:SS"),!
	For jobno=1:1:jobcnt do
	. IF unix  DO
	. . set jobs="SPJOB^speed(jobno,jobcnt,typestr,order,opno):(output="""_typestr_".mjo"_jobno_""":error="""_typestr_".mje"_jobno_""")"
	. Else  DO
	. . set jobs="SPJOB^speed(jobno,jobcnt,typestr,order,opno):(STARTUP=""STARTUP.COM"":output="""_typestr_".mjo"_jobno_""":error="""_typestr_".mje"_jobno_""")"
	. J @jobs
        . H 1
	write "Releasing jobs...",! 
	set mainbeg=$h
	lock -^permit
	H 0
	H 20
	lock +^permit:timeout
	IF $t'=1 write "SPEED_TEST TIME OUT, TEST FAILED",!  Q
	set mainend=$h
	write "Main Ends at   :",$ZDate($Horolog,"24:60:SS"),!
	write !,"All job has finised now.",! 
        set ^elaptime(^image,^typestr,^jnlstr,^opname(opno),^order,"PARENT",^run)=$$^difftime(mainend,mainbeg)
	Quit


SPJOB(jobno,jobcnt,typestr,order,opno)
	new ACN,RES
	set $ZT="g ERROR^speed"
	set totroot=^totroot
	set repeat=^repeat
	set prime=^prime
	set totop=^totop	; Used for LCL only
	set ctop=^ctop
	merge root=^root
	if typestr["LCL" DO
	.  merge cust=^cust 
	.  kill ^cust
	;
	;All job start at same time. 
	lock +^permit($j)
	;
	;
	; Start Local Variable
	;
	if typestr["LCL",order="RANDOP" DO
	.   FOR opno=1:1:totop DO 
	.   .   set opfn=^opname(opno)_"^randlcl"
	.   .   write "Op ",opfn," Starts at:",$ZDate($Horolog,"24:60:SS"),!
	.   .   do @opfn
	if typestr["LCL",order="SEQOP" DO
	.   FOR opno=1:1:totop DO 
	.   .   set opfn=^opname(opno)_"^seqlcl"
	.   .   write "Op ",opfn," Starts at:",$ZDate($Horolog,"24:60:SS"),!
	.   .   do @opfn
	;	
	;
	; Start Global Variable
	;
	;Note: To test reorg coalesce performance do some dummy sets.
	;      Then kill them after actual test SETS. That will create a sparse DB. 
	;	   For now coalesce performance is not calculated
	if typestr["GBL",order="RANDOP" DO
	.   set opfn=^opname(opno)_"^randgbl"
	.   ;	if opno=1  do DUMSET^randgbl
	.   write "Op ",opfn," Starts at:",$ZDate($Horolog,"24:60:SS"),!
	.   do @opfn
	.   ;	if opno=1  do DUMKILL^randgbl
	if typestr["GBL",order="SEQOP" DO
	.   set opfn=^opname(opno)_"^seqgbl"
	.   write "Op ",opfn," Starts at:",$ZDate($Horolog,"24:60:SS"),!
	.   do @opfn
	q
	;
ERROR   set $ZT=""
	ZSHOW "*"
        ZM +$ZS
	Q
