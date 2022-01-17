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

gtm9136
	write "Main entry point not intended to be used",!
	zhalt 99
;
; This entry point is intended to be used when trying various incarnations of setting ydb_nofflf. Just open the file and write
; to it and let the script validate the file created. No device parms are used with this subtest.
envset(filenm)
	open filenm:new
	use filenm
	write "hi",#
	close filenm
	quit
;
; This entry point is used when we want to use the fflf device parameter. This can be used with or without the ydb_nofflf
; environment variable to test that the device option overrides whatever the environment variable specifies.
usefflf(filenm)
	open filenm:(new:fflf)
	use filenm
	write "hi",#
	close filenm
	quit

;
; This entry point is used when we want to use the fflf device parameter. This can be used with or without the ydb_nofflf
; environment variable to test that the device option overrides whatever the environment variable specifies.
usenofflf(filenm)
	open filenm:(new:nofflf)
	use filenm
	write "hi",#
	close filenm
	quit
