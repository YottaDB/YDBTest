c003407	;
	; Automated testcase for C9L04-003407
	; The intent is to make gvcst_put create new globals using non-TP sets but implicitly convert them to TP
	; because of trigger related changes. This will cause blk-split related info to be initialized in cs_addrs->dir_tree.
	; Because the test induces trigger cycle related restarts (by the concurrent ztriggers), we will ensure the code to
	; clean up the dir_tree blksplit info in tp_clean_up does a good job. V5.4-002A and before used to not clean this
	; up for only the directory tree and fail asserts in tp_clean_up.c line 382 for expression (!chain1.flag)
	;
	set ^stop=0
	set ^njobs=5
	set jmaxwait=0
	do ^job("child^c003407",^njobs,"""""")
	; hang anywhere from 15 to 30 seconds waiting for the tp_clean_up assert codepath to be exercised.
	hang 15+$r(15)
	set ^stop=1
	do wait^job
	quit
	;
child	;
	if jobindex=1  do ztrig
	if jobindex'=1 do manygbls
	quit
	;
ztrig	;
	for i=1:1  quit:^stop=1  do
	.	s X=$ZTRIGGER("ITEM","+^SAMPLE -commands=S -xecute=""w 123"" -name=myname0")	; load a trigger on ^SAMPLE global
	.	s X=$ZTRIGGER("ITEM","-^SAMPLE -commands=S -xecute=""w 123"" -name=myname0")	; load a trigger on ^SAMPLE global
	quit
manygbls;
	; Creates many globals to have huge Directory tree
	set $ztrap="goto incrtrap"
	set template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set start=$extract(template,jobindex)
	set randindex=$r(4)
	set ^randindex(jobindex)=randindex
	for i=1:1  quit:^stop=1  set z="^"_start_i  do oneset
	quit
oneset	;
	set num=123456789.0987654321
	if randindex=0  set x=$incr(@z,num)
	if randindex=1  set @z=$j(i,10)
	if randindex=2  set x=$incr(@z,num_$j(i,900))
	if randindex=3  set @z=$j(i,900)
	quit
incrtrap; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line 
	; ------------------------------------------------------------------------------------------
	set y=$r
	set x=$incr(@y)
	set $ecode=""
	new savestat,mystat,prog,line,newprog
	set savestat=$zstatus
	set mystat=$P(savestat,",",2,100)
	set prog=$P(savestat,",",2,2)
	set line=$P($P(prog,"+",2,2),"^",1,1)
	set line=line+1
	set newprog=$P(prog,"+",1)_"+"_line_"^"_$P(prog,"^",2,3)
	set newprog=$zlevel_":"_newprog
	zgoto @newprog
