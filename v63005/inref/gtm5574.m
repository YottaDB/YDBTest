;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm5574
	do genrandint
	set ndec=n
	zsystem "echo 'ibase=10;obase=16; "_n_";' |bc > hex.txt"
	set h="hex.txt"
	open h
	use h
	read nhex
	zsystem "echo 'ibase=10;obase=8; "_n_";' |bc > oct.txt"
	set o="oct.txt"
	open o
	use o
	close h
	read noct
	use $p
	close o
	set twogig=4294967296

	set %DH=n
	do ^%DH
	do verify(nhex,%DH,16)
	write:(status=0) "%DH-----Correct Conversion",!
	write:(status'=0) "FAILED: DH= ",%DH,!

	set %HO=nhex
	do ^%HO
	do verify(noct,%HO,8)
	write:(status=0) "%HO-----Correct Conversion",!
	write:(status'=0) "FAILED: HO= ",%HO,!

	;set %OD=noct
	;do ^%OD
	;do verify(ndec,%OD,10)
	;write:(status=0) "%OD-----Correct Conversion",!
	;write:(status'=0) "FAILED: OD= ",%OD,!

	set %DO=ndec
	do ^%DO
	do verify(noct,%DO,8)
	write:(status=0) "%DO-----Correct Conversion",!
	write:(status'=0) "FAILED: DO= ",%DO,!

	;set %OH=noct
	;do ^%OH
	;do verify(nhex,%OH,16)
	;write:(status=0) "%OH-----Correct Conversion",!
	;write:(status'=0) "FAILED: OH= ",%OH,!

	set %HD=nhex
	do ^%HD
	do verify(ndec,%HD,10)
	write:(status=0) "%HD-----Correct Conversion",!
	write:(status'=0) "FAILED: HD= ",%HD,!
	quit

genrandint
	set l=$zcmdline
	if l<0 set l=-1*l
	set n=1+$random(9)
	set l=l-1
	for  quit:l=0  do
	. set n=n_$random(10)
	. set l=l-1
	if $zcmdline<0 set n="-"_n
	quit

verify(bcout,percentout,ibase)
	set zsyst="echo 'ibase="_ibase_"; "_percentout_"-("_bcout_");' | bc >> verify.out"
	zsystem zsyst
	set v="verify.out"
	open v
	use v
	read status
	close v
	use $p
	if $zcmdline<0 set status=status-twogig
	quit
