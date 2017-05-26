;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7160
	set $ETRAP="do ERROR^gtm7160"
	new reg,dseout,which
	; %DSEWRAP debugging
	set %DSEWRAP("debug")=1
	;dump the piped commands to a file;zbreak dump+30^%DSEWRAP:"write ""open -file=dse.out"",!"
	; UTF-8 mode on Solaris and HPUX have a bug, use file mode
	if ($zchset="UTF-8")&($select($zversion["Solaris":1,$zversion["HP-UX":1,1:0)) set %DSEWRAP("forcenopipe")=1
	; Choose mode of operation. With a random $piece between 1 and 6 (see the end of the file)
	; DEFAULT on VMS is "$DEFAULT"
	if $zversion["VMS" set randreg=$text(vmsregs^gtm7160)
	else  set randreg=$text(unixregs^gtm7160)
	; Choose which reg to use
	set which=+$zcmdline
	if which=0 set which=1+$random($length(randreg,";")-1)
	; drive dump^%DSEWRAP varying the input parameters, add 1 to avoid the mumps label
	do dump^%DSEWRAP($piece(randreg,";",which+1),.dseout,,"all")
	if '$data(dseout) do ERROR^gtm7160
	for  set reg=$order(dseout($get(reg))) quit:reg=""  do sanitize(.dseout,reg)
	zwrite dseout
	set dbg="gtm7160.dbg" open dbg:newversion use dbg zwrite  close dbg
	quit

sanitize(out,reg)
	set $ETRAP="do ERROR^gtm7160",MASKED="MASKED"
	; santize "Date/Time"
	if 10000>(+$piece(out(reg,"Date/Time"),",",2)) set $piece(out(reg,"Date/Time"),",",2)=".....]"
	set out(reg,"Date/Time")=$$dtmask(out(reg,"Date/Time"))

	; mask all TRUE/FALSE values
	set field=""
	for  set field=$order(out(reg,field)) quit:""=field  do:out(reg,field)?1(1"TRUE",1"FALSE")
	.	set out(reg,field)=MASKED

	; santize "Access method" randomization
	set field="Access method"
	set cmpval=$ztrnlnm("acc_meth") if $length(cmpval)=0 set cmpval="BG"
	set out(reg,field)=(out(reg,field)=cmpval)

	; detect endian "gtm_endian"
	set field="Endian Format"
	set cmpval=$ztrnlnm("gtm_endian"),cmpval=$select(cmpval="LITTLE_ENDIAN":"LITTLE",1:"BIG")
	set out(reg,field)=(out(reg,field)=cmpval)

	; just mask these values
	set fields=$text(mask)
	for i=2:1:$length(fields,";") do
	. set out(reg,$piece(fields,";",i))=MASKED

	; kill fields that don't always show up in the output
	set fields=$text(remove)
	for i=2:1:$length(fields,";") do
	. kill out(reg,$piece(fields,";",i))
	. kill out(reg,$piece(fields,";",i)_" TN") ; some of these have "buddy" fields

	quit

dtmask(str)
	 set str=$translate(str,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","..........................")
	 quit $translate(str,"1234567890","..........")

ERROR
	write $zstatus,!
	zshow "*"
	halt

	; DEFAULT on VMS is "$DEFAULT"
unixregs;*;DEFAULT,AREG,BREG,DEFAULT;DEFAULT,AREG,BREG;DEFAULT,AREG;
vmsregs;*;$DEFAULT,AREG,BREG,$DEFAULT;$DEFAULT,AREG,BREG;$DEFAULT,AREG;
mask;Journal Alignsize;Last GT.M Minor Version;DB Current Minor Version;DB Creation Minor Version;DB Creation Version;Next Epoch_Time;Journal checksum seed;Free Global Buffers;MM defer_time;Journal Before imaging;Journal Epoch Interval;Writer fnd no writes;Blks Last Comprehensive Backup;CAT : # of crit acquired total successes;Database file encryption hash
remove;Total buffer flushes;Writer fnd no writes;DFL : # of Database FLushes;DFS : # of Database FSyncs;wcs_wtstart intent cnt;wcs_wtstart pid count;Calls to wcs_wtstart
