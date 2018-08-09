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
	if $ZCMDLINE<0 do neg
	else  do pos
	quit

neg
	set %DH=n
	set %DO=n
	set %DL=1

	do ^%DH
	do verify(nhex,%DH,16)
	write:(status=0) "%DH-----Correct Conversion",!
	write:(status'=0) "FAILED: DH= ",%DH,"   bcoutput= ",nhex,"   diff=",status,!

	do ^%DO
	do verify(noct,%DO,8)
	write:(status=0) "%DO-----Correct Conversion",!
	write:(status'=0) "FAILED: DO= ",%DO,"   bcoutput= ",noct,!
	quit

pos
	set %DH=n
	do ^%DH
	do verify(nhex,%DH,16)
	write:(status=0) "%DH-----Correct Conversion",!
	write:(status'=0) "FAILED: DH= ",%DH,"   bcoutput= ",nhex,"   diff=",status,!

	set %HO=%DH
	do ^%HO
	do verify(noct,%HO,8)
	write:(status=0) "%HO-----Correct Conversion",!
	write:(status'=0) "FAILED: HO= ",%HO,"   bcoutput= ",noct,!

	set %OD=%HO
	do ^%OD
	do verify(ndec,%OD,10)
	write:(status=0) "%OD-----Correct Conversion",!
	write:(status'=0) "FAILED: OD= ",%OD,"   bcoutput= ",ndec,!

	set %DO=%OD
	do ^%DO
	do verify(noct,%DO,8)
	write:(status=0) "%DO-----Correct Conversion",!
	write:(status'=0) "FAILED: DO= ",%DO,"   bcoutput= ",noct,!

	set %OH=%DO
	do ^%OH
	do verify(nhex,%OH,16)
	write:(status=0) "%OH-----Correct Conversion",!
	write:(status'=0) "FAILED: OH= ",%OH,"   bcoutput= ",nhex,!

	set %HD=%OH
	do ^%HD
	do verify(ndec,%HD,10)
	write:(status=0) "%HD-----Correct Conversion",!
	write:(status'=0) "FAILED: HD= ",%HD,"   bcoutput= ",ndec,!
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
	set zsyst="echo 'ibase="_ibase_"; "_percentout_"-("_bcout_");' | bc > verify.out"
	zsystem zsyst
	set v="verify.out"
	open v
	use v
	read status
	close v
	use $p
	if $ZCMDLINE<0 do
	. if ibase=8 set status=status#(2**(3*$length(percentout)))
	. if ibase=16 set status=status#(2**(4*$length(percentout)))
	quit
