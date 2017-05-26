c002655	;
	; test that a TP transaction creating a huge number of global variables does not corrupt the database
	; the following test assumes 512-byte GDS block size and 16K global buffers.
	;
	quit
set	;
	set act="set"
	do action
	quit
verify	;
	set act="ver"
	do action
	quit
action	;
	set $ztrap="write $zstatus,!  halt"
	view "GDSCERT":1
	new i,str,actual,expec,fl
	set fl=0
	set prefix="^abc"
	tstart ():serial
	for i=1:3:9000  do
	.	set str=prefix_i
	.	if act="set" set @str=str
	.	if act="ver" do
	.	.	set actual=$get(@str)
	.	.	set expec=str
	.	.	if actual'=expec write "Verify Fail: ",prefix,i,"=",actual,",Expected=",expec,! set fl=fl+1
	tcommit
	if (act="ver") do
	.	if (fl=0)      write " --> Verify Directory Tree : PASS",!
	.	if (fl'=0)     write " --> Verify Directory Tree : FAIL",!
	quit
