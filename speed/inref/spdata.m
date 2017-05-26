spdata; Speed test data
init;
	;
	set ^run=+$ztrnlnm("cur_run")
	set parm=$ztrnlnm("gtm_test_parms")
	set ^typestr=$piece(parm," ",1)
	set ^order=$piece(parm," ",2)
	set ^jnlstr=$piece(parm," ",3)
	set ^jobcnt=$piece(parm," ",5)
	set ^totop=+$piece(parm," ",6)
	set ^repeat=+$piece(parm," ",7)
	;
        set ^totroot=10 ; We have 10 roots in the above
        set ^totname=7	; We have 7 names
	set ^cpuovrhd=0
	set ^elpovrhd=0
	;
	set hostn=$$^findhost(1)
	write "do speed^srvconf("_hostn_")",!  do speed^srvconf(hostn)
	set sizes=sizes(hostn)
	set size=+$piece($extract(sizes,$find(sizes,^typestr)-$length(^typestr),$length(sizes)),"=",2)
	set ^size=size
	set ^sizes(^typestr,^order,^jnlstr)=size
	if +$ztrnlnm("prim_root")=1  set fn="size.txt" open fn:newversion use fn write size close fn
	write "SPEED_TEST:",^typestr,":Starts at:",$ZDate($Horolog,"24:60:SS"),! 
	write "Size = ",size,!
image;
	if $zv["VMS" set ^unix=0
        else  set ^unix=1
        if ^unix  DO
        .  set ^image=$$FUNC^%UCASE($P($ZPARSE("$gtm_exe"),"/",5))
	.  IF ^image="" set ^image="PRO"
        else  DO
        .  set ^image="PRO"
        .  if $ZPARSE("gtm$exe")["BTA"  set ^image="BTA"
        .  if $ZPARSE("gtm$exe")["DBG"  set ^image="DBG"
	;
	; elapsed time is what the speed test primarily cares about.
	; cpu time is also something that we need to monitor but not at that level of detail hence give a bigger tolerance
	;
        set ^cputoler=0.75		;  signal failure only if Ops/CPU_sec     is less than 25% of reference speed
        set ^elptoler=0.92		;  signal failure only if Ops/Elapsed_sec is less than  8% of reference speed
        quit
initcust
        new max,size,i,rnum1,runum2,temp1,temp2
	write "initcust starts at:",$ZDate($Horolog,"24:60:SS"),! 
	set temp=" |0123|4.56|7.8|99|00|!#$%&'()*+,-./|:;<=>?@|ABCDEFGHIJKLMNOPQRSTUVWXYZ|[\]^_`|abcdefghijklmnopqrstuvwxyz|{}~"
	set max=$length(temp)
	set maxslen=max\2
	set size=^size\8
	set ^ctop=size	
        for i=1:1:size DO
	. set begi=1+(i#max)
	. set endi=begi+maxslen
	. set str=$extract(temp,begi,endi)_i
        . set ^tmpcust(str)=i
	set index=""
        for i=1:1:size DO
	. set index=$order(^tmpcust(index))
	. set ^cust(i)=index
	K ^tmpcust
	write "initcust ends at:",$ZDate($Horolog,"24:60:SS"),! 
	Q

