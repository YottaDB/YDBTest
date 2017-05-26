maxsubslen
	do init
	do writefile
	quit

init
	write "Testing triggers with 8192 charactes and more subscripts",!
	; get the current key size
	set key="key.pipe"
	; open key:(command="$GDE show -region DEFAULT | $tst_awk '{if ($1 ~ /DEFAULT/){print $5}}'":stderr="key.err")::"pipe"
	open key:(command="$gtm_exe/mumps -run ^GDE show -region DEFAULT | awk '{if ($1 ~ /DEFAULT/){print $5}}'":stderr="key.err")::"pipe"
	use key
	read size
	use $p
	write "Key size is ",size,!
	do initalphanum
	set allsubs=$$getsubs(8192)
	write "subscript length ",$length(allsubs),!
	write "subscripts ",$length(allsubs,","),!
	quit

writefile
	; write the trigger file
	set file="maxsubslen.trg" open file:newversion use file 
	write "; acceptable ",$length(allsubs),!
	write "+^Z(",allsubs,") -commands=S -xecute=""do ^twork""",!
	close file
	set allsubs=allsubs_",""this is a length test of the entire line to show that this should not happen at any time"""
	write "overlong ",$length(allsubs),!
	set file="overmaxsubslen.trg" open file:newversion use file 
	write "; overlong ",$length(allsubs),!
	write "+^Z(",allsubs,") -commands=S -xecute=""do ^twork""",!
	close file
	quit

ztrsave(file,allsubs)
	use file
	write "; subslength=",$length(allsubs)," subscount=",$length(allsubs,","),!
	write "+^Z(",allsubs,") -commands=S -xecute=""do ^twork""",!
	use $p
	quit

ztrmain
	new file,output,fail
	do init
	set file="ztrtest.trg",output="ztrtest.outx",selectoutput="ztrtest.select"
	open file:newversion open output:newversion open selectoutput:newversion
	;
	; ztrigger load the acceptably long trigger from the file test 8192 subs
	do ztrsave^maxsubslen(file,allsubs)
	write !,"ztrigger the acceptably long trigger matching the file test",!
	set item="+^Z("_allsubs_") -commands=S -xecute=""do ^twork"""
	if '$ztrigger("item",item) write "FAIL",!
	;
	; ztrigger load unacceptably long triggers from 8193 up to 8292
	; the loop from 1 to 100 is supposed to fail on the first iteration
	; In the dark ages of trigger bugs, looping from 1 to 100 did not fail
	; on the first iteration
	write !,"ztrigger load unacceptably long triggers from 8193 and up",!
	set fail=1
	for i=1:1:100  quit:'fail  do
	. ; the first subscript is 10, multiply by 10 to append one more character
	. set $piece(allsubs,",",1)=$piece(allsubs,",",1)*10
	. do ztrsave^maxsubslen(file,allsubs)
	. set item="+^Z("_allsubs_") -commands=S -xecute=""do ^twork"""
	. ; save the noisy output of ztrigger somewhere else
	. use output
	. set fail=$ztrigger("item",item)
	. use $p ; for each iteration report whether the test passed or failed
	. if fail write "FAIL",i,!
	. if 'fail  do
	. . write "PASS:",$length(allsubs),!
	. . close output
	. . open output:readonly
	. . use output
	. . read line
	. . use $p
	. . write line,!
	; write the loaded triggers back out to a file
	use selectoutput
	if '$ztrigger("select") use $p write "error in select",!
	close file,output,selectoutput
	quit

	; this routine reads the second line of the trigger output file ztrtest.trg
	; and the select output file ztrtest.outx and compares their lengths. Both
	; lines are the same trigger and should be the same length.
ztrvalidate
	set done=0 ; needed this little hack to run this script inside and outside the maxparse_base.csh script
	write !,!,"Compare loaded trigger length to select output trigger length",!
	set trgfile="ztrtest.trg",selectoutput="ztrtest.select"
	open trgfile:readonly
	use trgfile
	for i=1:1:2 read line
	set origtrglen=$length(line)
	open selectoutput:readonly
	use selectoutput
	for i=1:1:6  quit:done  read line if $extract(line,1,4)="+^Z(" set done=1
	set selecttrglen=$select(done:$length(line),1:0)
	close trgfile,selectoutput
	use $p
	if origtrglen=selecttrglen write "PASS",!
	if origtrglen'=selecttrglen write "FAIL: wrote ",origtrglen," but select shows only ",selecttrglen,!
	write !,!
	quit

	; set k=32 for i=k:1:126 write i_":"_$char(i)_$char(9) if (i-k)#9=8 write !
initalphanum
	new i
	for i=48:1:57  do
	. set alphanum($incr(ascii))=$char(i)
	for i=65:1:90  do
	. set alphanum($incr(ascii))=$char(i)
	for i=97:1:122  do
	. set alphanum($incr(ascii))=$char(i)
	set ascii=ascii+1
	quit

alphanum(i)
	new index
	set index=i#ascii
	quit alphanum(index)

getsubs(len)
	new subs,i
	set subs=""
	for i=1:1:31 quit:$length(subs)>len  do
	.	set lead=$$alphanum(i+10)
	.	set csubs=""
	.	for j=1:1:62 quit:($length(subs)+$length(csubs))>len  do
	.	.	set $piece(csubs,";",j)=$char(34)_lead_$$alphanum(j)_$char(34)
	.	set $piece(subs,",",i)=csubs
	; since M always puts us over, drop back to the desired length
	if $length(subs)>8192  do
	.	set found=$length(subs)
	.	for i=-1:-1:-20  quit:found'=$length(subs)  set found=$find(subs,";",found+i) set:'found found=$length(subs)
	.	set found=found-2 ; need to clear the last semicolon
	.	set subs=$extract(subs,1,found)
	; append a number in the last GVN position to pad the length
	if ($length(subs)+2)<8193  do
	.	set more=8190-$length(subs)
	.	set subs="1"_$translate($justify("",more)," ","0")_","_subs
	quit subs

