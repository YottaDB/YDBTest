drivetp	; ; ; driver program for [tp]resil
	;
	If ^LFE="L"  Set ^light=1
	w "TPRESIL TEST"
	New
	Set output="volktp.mjo0",error="volktp.mje0"
	Open output:newversion,error:newversion
	Use output
	Set kx=0,cnt=0
	Set unix=$ZVersion'["VMS"
	New $ZTrap Set $ZTrap="Set cnt=cnt+1 Use error ZSHOW ""*"" Write ! Use output ZGoto "_$ZLevel_":error^drive"
	Set ^JOB=0
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo1":error="volktp.mje1")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo1":error="volktp.mje1")  Hang 10
	Do in0^dbfill("set")
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo2":error="volktp.mje2")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo2":error="volktp.mje2")  Hang 10
	Do in0^dbfill("ver")
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo3":error="volktp.mje3")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo3":error="volktp.mje3")  Hang 10
	Do in1^dbfill("set")
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo4":error="volktp.mje4")  Hang 10
Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo4":error="volktp.mje4")  Hang 10
	Do in1^dbfill("ver")
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo5":error="volktp.mje5")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo5":error="volktp.mje5")  Hang 10
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo6":error="volktp.mje6")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo6":error="volktp.mje6")  Hang 10
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo7":error="volktp.mje7")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo7":error="volktp.mje7")  Hang 10
	If unix Job ^volktp($View("gdscert")):(output="volktp.mjo8":error="volktp.mje8")  Hang 10
	Else  Job ^volktp($View("gdscert")):(nodetached:startup="startup.com":output="volktp.mjo8":error="volktp.mje8")  Hang 10
error	For kx=kx+1:1:25  Quit:^JOB=0  Do in2^dbfill("set"),in2^dbfill("ver"),in2^dbfill("kill")  Hang 60
	Set $ZTrap=""
	Write !,$Select(cnt:"FAIL",1:"COMPLETE")," from ",$T(+0)
	Close output
	If cnt Close error
	Else  Close error:delete
	Halt
