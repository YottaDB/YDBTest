upgrdtst;
	; this test tries to create a lot of too-full blocks at all levels and both in the GVT and Directory Tree
	; too-full => the block has less than 8 bytes (9 in VMS) of free space
	;	   => this block needs to be identified by V5CERTIFY PHASE-1 and split by V5CERTIFY PHASE-2
	; this is needed in order to test the V5CERTIFY code that is being developed for the DATABASE UPGRADE part of
	;	the 64bit-tn project (D9E03-002438)
set	;
	do setdirt
	do setgvt
	quit
replay  ;
	set unix=$ZVersion'["VMS"
	if ""=$ztrnlnm(type) set @type=20+$random(num)
	else  set @type=$ztrnlnm(type)
        if unix set file="settings.csh"
        else  set file="settings.com"
        open file:(append)
        use file
	if unix write "setenv "_type_" "_@type,!
	else  write "$define /nolog "_type_" "_@type,!
	close file
	quit
setdirt	;
	new action
	do replay
	set ^dirtend=1+@type
	write "--> Number of globals in directory tree : ",^dirtend,!
	set action="set"
	do dirtloop
	quit
setgvt	;
	new action
	do replay
	set ^gvtend=1+@type
	write "--> Number of records in global variable tree : ",^gvtend,!
	set action="set"
	do gvtloop
	quit
verify	;
	do verdirt;
	do vergvt;
	quit
verdirt	;
	new action
	set action="ver"
	do dirtloop
	quit
vergvt	;
	new action
	set action="ver"
	do gvtloop
	quit
common	;
	set prime=50000017	;Precalculated
	set root=5		;Precalculated
	quit
gvtloop	;
	new maxerr,fl,str,i,value,num
	do common
	if $data(gvname)=0   new gvname   set gvname="^x"
	if $data(startidx)=0 new startidx set startidx=1
	if $data(endidx)=0   new endidx   set endidx=^gvtend
	set fl=0
	set maxerr=10
	set num=root
	for i=startidx:1:endidx  do  quit:(fl>maxerr)
	.	set num=(num*root)#prime
	.	set str=$$^genstr(num)
	.	set value=$justify(i#100,i#2+1)
	.	if action="set" set @gvname@(str)=value
	.	if (action="ver")&($GET(@gvname@(str))'=value) do
	.	.	write "Verify Fail: i=",i," num=",num," ",gvname,"("_str_")=",$GET(@gvname@(str))," Expected=",value,! set fl=fl+1
	if (action="ver") do
	.	if (fl>maxerr) write "Too many errors ",!
	.	if (fl=0)      write " --> Verify all Global Variable Tree : PASS",!
	.	if (fl'=0)     write " --> Verify all Global Variable Tree : FAIL",!
	quit
dirtloop;
	new maxerr,fl,str,i,value,num
	do common
	if $data(startidx)=0 new startidx set startidx=1
	if $data(endidx)=0   new endidx   set endidx=^dirtend
	set fl=0
	set maxerr=10
	set num=root
	for i=startidx:1:endidx  do  quit:(fl>maxerr)
	.	set num=(num*root)#prime
	.	set str=$$^gengvn(num)
	.	set value=$justify(i#10,i#100+1)
	.	set xstr="^"_str
	.	if action="set" set @xstr=value
	.	if (action="ver")&($GET(@xstr)'=value) do
	.	.	write "Verify Fail: i=",i," num=",num," ",xstr,"=",$GET(@xstr),",Expected=",value,! set fl=fl+1
	if (action="ver") do
	.	if (fl>maxerr) write "--> Verify Directory Tree : Too many errors ",!
	.	if (fl=0)      write " --> Verify Directory Tree : PASS",!
	.	if (fl'=0)     write " --> Verify Directory Tree : FAIL",!
	quit
setbig	;
	; create too-large records all of which will fit in V4 blocks but only some will fit in V5 blocks
	; ^biggbl(1) and ^biggbl(2) will fit just right in a 512-byte sized V5 block
	; ^biggbl(3) until ^biggbl(10) should not fit in a 512-byte sized V5 block
	; ^biggbl(11) and ^biggbl(12) will fit just right in a 512-byte sized V5 block
	;
	do setgood
	do setbad
	quit
initbig ;
        ; The following is called as part of "setdirt" to ensure the global name "^biggbl" is part of the directory tree
        ; as part of the v4dbprepare.csh/.com script. This will have the effect of creating a global in the Directory Tree
        ; and Global Variable Tree but removing it only from the GVT. The DT will thus have the global name as part of
        ; v4dbprepare thereby we would have done dbcertify on it. The later setbig^upgrdtst should not update the DT
        ; as the global name already exists there. It will update only the GVT.
        ;
        set ^biggbl=1
        kill ^biggbl
        quit
setgood	;
	new i
	for i=1,2,11,12 set ^biggbl(i)=$justify(i,480+((i-1)#10))
	quit
setbad	;
	new i
	for i=3:1:10 set ^biggbl(i)=$justify(i,480+((i-1)#10))
	quit
killbig	;
	; kill only the too-large records (i.e. biggbl(3) upto biggbl(10) instead of all ^biggbl(i))
	; this is because ^biggbl(1) and ^biggbl(2) will fit JUST TIGHT in a V5 512-byte sized block that
	; we want to test that this boundary condition is handled right by the MUPIP REORG UPGRADE and/or GTM logic
	;
	new i
	for i=3:1:10 kill ^biggbl(i)
	quit
vrfybig	;
	new i,expec,fl
	set fl=0
	for i=1,2,11,12  do
	.	set actual=$get(^biggbl(i))
	.	set expec=$justify(i,480+((i-1)#10))
	.	if actual'=expec  write "Verify Fail: ^biggbl(",i,")=",actual,",Expected=",expec,! set fl=fl+1
	for i=3:1:10  do
	.	set actual=$get(^biggbl(i))
	.	set expec=""
	.	if actual'=expec  write "Verify Fail: ^biggbl(",i,")=",actual,",Expected=",expec,! set fl=fl+1
	if (fl=0)      write " --> Verify Directory Tree : PASS",!
	if (fl'=0)     write " --> Verify Directory Tree : FAIL",!
	quit
