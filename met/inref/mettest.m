drive	;
	set unix=$ZVersion'["VMS"
	if unix  set ^dtloop=25,numjobs=8
	if 'unix set ^dtloop=10,numjobs=4
	;
	set jmaxwait=0	; do not wait for children so that ^%jobwait(jobid,jobindex) gets filled with PIDs used by checkdb
	set jobid=$ztrnlnm("gtm_test_jobid")
	do ^job("dtsub^mettest",numjobs,"""""")

	set jmaxwait=14400	; wait for max of 4 hours for children to be done
	do wait^job

	do checkdb	; do application level data integrity check
	quit

dtinit	;
        set SIZ=4000 ; 10000
        kill ^LJPTBL1,^LJPTBL2,^LJPTBL3,^LJPTBL4,^LJPLOG
        set P1="F111111111111111111111111111111111111111111111111111111111111111Z"
        set P2="F222222222222222222222222222222222222222222222222222222222222222Z"
        set P3="F333333333333333333333333333333333333333333333333333333333333333Z"
        set P4="F444444444444444444444444444444444444444444444444444444444444444Z"
        set FILL=P1_P2_P3_P4
        set ^LJPSIZ=SIZ
	set ^LJPFILL=FILL
	set ^LJPTBLMX=1000000
	set ^LJPLOGSTR="ALLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLZ"
	for I=0:1:SIZ do
	. set ^LJPTBL1(I,"1A")=I,^LJPTBL1(I,"1B")=FILL
	. set ^LJPTBL2(I,"2A")=-I,^LJPTBL2(I,"2B")=FILL
	. set ^LJPTBL3(I,"3A")=I*2,^LJPTBL3(I,"3B")=FILL
	. set ^LJPTBL4(I,"4A")=-I*2,^LJPTBL4(I,"4B")=FILL
	quit

dtsub	;
	set $ZT="set $ZT="""" goto ERROR"
	view "GDSCERT":1
	write "$view(""GDSCERT"")=",$view("GDSCERT"),!
	set istp=$random(2)
	write "istp = ",istp,!
	set isminortp=$random(2)*istp	; whether we will do each M-line inside of a TP fence
	set ismajortp=istp-isminortp	; whether we will do an entire chunk of M-code inside of a TP fence
	write "isminortp = ",isminortp,!
	write "ismajortp = ",ismajortp,!
	set isnoisol=$random(2)
	write "isnoisol = ",isnoisol,!
	if isnoisol view "NOISOLATION":"^LJPLOG"
	write "$view(""NOISOLATION"",""^LJPLOG"")=",$view("NOISOLATION","^LJPLOG"),!
	;
	; GTM V44004 onwards try randomly enabling duplicate set optimization
	set dupsupp=0	; by default support for duplicate set optimization is not there
	if $piece($zv," ",2)]"V4.4-003Z" set dupsupp=1	;for V44004 onwards, support for the optimization is there
	set isdupset=0
	if dupsupp=1 set isdupset=$random(2)
	write "isdupset = ",isdupset,!
	if isdupset=1 view "GVDUPSETNOOP":1
	if dupsupp=1 write "$view(""GVDUPSETNOOP"")=",$view("GVDUPSETNOOP"),!
	;
	set dtloop=^dtloop
	set ljplogstr=^LJPLOGSTR
	for L=1:1:dtloop do
	.	write $J_" "_L_" "_$ZD($H,"12:60:SS AM"),!
	.	;;write "--> L = ",L,!
	.	if ismajortp=1 tstart ():serial
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LA")=$H_" "_^LJPSIZ
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LB")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LC")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LD")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LE")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LJ")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LI")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LH")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LG")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if isminortp=1 tstart ():serial
	.	set ^LJPLOG($J,L,"LF")=ljplogstr
	.	if isminortp=1 tcommit
	.
	.	if ismajortp=1 tcommit
	.
	.	; Scan existing records
	.	set rand=$random(4)
	.	;;write "  -> rand = ",rand,!
	.	for I=1:1:rand do
	.	.	set R=$R(^LJPSIZ)
	.	.	;;write "    -> I = ",I," : R = ",R,!
	.	.
	.	.	if ismajortp=1 tstart ():serial
	.	.
	.	.	if isminortp=1 tstart ():serial
	.	.	if ^LJPTBL1(R,"1A")'=-^LJPTBL2(R,"2A") write !,$J," ",R," ",^LJPTBL1(R,"1A")," ",^LJPTBL2(R,"2A")
	.	.	if isminortp=1 tcommit
	.	.
	.	.	set rand1=$random(100)
	.	.	;;write "      -> rand1 = ",rand1,!
	.	.	if isminortp=1 tstart ():serial
	.	.	set ^LJPTBL1(R,rand1)="this is set 1 xxxxxxxxxxxxxxxxxxxxxxxxxxx"
	.	.	if isminortp=1 tcommit
	.	.
	.	.	set rand2=$random(100)
	.	.	;;write "      -> rand2 = ",rand2,!
	.	.	if isminortp=1 tstart ():serial
	.	.	set ^LJPTBL2(R,rand2)="this is set 2 xxxxxxxxxxxxxxxxxxxxxxxxxxx"
	.	.	if isminortp=1 tcommit
	.	.
	.	.	if isminortp=1 tstart ():serial
	.	.	if ^LJPTBL3(R,"3A")'=-^LJPTBL4(R,"4A") write !,$J," ",R," ",^LJPTBL3(R,"3A")," ",^LJPTBL4(R,"4A")
	.	.	if isminortp=1 tcommit
	.	.
	.	.	set rand3=$random(100)
	.	.	;;write "      -> rand3 = ",rand3,!
	.	.	if isminortp=1 tstart ():serial
	.	.	set ^LJPTBL3(R,rand3)="this is set 3 xxxxxxxxxxxxxxxxxxxxxxxxxxx"
	.	.	if isminortp=1 tcommit
	.	.
	.	.	set rand4=$random(100)
	.	.	;;write "      -> rand4 = ",rand4,!
	.	.	if isminortp=1 tstart ():serial
	.	.	set ^LJPTBL4(R,rand4)="this is set 4 xxxxxxxxxxxxxxxxxxxxxxxxxxx"
	.	.	if isminortp=1 tcommit
	.	.
	.	.	if ismajortp=1 tcommit
	.
	.	; Modify a pair of records
	.	set R=$R(^LJPSIZ) set V=$R(^LJPTBLMX)
	.	;;write "  -> R = ",R," : V = ",V,!
	.
	.	if istp=1 tstart ():serial
	.	set ^LJPTBL1(R,"1A")=V,^LJPTBL2(R,"2A")=-V
	.	if istp=1 tcommit
	quit

checkdb	;
	set fl=0
	;-------------------------------------------------------------------------------------------------------------------
        ; Verify content of ^LJPTBL1,^LJPTBL2,^LJPTBL3,^LJPTBL4. Actual content cannot be verified currently for 1A and 2A.
	;-------------------------------------------------------------------------------------------------------------------
	;
        set size=^LJPSIZ
	set max=^LJPTBLMX
	set FILL=^LJPFILL
	;
	for I=0:1:size do
	.	set val=$get(^LJPTBL1(I,"1A"),-1)
	.	if (val<0)!(val'<max) write "Verify Fail: ^LJPTBL1(",I,",""1A"")=",val," Expected=1 to ",max,! set fl=fl+1
	.
	.	set val=$get(^LJPTBL2(I,"2A"),1)
	.	set val=-val
	.	if (val<0)!(val'<max) write "Verify Fail: ^LJPTBL2(",I,",""2A"")=",-val," Expected=-1 to -",max,! set fl=fl+1
	.
	.	set val=$get(^LJPTBL3(I,"3A"))
	.	if val'=(I*2) write "Verify Fail: ^LJPTBL3(",I,",""3A"")=",val," Expected=",(I*2),! set fl=fl+1
	.
	.	set val=$get(^LJPTBL4(I,"4A"))
	.	if val'=-(I*2) write "Verify Fail: ^LJPTBL4(",I,",""4A"")=",val," Expected=",-(I*2),! set fl=fl+1
	.
	.	set val=$get(^LJPTBL1(I,"1B"))
	.	if val'=FILL write "Verify Fail: ^LJPTBL1(",I,",""1B"")=",val," Expected=",FILL,! set fl=fl+1
	.
	.	set val=$get(^LJPTBL2(I,"2B"))
	.	if val'=FILL write "Verify Fail: ^LJPTBL2(",I,",""2B"")=",val," Expected=",FILL,! set fl=fl+1
	.
	.	set val=$get(^LJPTBL3(I,"3B"))
	.	if val'=FILL write "Verify Fail: ^LJPTBL3(",I,",""3B"")=",val," Expected=",FILL,! set fl=fl+1
	.
	.	set val=$get(^LJPTBL4(I,"4B"))
	.	if val'=FILL write "Verify Fail: ^LJPTBL4(",I,",""4B"")=",val," Expected=",FILL,! set fl=fl+1
	;
	;-----------------------------
	; Verify content of ^LJPLOG
	;-----------------------------
	;
	set dtloop=^dtloop
	set ljplogstr=^LJPLOGSTR
	set jobid=$ztrnlnm("gtm_test_jobid")
	set njobs=^%jobwait(jobid,"njobs")
	for i=1:1:njobs do
	.	set pid=^%jobwait(jobid,i)
	.	for L=1:1:dtloop do
	.	.	set val=$get(^LJPLOG(pid,L,"LA")) 
	.	.	set val1=$piece(val," ",1)
	.	.	if $piece(val," ",2)'=size do
	.	.	.	write "Verify Fail: ^LJPLOG(",pid,",",L,",""LA"")=",val," Expected=",val1_" "_size,! set fl=fl+1
	.	.	for j="LB","LC","LD","LE","LF","LG","LH","LI","LJ" do
	.	.	.	set val=$get(^LJPLOG(pid,L,"LB"))
	.	.	.	if val'=ljplogstr do
	.	.	.	.	write "Verify Fail: ^LJPLOG(",pid,",",L,",""LA"")=",val," Expected=",ljplogstr,! set fl=fl+1
	;
	;------------------------------------------------------------------------------------------------------
	; If verification found errors, create file checkdb_err_'jobid'.txt so parent script can stop the test
	;------------------------------------------------------------------------------------------------------
	;
	if (fl'=0) do
	.	set file="checkdb_err_"_jobid_".txt"
	.	open file
	.	use file
	.	write "checkdb found errors. see outstream.log for details",!
	.	close file
	.	use $p
	quit

ERROR	zshow "*"
	if $tlevel trollback
	quit
