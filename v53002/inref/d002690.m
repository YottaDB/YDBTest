d002690	;
	set ^stop=0
	set jmaxwait=0
	do ^job("child^d002690",5,"""""")
	quit
stop	;
	set ^stop=1
	do wait^job
	quit
child	;
	new max
	set vms=$zv["VMS"
	if vms=1 set updsize=20
	else  set updsize=350
	for i=1:1  quit:^stop=1  do
	.	set type=$r(3)
	.	if type=2 tstart ():serial
	.	if type=1 tstart ():(serial:transaction="BATCH")
	.	set ^x($j,i)=$j(i,updsize)
	.	if type'=0 tcommit
	.	h 0.01
	set max=i-1  for i=1:1:max if ^x($j,i)'=$j(i,updsize) write "VERIFY-E-FAIL : Application verification failed",! zshow "*" halt
	quit
dsechange;
	set vms=$zv["VMS"
	for str="jnlbuffoffset","dskaddr","freeaddr","dskaddroffset"  do
	.	set hex(str)=$ztrnlnm("hex"_str)
	.	set dec(str)=$$FUNC^%HD(hex(str))
	; Calculate new value of dskaddr = freeaddr +/- ("2**1 to 2**25") + 1
	; 1 added to make sure new dskaddr is not aligned with freeaddr
	set add=$r(2)
	set rand=1+$r(25)	; rand = [1 to 25]
	if add set dec("newdskaddr")=dec("freeaddr")+((2**rand)+1)
	if 'add set dec("newdskaddr")=dec("freeaddr")-((2**rand)+1)
	set dec("changeoffset")=dec("jnlbuffoffset")+dec("dskaddroffset")
	for str="newdskaddr","changeoffset"  do
	.	set hex(str)=$$FUNC^%DH(dec(str))
	.	; make sure the cache change command is going to change a non-zero offset to a non-zero value
	.	if 0=dec(str) write "DSECHANGEDSKADDR-E-ZERO : "_str_" is 0. Test error",!
	set file=$ztrnlnm("dsechangescript")
        open file:newversion
        use file
	; seize crit first
	; Write final DSE CACHE CHANGE command (use -nocrit as parent DSE script is holding crit)
	; release crit before quitting 
	if 'vms do
	. write "crit -seize",!
        . write "cache -change -off="_hex("changeoffset")_" -size=4 -val="_hex("newdskaddr"),!
	. write "crit -release",!
	if vms do
	. write "$ DSE",!
	. write "crit /seize",!
        . write "cache /change /off="_hex("changeoffset")_" /size=4 /val="_hex("newdskaddr"),!
	. write "crit /release",!
	. write "quit",!
        close file
	use $p
	zwrite
	quit
