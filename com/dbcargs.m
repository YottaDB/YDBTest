;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dbcargs
	set dbcargs=$ztrnlnm("gtm_test_dbcargs")
	if dbcargs'="" write dbcargs,! quit				; REPLAY
	if $zcmdline'?.e1(1N1"-"1N,1N1","1N).e write $zcmdline,! quit 	; nothing to randomize
	; DEFAULTS
	set debug=+$ztrnlnm("gtm_test_debug")
	set blockspan=+$ztrnlnm("gtm_test_spannode")
	set $ETRAP="do error"
	if debug>0 set debugfile="dbcargs.debug" open debugfile:append
	; GT.M Version - gtm_ver is set by sr_unix/setactive.csh
	set version=+$tr($ztrnlnm("gtm_verno"),"V.-ABCDEFG","")
	if version=0 set version=+$tr($piece($zversion,$char(32),2),"V.-ABCDEFG","")
	if version<1000 set version=version*100  ; development versions are considered the highest
	if version<60000 set blockspan=0 if debug use debugfile zwrite version,blockspan  use $p
	; work
	do parseargs
	do randomize
	do writeargs
	if debug>0 close debugfile
	quit

	; dbcreate argument parsing matches the AWK code from test/com_u/dbcreate_multi.awk
parseargs
	set cmdline=$$FUNC^%LCASE($zcmdline),argc=$length(cmdline," ")	;
	set defargs=$piece($text(defargs^dbcargs),";",2)
	for i=1:1:argc do
	.	set KV=$piece(cmdline," ",i)
	.	;if KV'?1"-".(1L,1"_").1"=".N set args($piece(defargs," ",i))=KV quit
	.	if KV'?1"-".e set args($piece(defargs," ",i))=KV quit
	.	set key=$piece(KV,"=",1),$extract(key,1,1)="",value=$piece(KV,"=",2)
	.	; handle flags first
	.	if (key?1"imptp".e) set imptp=1 quit
	.	; start dbcreate_multi.awk like argument parsing
	.	if (key?1"f".e)&($length(value)) set args("name_override")=value quit
	.	if (key="name_override")&($length(value)) set args("name_override")=value quit
	.	if (key="different_gld") set args("different_gld")=1 quit
	.	if (key="gld_has_db_fullpath") set args("gld_has_db_fullpath")=1 quit
	.	if (key="n_regions")&($length(value)) set args("n_regions")=value quit
	.	if (key?1"k".e)&($length(value)) set args("key_size")=value quit
	.	if (key?1"rec".e)&($length(value)) set args("record_size")=value quit
	.	if (key?1"bl".e)&($length(value)) set args("block_size")=value quit
	.	if (key?1"al".e)&($length(value)) set args("allocation")=value quit
	.	if (key?1"glo".e)&($length(value)) set args("global_buffer_count")=value quit
	.	if (key?1"e".e)&($length(value)) set args("extension_count")=value quit
	.	if (key?1"res".e)&($length(value)) set args("reserved_bytes")=value quit
	.	if (key?1"c".e)&($length(value)) set args("collation_default")=value quit
	.	if (key?1"acc_meth_env".e)&($length(value)) set args("acces_meth_env")=$$FUNC^%UCASE(value) quit
	.	if (key?1"acc_meth".e)&($length(value)) set args("acces_method")=$$FUNC^%UCASE(value) quit
	.	if (key?1"freeze".e) set args("freeze")="-inst_freeze_on_error" quit
	.	if (key?1"nofreeze".e) set args("freeze")="-noinst_freeze_on_error" quit
	.	if (key?1"qdbr".e) set args("qdbrundown")="-qdbrundown" quit
	.	if (key?1"noqdbr".e) set args("qdbrundown")="-noqdbrundown" quit
	.	if (key?1"test_gtcm".e)&($length(value)) set args("test_gtcm")=value quit
	.	if (key?1"tem".e)&($length(value)) set args("template")=value quit
	.	if (key?1"test_collation".e)&($length(value)) set args("test_collation")=value quit
	.	if (key?1"stats".e) set args("test_stats")="-stats" quit
	.	if (key?1"nostats".e) set args("test_stats")="-nostats" quit
	.	if (key?1"stdnull".e) set args("test_stdnull_collation")="-stdnull" quit
	.	if (key?1"nostdnull".e) set args("test_stdnull_collation")="-nostdnull" quit
	.	if (key?1"n".e) set args("null_subscripts")=$select($length(value):value,1:"NOVAL") quit  ; this is what dbcreate_multi.awk does
	.	do writeout("TEST-W-WARN: undefined key used in randomization","args("_key_"))="_value)
	if debug>0 use debugfile zwrite args  use $p
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; print out dbcreate arguments that match the usual usage such as:
	;        $gtm_tst/com/dbcreat.csh mumps 1
	;        $gtm_tst/com/dbcreat.csh mumps 1 125 256 512 -<some opt>
	;        $gtm_tst/com/dbcreat.csh mumps 1 125 256 512
	; By producing the same arguments, we can simply compare the argument
	; strings before and after randomization to determine if the args
	; were randomized.
writeargs
	set argc=0
	for i=1:1:$length(defargs," ")  do  ; in the order of default args, cycle through the discovered args and dump out values
	.	set key=$piece(defargs," ",i)
	.	if ($data(args(key))>0) do
	.	.	set argc=argc+1
	.	.	set $piece(args," ",argc)=args(key)
	.	.	if (argc'=i) set $piece(args," ",argc)="-"_key_$select($length(args(key))=0:"",1:"="_args(key))
	.	.	if (key="test_stdnull_collation") set $piece(args," ",argc)=args(key)
	.	zkill args(key)
	write args,!
	quit

	; print out a nicely formartted arg string
writeprettyargs
	set key="" for i=1:1  set key=$order(args(key))  quit:key=""  set $piece(args," ",i)="-"_key_"="_args(key)
	quit

	; write debug message to dbcargsrandomizer.out
writeout(msg,somevar)
	new file
	set file="dbcargsrandomizer.out"
	open file:append
	use file
	write $zdate($horolog,"MON DD 24:60:SS","Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec"),?16,$select('$data(msg):"",1:msg)," "
	if $data(somevar) zwrite somevar
	else  write !
	close file
	use $p
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; in case of an error, do not cause dbcreate to fail, do a zshow "*"
	; dump and write out the unrandomized arguments
error
	new file
	set file="dbcargsrandomizer.out"
	open file:append
	use file
	write "TEST-W-WARN: dbcreate randomization failed, backing off to $zcmdline",!
	write $zstatus
	zwrite
	close file
	use $p
	set $ecode=""
	do norandom
	halt

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; de-randomization use this for error handling
	; the assumption is that the minimum values satisfy the
	; key/record/block constraints
norandom
	new argc,cmdline
	if $zcmdline'?.e1(1N1"-"1N,1N1","1N).e write $zcmdline,! quit 	; nothing to randomize
	set cmdline=$$FUNC^%LCASE($zcmdline),argc=$length(cmdline," ")	;
	for i=1:1:argc do
	.	set KV=$piece(cmdline," ",i)
	.	if KV?1"-"1.L1"="1.N1(1"-",1",").E set $piece(KV,"=",2)=+$piece(KV,"=",2)
	.	if KV?1.N1(1"-",1",").E set KV=+KV
	.	set $piece(cmdline," ",i)=KV
	write cmdline,!
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; randomize arguments as necessary
randomize
	if debug>0 use debugfile write "PRE randomization",! zwr args  use $p
	do setpads
	do randREG
	do randKRB
	if debug>0 use debugfile write "POST randomization",! zwr args  use $p
	quit

	; randomize the regions
randREG
	new value,range,collection
	set value=$get(args("n_regions"),$$getdef("n_regions"))
	set range=$length(value,"-"),collection=$length(value,",")
	quit:('range&'collection)
	if range>1 do  ; RANGE PROCESSING
	.	set min=+$piece(value,"-",1),max=+$piece(value,"-",2)
	.	set range=(max-min)+1
	.	set args("n_regions")=$random(range)+min
	if collection>1 do  ; SET PROCESSING
	.	set collection=$length(value,",")
	.	set args("n_regions")=$piece(value,",",1+$random(collection))
	quit

	; randomize the key, block and record size
randKRB
	new value,key,rec,blk
	; Determine constraints based on whether or not randomization occurs
	; key_size
	set value=$get(args("key_size"),$$getdef("key_size"))
	set key("range")=$length(value,"-"),key("collection")=$length(value,",")
	; record_size
	set value=$get(args("record_size"),$$getdef("record_size"))
	set rec("range")=$length(value,"-"),rec("collection")=$length(value,",")
	set rec("max")=$select(rec("range")>1:$piece(value,"-",2),rec("collection")>1:$piece(value,",",rec("collection")),1:value)
	; block_size
	set value=$get(args("block_size"),$$getdef("block_size"))
	set blk("range")=$length(value,"-"),blk("collection")=$length(value,",")
	; determine BLOCK_MAX
	set blk("max")=$select(blk("range")>1:$piece(value,"-",2),blk("collection")>1:$piece(value,",",blk("collection")),1:value)
	if (blk("max")-pad("block_size"))<rec("max") set rec("max")=blk("max")-pad("block_size")
	;
	; key_size
	; key size cannot be larger than the block size, and we assume that no
	; one will exceed the maximum key size 1023
	set value=$get(args("key_size"),$$getdef("key_size"))
	if key("range")>1 do  ; RANGE PROCESSING
	.	set min=+$piece(value,"-",1),max=+$piece(value,"-",2)
	.	set keymax=$select(blockspan:blk("max")-pad("block_size"),1:rec("max")-pad("record_size")) ; key size cannot exceed block / record size
	.	set keymax=$select((version>55000)&(keymax>1019):1019,(version<60000)&(keymax>255):255,1:keymax)
	.	set max=$select(max>keymax:keymax,1:max)
	.	set key("range")=(max-min)+1
	.	if key("range")>0 set args("key_size")=$random(key("range"))+min
	.	else  set args("key_size")=max
	if key("collection")>1 do  ; SET PROCESSING
	.	set key("collection")=$length(value,",")
	.	set keymax=$select(blockspan:blk("max")-pad("block_size"),1:rec("max")-pad("record_size")) ; key size cannot exceed block / record size
	.	set keymax=$select((version>55000)&(keymax>1019):1019,(version<60000)&(keymax>255):255,1:keymax)
	.	for i=key("collection"):-1:1  quit:((+$piece(value,",",i))'>keymax)
	.	set args("key_size")=$piece(value,",",$random(i)+1)
	;
	; record_size
	; record size includes key size prior to V6. After V6 record size is
	; just the value. However to ensure compatiblity with prior releases we
	; retain the same constraints
	set value=$get(args("record_size"),$$getdef("record_size"))
	if rec("range")>1 do  ; RANGE PROCESSING
	.	set min=+$piece(value,"-",1),max=+$piece(value,"-",2)
	.	set recmin=$select(blockspan:min,1:(args("key_size")+pad("record_size")))
	.	set recmax=$select(blockspan:max,1:blk("max")-pad("block_size"))
	.	;
	.	set min=$select(min<recmin:recmin,1:min)
	.	set max=$select(max>recmax:recmax,1:max)
	.	;
	.	set rec("range")=(max-min)+1
	.	if rec("range")>0 set args("record_size")=$random(rec("range"))+min
	.	else  set args("record_size")=max
	if rec("collection")>1 do  ; SET PROCESSING
	.	set rec("collection")=$length(value,","),i=1
	.	if blockspan=0 do  ; do not use values in the collection where max > blk("max") - pad("block_size")
	.	.	for i=rec("collection"):-1:1  quit:((+$piece(value,",",i))'>(blk("max")-pad("block_size")))
	.	.	set rec("collection")=i
	.	. 	for i=1:1:rec("collection")  quit:(+$piece(value,",",i))>(args("key_size")+pad("record_size"))
	.	set i=i-1,rec("collection")=rec("collection")-i
	.	set args("record_size")=$piece(value,",",(1+$random(rec("collection")))+i)
	;
	; block_size
	; block size must be greater than record size unless -blockspan is specified for V6 nodes spanning blocks
	; block size must be greater than key size if -blockspan is specified for V6 nodes spanning blocks
	set value=$get(args("block_size"),$$getdef("block_size"))
	if blk("range")>1 do  ; RANGE PROCESSING
	.	set min=+$piece(value,"-",1),max=+$piece(value,"-",2)
	.	if blockspan=1 set min=$select(min>(args("key_size")+pad("block_size")):min,1:(args("key_size")+pad("block_size")))
	.	if blockspan=0 set min=$select(min>(args("record_size")+pad("block_size")):min,1:(args("record_size")+pad("block_size")))
	.	set blk("range")=(max-min)+1
	.	set args("block_size")=$random(blk("range"))+min
	if blk("collection")>1 do  ; SET PROCESSING
	.	set blk("collection")=$length(value,",")
	.	if blockspan=1 for i=1:1:blk("collection")  quit:(+$piece(value,",",i))>(args("key_size")+pad("block_size"))
	.	if blockspan=0 for i=1:1:blk("collection")  quit:(+$piece(value,",",i))>(args("record_size")+pad("block_size"))
	.	set i=i-1,blk("collection")=blk("collection")-i
	.	set args("block_size")=$piece(value,",",(1+$random(blk("collection")))+i)
	; FAILSAFE - need this until we shake out the edge cases
	if (blockspan=0)&(args("key_size")>args("record_size")) do
	.	do writeout("TEST-W-WARN: chose key_size > record_size","args(""key_size""))="_args("key_size")_$c(10)_"args(""record_size""))="_args("record_size"))
	.	do error
	.	halt
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; set the default pad values
setpads
	if version<60000 do
	.	set pad("block_size")=16  ; max record size is limited by a 16 byte pad for the block. this does not include reserved bytes
	.	set pad("record_size")=4  ; max key size is limited by a 4 byte pad for the record
	if version>55000 do
	.	set pad("block_size")=40  ; max key size is limited by a 40 byte padding for the block
	.	set pad("record_size")=0
	quit

getdef(key)
	if key="n_regions" quit 1
	if key="key_size" quit 64
	if key="record_size" quit 256
	if key="block_size" quit 1024
	quit -1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; test/com_u/dbcreate.csh's default arguments in order
defargs;file_name n_regions key_size record_size block_size allocation global_buffer_count extension_count reserved_bytes collation_default null_subscripts access_method acc_meth_env journal test_collation test_stdnull_collation test_gtcm qdbrundown freeze

