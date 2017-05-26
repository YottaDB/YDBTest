litlab	;
	; Create and zlink a routine over and over containing different literals and labels
	; each time it is created and called. Store the literals and then verify
	; them down the road.
	; Also at the end verify the locals set at each iteration before zlink.
	; At the end try to access labels which has been replaced
	;
	; This tests stp_move() routine of GT.M
	write "------------------------------------------------------------",!
	write "Test of literals, variables and labels for replaced routines",!
	write "------------------------------------------------------------",!
	set debug=$ztrnlnm("GTM$TEST_DEBUGING_TEST_SYSTEM")
	set max=1000
	set maxlab=4
	set comlab=2
	set fn="testReplacedLiteralsAndLabels.m"
	set lcnt1=1
	set lcnt2=1
	write "Generate M routines and run them",!
	for cnt=1:1:max do
	. ; Create the M code on the fly
	. open fn:(NewVersion)
	. use fn
	. set labname="longliteralsandlabels"_cnt_"()"
	. write labname,"; testing replaced literals/labels",!
	. write "       SET literal=""Module ",cnt," of ",max,"""",!
	. write "       SET longliteralvariable9012345678901=""Module ",cnt*10," of ",max,"""",!
	. write "       SET indvar=""longliteralvariable9012345678901""",!
	. write "       SET:'$DATA(counter) counter=0",! 
	. write "       SET counter=counter+1",! 
	. write "       SET routines(counter)=""",labname,"""",!
	. write "       QUIT literal",!
	. for lnum=1:1:maxlab do
	. . write "sublabelno",lcnt1,";",!
	. . write "       set du("_lcnt2,")=","""dummy literal ",lcnt2,"""",!
	. . write "       quit",!
	. . set lcnt1=lcnt1+1
	. . set lcnt2=lcnt2+1
	. set lcnt1=lcnt1-comlab	; So two labels will be common for two versions
	. write "%sublabcommon;",!
	. write "sublabcommon;",!
	. write "       set sublabcommon=",$j,!
	. write "       quit",!
	. close fn
	. ;
	. ; Now execute generated M routine
	. use $PRINCIPAL
	. zlink "testReplacedLiteralsAndLabels.m"
	. ; Following set will accees result returned by function
	. set results("literal",cnt)=$$^testReplacedLiteralsAndLabels()
	. ; Following set will use indirection of 'indvar; to access variable 'longliteralvariable9012345678901''s values
	. set results("indvar",cnt)=@indvar
	. for lnum=lcnt1-comlab:1:lcnt1+1 do
	. . ; Following two lines use label and routine name to run a routine using xecute
	. . set rtnlabname="do sublabelno"_lnum_"^testReplacedLiteralsAndLabels"
	. . xecute rtnlabname
	. do %sublabcommon^testReplacedLiteralsAndLabels
	. set results("sublabcommon",cnt)=sublabcommon
	. ; Execution  of generated M code completed
	. ;
	. if debug'="" do
	. . set command="\mv testReplacedLiteralsAndLabels.m savelit"_cnt_".m"
	. . zsystem command
	. else  do
	. . open fn
	. . close fn
	. . close fn:delete
	write !,"Replaced routines have finished running. Verify results...",!
	set maxerr=10
	set errno=0
	for cnt=1:1:max do  q:errno=maxerr
	. set exprslt="Module "_cnt_" of "_max
	. If exprslt'=$get(results("literal",cnt)) do
	. . write !,"*** Error for results(""literal"") ",cnt,!
	. . write "    Expected result: ",exprslt,!
	. . write "    Computed result: ",$get(results("literal",cnt)),!
	. . set errno=errno+1
	. set temp=cnt*10
	. set exprslt="Module "_temp_" of "_max
	. If exprslt'=$get(results("indvar",cnt)) do
	. . write !,"*** Error for result(""indvar"") ",cnt,!
	. . write "    Expected result: ",exprslt,!
	. . write "    Computed result: ",$get(results("indvar",cnt)),!
	. . set errno=errno+1
	. set exprslt=$j
	. If exprslt'=$get(results("sublabcommon",cnt)) do
	. . write !,"*** Error for results(""sublabcommon"") ",cnt,!
	. . write "    Expected result: ",exprslt,!
	. . write "    Computed result: ",$get(results("sublabcommon",cnt)),!
	. . set errno=errno+1
	for cnt=1:1:lcnt2-1 do  q:errno=maxerr
	. set exprslt="dummy literal "_cnt
	. if $get(du(cnt))'=exprslt do
	. . write !,"*** Error for du ",cnt,!
	. . write "    Expected result: ",exprslt,!
	. . write "    Computed result: ",$get(du(cnt)),!
	. . set errno=errno+1
	if errno'=0 write "Test failed in ",$t(+0),!
	if errno'<maxerr write "Too many errors",!
	if errno=0 write "Verification of literals and variables PASSED",!
	;
errtest;
	set $ZT="set $ZT="""" g litlaberr"
	write "Now try some label which has been replaced. There will be one error at the end",!
	for lnum=lcnt1:-1:lcnt1-maxlab do
	. set routinecall="do sublabelno"_lnum_"^testReplacedLiteralsAndLabels"
	. write routinecall,!
	. xecute routinecall
	quit
litlaberr;
	write $zstatus,!
	q
