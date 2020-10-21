;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Large portions of this test are based upon the v63005/gtm5574 test
; which have been modified to ensure that the test will fail if the
; ydb652 bug is present.
	for i=1:1:10  do
	. write !,"Start iteration ",i," of test",!
	. do test
	quit

test
	do genrandint
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



genrandint
	set n=1
	set l=18
	set maxedoutsofar=1
	set maxr=2
	for  quit:l=0  do
	. set r=$random(maxr)
	. set n=n_r
	. set l=l-1
	. do testr
	quit

testr
	if 0=maxedoutsofar quit
	if 17=l,1=r  do
	. set maxr=6
	. quit
	if 16=l,5=r  do
	. set maxr=3
	. quit
	if 15=l,2=r  do
	. set maxr=10
	. quit
	if 14=l,9=r  do
	. set maxr=3
	. quit
	if 13=l,2=r  do
	. set maxr=2
	. quit
	if 12=l,1=r  do
	. set maxr=6
	. quit
	if 11=l,5=r  do
	. set maxr=1
	. quit
	if 10=l  do
	. set maxr=5
	. quit
	if 9=l,4=r  do
	. set maxr=7
	. quit
	if 8=l,6=r  do
	. set maxr=1
	. quit
	if 7=l  do
	. set maxr=7
	. quit
	if 6=l,6=r  do
	. set maxr=9
	. quit
	if 5=l,8=r  do
	. set maxr=5
	. quit
	if 4=l,4=r  do
	. set maxr=7
	. quit
	if 3=l,6=r  do
	. set maxr=10
	. quit
	if 2=l,9=r  do
	. set maxr=8
	. quit
	if 1=l,7=r  do
	. set maxr=6
	. quit
	set maxr=10
	set maxedoutsofar=0
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
