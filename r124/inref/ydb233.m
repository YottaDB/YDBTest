;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
peek	;
	write $$^%PEEKBYNAME("sgmnt_data.reorg_sleep_nsec","DEFAULT")
	quit

sleepTime	;
	set file="reorgTA.txt"
	open file:(exception="goto done")
	set sum=0
	for  use file  read line  do
	.	set sum=sum+line
done	close file
	write (sum/$ZCMDLINE)*1E9
	quit

percent	;
	set actual=$piece($zcmdline," ",1)
	set expect=$piece($zcmdline," ",2)
	if (expect>500000) set percenterror=((actual-expect)/actual)*100
	else  set percenterror=0	; for nanosleep seconds < 500,000 (i.e. 0.5 millisecond) we have seen
					; actual strace times go as high as 5x the expected. We suspect this is due
					; to strace time rounding issues so consider the test as a pass in this situation.
	if percenterror>10  Write "------>The sleep time for mupip reorg gives a percent error of ",percenterror,"%, which is above the 10% threshold, which is not acceptable."
	else  Do
	.	if percenterror<-10  Write "------>The sleep time for mupip reorg gives a percent error of ",percenterror,"%, which means MUPIP REORG slept for less time than assigned."
	.	else  Write "------>The sleep time for mupip reorg gives a percent error within the +/- 10% threshold, which is acceptable."
	quit
