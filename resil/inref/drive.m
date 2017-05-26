drboth	; ; ; driver program for [tp]resil
	;
	If ^LFE="L"  Set ^light=1
	New
	if ^tp="NON_TP" Set function="volkill"  w "RESIL TEST",!
	Else  Set function="volktp"  w "TPRESIL TEST",!
	Set output=function_"0.mjo0",error=function_"0.mje0"
	Open output:newversion,error:newversion
	Use output
	Set cnt=0
	New $ZTrap Set $ZTrap="Set cnt=cnt+1 Use error ZSHOW ""*"" Write ! Use output ZGoto "_$ZLevel_":error^drive"
	Set jmaxwait=0
	Set jobid=1 Do ^job(function,1,$View("gdscert")) Hang 10
	Do in0^dbfill("set")
	Set jobid=2 Do ^job(function,1,$View("gdscert")) Hang 10
	Do in0^dbfill("ver")
	Set jobid=3 Do ^job(function,1,$View("gdscert")) Hang 10
	Do in1^dbfill("set")
	Set jobid=4 Do ^job(function,1,$View("gdscert")) Hang 10
	Do in1^dbfill("ver")
	Set jobid=5 Do ^job(function,4,$View("gdscert")) Hang 10
	For kx=1:1:25 Quit:'$$numjobs  Do in2^dbfill("set"),in2^dbfill("ver"),in2^dbfill("kill") write "$h = ",$h,! Hang 60
	If $$numjobs Do wait^job
	Set $ZTrap=""
	Write !,$Select(cnt:"FAIL",1:"COMPLETE")," from ",$T(+0)
	Close output
	If cnt Close error
	Else  Close error:delete
	Halt
numjobs()	; Count number of children still running
	new cnt,jobid
	s cnt=0 for jobid=1:1:5 s cnt=cnt+$$childcnt^job
	q cnt
