;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Driver routines for the spcfcbufdelay_pid-gtmde568333 subtest. See that subtest for the overall scheme.
gtmde568333	;
	quit
	;
holder	; Run with white box test case 143 (WBTEST_DB_WRITE_HANG) enabled.
	;
	; Dirty global buffers fast enough to drive DB_HANG_TRIGGER (75) database writes. On the 75th write
	; DB_LSEEKWRITE_HANG kicks in and this process sleeps inside DB_LSEEKWRITE for as many seconds as
	; ydb_white_box_test_case_count says, which the subtest sets to $holderhang (a fixed 3 minutes when
	; that is unset), still holding the cache record it was writing: "cr->epid" is this process and
	; "cr->dirty" is set.
	; That is exactly the state "wcs_get_space" reports through SPCFCBUFDELAY.
	;
	; Record our PID first, since the loop below hangs partway through.
	;
	; The loop only has to drive DB_HANG_TRIGGER (75) database writes, which takes on the order of a
	; thousand SETs against the small global buffer cache this subtest creates. The bound below is well
	; clear of that while still being small enough that finishing the remainder after the hang is cheap.
	open "holder.pid":(newversion) use "holder.pid" write $job,! close "holder.pid"
	for i=1:1:50000 set ^holder(i)=$justify(i,200)
	quit
	;
delayed	; Run with white box test case 410 (WBTEST_FORCE_SPCFCBUFDELAY) enabled.
	;
	; Churn the (deliberately small) global buffer cache so that "db_csh_getn" has to recycle the cache
	; record the holder process is sitting on. Recycling a still-dirty cache record is what takes us into
	; "wcs_get_space(reg, 0, cr)" and hence to the SPCFCBUFDELAY message.
	;
	; The loop is bounded so the subtest cannot hang if the holder finishes first.
	;
	; Keep the bound small. This process blocks in "wcs_get_space" for as long as the holder's hang lasts,
	; and every iteration left over after it is released is time the subtest spends doing nothing useful.
	for i=1:1:20000 set ^delayed(i)=$justify(i,200)
	quit
