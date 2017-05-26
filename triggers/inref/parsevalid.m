parsevalid
	quit

MT
	do ^echoline
	write "Testing with empty but non-null file",!
	do text^dollarztrigger("MTfile^parsevalid","MT.trg")
	quit

deleteall
	do ^echoline
	set x=$ztrigger("ITEM","-*")
	if x=0 write "Unabled to delete all triggers with -*",!
	quit

autonameincr
	for i=1:1:8  do
	.	set line=$text(tfile+i^parsevalid)
	.	set $extract(line,1,2)=""
	.	write line,!
	.	tstart ()
	.	write $ztrigger("i",line)
	.	tcommit
	quit

zload
	set file=$zcmdline
byfile
	set x='$ztrigger("file",file)
byitem
	open file:readonly
	use file
	for  quit:$zeof  read line  do
	.	use $p
	.	set fchar=$extract(line,1)
	.	if $select(fchar="-":1,fchar="+":1,1:0)  do
	.	.	set x=$ztrigger("item",line)
	.	.	if 'x  write "FAILED: ",line,!
	. 	use file
	close file
	quit

show
	use $p
	if '$ztrigger("select") write "Select failed",!
	write !
	quit

MTfile
	;; This file is empty
	;
	;; need to test what happens when there are no triggers in a file
	;
	quit

tfile
	;+^namemonoincr(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=$char(32)
	;+^namemonoincr(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -delim="`" -piece=1;20
	;-^namemonoincr(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=" "
	;+^namemonoincr(t=:;$char(42),*,t2=?.e,t3=","","",")   -commands=s,k,zk,zw -xecute="do ^twork" -options=i -options=noi,noc -delim=$char(96) -piece=1;20
	;+^namemonoincr(t=:;$char(42),*,t2=?.e,t3=","","",")   -commands=set -xecute="do ^twork" -options=i -options=noi,noc
	;+^namemonoincr(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=" "
	;-^namemonoincr(t=:;;*;;?.e,*;,t2=;;?.e,t3=","","",";;)	-commands=set -xecute="do ^twork" -options=noi,noc -piece=1 -delim=" "
	;-^namemonoincr(t=:;$char(42),*,t2=?.e,t3=","","",")   -commands=s,k,zk,zw -xecute="do ^twork" -options=i -options=noi,noc -delim=$char(96) -piece=1;20
	quit
