;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to cause the M Lock hash table to be expanded which creates a new shared memory segment. Once this
; is done, the process running this routine will be forcefully killed (kill -9) to prevent any cleanup as we
; want this new shared memory to be orphaned. Then we will verify that after a MUPIP RUNDOWN, this extended
; lock hashtable shared segment is cleaned up. Prior to gtm9260 (V63012), MUPIP RUNDOWN would leave this segment
; and did not clean it up. Note this routine requires $ydb_lockhash_n_bits set to 10 to function correctly.
gtm9260
	new stoploop,loop,shmid,shmidfile
	write "Starting gtm9260 - trying to create an MLock hashtable expansion",!
	set stoploop=0
	for loop=1:1 do  quit:stoploop
	. ; Use a timed lock for reasons described here: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/1379#note_925281079
	. lock @("+^alock"_loop_":10")
	. if '$test do
	. . write "Hit lock deadlock (waiting for resources) at iteration ",loop," - terminating run",!
	. . zhalt 1
	. set shmid=$$getmlkhashshmid()
	. set:(0<shmid) stoploop=1	; If has a positive value, then we have a segment
	set shmidfile="ydblckhshshmid.txt"
	open shmidfile:new
	use shmidfile
	write shmid
	close shmidfile
	write "Completed gtm9260 - segment created (shmid=",shmid,") after ",loop," iterations - terminating via kill -9",!
	zsystem "kill -9 "_$job
	hang 9999			; Wait for kill -9 to terminate us and orphan our IPCs.

; Routine to return the contents of sgmnt_addrs.mlkhash_shmid which, if set, contains the shmid of the
; extended lock hash table.
getmlkhashshmid()
	quit $$^%PEEKBYNAME("sgmnt_addrs.mlkhash_shmid","DEFAULT")
