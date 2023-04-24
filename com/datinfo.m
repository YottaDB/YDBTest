;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
datinfo
	new x
	do get("x")
	zwrite x
	quit
	; Grab the max key and record sizes from DSE/%PEEKBYNAME to bring imptp testing close to the
	; maximums. This only works when all the regions share the same max values for keys and records
get(gvn)
	new imptpmaxkeysize,recpad,key2blockpct,blockspan,version,chset,ugenstrmax,blockdatalen,largerecdataratio
	if '$data(gvn) set gvn="^%imptp("_+$ztrnlnm("gtm_test_dbfillid")_")"
	set imptpmaxkeysize=40	; Rough estimate of space used by keys in IMPTP
	set recpad=4		; sizeof(rec_hdr)
	set key2blockpct=.30	; Maximum ratio of key size relative to the block size
	set blockspan=+$ztrnlnm("gtm_test_spannode")
	set version=$$^verno()
	if version<60000 set blockspan=0  ; versions less than V6.0-000 cannot do spanning nodes
	set chset=$$^zchset()
	set ugenstrmax=$select(chset="M":70,1:120)
	do dseget(.datinfo)
	; Large record sizes have a tendency to fill disks. don't use them unless the test is spanning nodes
	if (blockspan=0)&(datinfo("max_record_size")>1000) set datinfo("max_record_size")=1000
	; Don't let the max_key_size exceed more than 50% of the block size in general
	set:(.5<(datinfo("max_key_size")/datinfo("block_size"))) datinfo("max_key_size")=(datinfo("block_size")*0.5)\1
	; Without spanning nodes, ensure that the maximum size string generated by ugenstr fits in both key and record size
	if (blockspan=0)&((datinfo("max_record_size")-datinfo("max_key_size"))<ugenstrmax) do
	.	set datinfo("max_key_size")=$select(datinfo("max_key_size")<255:ugenstrmax,1:datinfo("max_key_size")-ugenstrmax)
	; MAXBTLEVEL avoidance
	if (blockspan=1) do
	.	; The available data space for the record is the block size minus the maximum key size. Use this value to
	.	; ensure that the spanning nodes that we create do not cause MAXBTLEVEL errors for IMPTP.
	.	set blockdatalen=datinfo("block_size")-datinfo("max_key_size")
	.	set largerecdataratio=0
	.	if blockdatalen=0  set largerecdataratio=1	; would use !, but can't rely on short circuiting
	.	else  set largerecdataratio=((datinfo("max_record_size")/blockdatalen)>3)
	.	if largerecdataratio do
	.	.	if datinfo("max_key_size")>(datinfo("block_size")*key2blockpct) do
	.	.	.	set datinfo("max_key_size")=(datinfo("block_size")*key2blockpct)\1
	.	.	.	set blockdatalen=datinfo("block_size")-datinfo("max_key_size")
	.	.	.	set largerecdataratio=((datinfo("max_record_size")/blockdatalen)>3)
	.	.	if largerecdataratio do
	.	.	.	set datinfo("max_record_size")=3*blockdatalen
	; Without spanning nodes, ensure that the max record length fits within the record size. datinfo("record_size") is
	; the maximum padding that can be applied to a record
	set datinfo("record_size")=datinfo("max_record_size")-$select(blockspan>0:recpad,1:datinfo("max_key_size")+recpad)
	; In IMPTP, the maximum key size, ^gvn(sub1,...subN), is imptpmaxkeysize bytes. datinfo("key_size") is the
	; maximum padding that can be applied to 'subN' when creating a spanning node. We subtract imptpmaxkeysize
	; to avoid overflowing the key when we pad 'subN'
	set datinfo("key_size")=datinfo("max_key_size")-imptpmaxkeysize
	merge @gvn=datinfo
	quit

dseget(datinfo)
	new dseoutput,$ETRAP,myetrap,reg
	; In case of an error, use the by file mechanism
	set $ETRAP="use $p zshow ""*"" set $ecode="""" zgoto "_$zlevel_":byfile^datinfo"
	set myetrap=$ETRAP
	if version>62002 do  quit	; Use ^%PEEKBYNAME() if it is available (V63000 and later)
	.	set reg=$view("GVNEXT","")  ; Use information from the first available region
	.	set datinfo("block_size")=$$^%PEEKBYNAME("sgmnt_data.blk_size",reg)
	.	set datinfo("max_record_size")=$$^%PEEKBYNAME("sgmnt_data.max_rec_size",reg)
	.	set datinfo("max_key_size")=$$^%PEEKBYNAME("sgmnt_data.max_key_size",reg)
	;
	; Else, we are stuck pulling it out of DSE itself
	;
	set file="dsedump.txt"
	set dsecmd="$DSE dump -fileheader >&! "_file
	zsystem dsecmd
	open file:readonly
	use file
	for line=1:1  quit:$zeof  read line(line) do
	. if $length($text(^%MPIECE))>0 do  ; We don't have MPIECE implementation in the older versions so use flexpiece instead
	.	. if line(line)?.e1" "1"Block size (in bytes)".e set datinfo("block_size")=$$^%MPIECE($piece($$^%MPIECE(line(line),"  ","|"),"|",4))
	. 	. if line(line)?." "1"Maximum record size".e set datinfo("max_record_size")=$$^%MPIECE($piece($$^%MPIECE(line(line),"  ","|"),"|",2))
	. 	. if line(line)?." "1"Maximum key size".e set datinfo("max_key_size")=$$^%MPIECE($piece($$^%MPIECE(line(line),"  ","|"),"|",2))
	. else  do
	.	. if line(line)?.e1" "1"Block size (in bytes)".e set datinfo("block_size")=$piece($$^v53003flexpiece(line(line),"  ","|"),"|",4)
	. 	. if line(line)?." "1"Maximum record size".e set datinfo("max_record_size")=$piece($$^v53003flexpiece(line(line),"  ","|"),"|",2)
	. 	. if line(line)?." "1"Maximum key size".e set datinfo("max_key_size")=$piece($$^v53003flexpiece(line(line),"  ","|"),"|",2)
	close file
	quit
