lblconf ;
	; This script returns back the label names for the speed reference file.
	; The name of the label returned is dependent on the parameters passed in the test configuration
	; At present access method and "replication" are the parameters it is dependent on.
	set unix=$ZVersion'["VMS"
	set accmeth=$ztrnlnm("acc_meth")
	set repl=$ztrnlnm("speed_replic")
	set label("BG","REPL")="data1"
	set label("BG","NOREPL")="data2"
	set label("MM","REPL")="data3"
	set label("MM","NOREPL")="data4"

