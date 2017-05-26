waitchrg(numchild,maxwait,regname);
	;
	; this operates on the region "regname" unless regname="*" in which case it operates on all regions in current gbldir
	;
	; this waits until either of the following conditions becomes false
	;	  (i) numchild is zero or positive and 
	;		"Reference count" (number of attached processes to the database) in the fileheader is > "numchild"
	;	 (ii) numchild is negative and
	;		"Reference count" (number of attached processes to the database) in the fileheader is < "-numchild"
	;	(iii) We have waited for more than "maxwait" seconds
	;
	; Returns
	;	current number of processes attached (excluding this one)
	; Note : this relies on %PEEKBYNAME
	;
	new reg,result,direction,output
	set $ETRAP="set x=$zjobexam(),$ecode="""""
	if $ztrnlnm("save_io") set prevdev=$IO
	set direction=0
	if (numchild<0) set numchild=-numchild,direction=1
	set numchild=numchild+1	; add 1 for this process that attaches to the region below
	if ($data(waitreplic)=1)&($ztrnlnm("test_replic")'="") set numchild=numchild+1
	; Do a DSE all dump to start, redirecting to an appended file in case AIX reuses a PID
	zsystem "$gtm_dist/dse all -dump >>& waitchrgstartingdsealldump.out_"_$job
	set output="waitchrg_"_$job_".out"
	open output:append use output write "reg : direction : refcnt : numchild : total wait : maxwait",! close output
	if regname'="*"  set result=$$waitreg^waitchrg(direction,numchild,maxwait,regname) quit result
	set result=0
	set reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  set result=result+$$waitreg^waitchrg(direction,numchild,maxwait,reg)
	quit result
	;
waitreg(direction,numchild,maxwait,reg)
	new i,line,refcnt,start,totalwait
	set refcnt=numchild,line=""
	set maxwait=maxwait*1E6 ; convert from seconds to microseconds
	set (start,totalwait)=$zut
	for i=1:1 do  quit:((direction=0)&(refcnt'>numchild))!((direction=1)&(refcnt'<numchild))!((totalwait-start)>maxwait)  hang 1
	.	set (refcnt,refcnt(i))=$$^%PEEKBYNAME("node_local.ref_cnt",reg)
	.	set totalwait=$zut
	if $ztrnlnm("save_io") use prevdev
	write "Done Waiting for region ",reg," : Refcnt = ",refcnt-1,!
	if $ztrnlnm("save_io") use $p
	open output:append use output
	for  quit:i>0  set $piece(line," : ",i)=i_"="_refcnt(i),i=i-1
	write reg," : ",direction," : ",refcnt," : ",numchild," : ",(totalwait-start)\1E6," : ",maxwait," :DEBUG ",line,!
	close output
	quit refcnt-1
