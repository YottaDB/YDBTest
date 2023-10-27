;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
; GTM-8681 - Verify MUPIP BACKUP -RECORD stores the time of its start when it completes successfully
;
; Methodology:
;   1. Verify recorded backup time is 0.
;   2. Record start time with $ZUT (converted to seconds).
;   3. Run MUPIP BACKUP -RECORD
;   4. Record end time with $ZUT (converted to seconds)
;   5. Fetch the recorded backup time via $$^PEEKBYNAME()
;   6. Verify the recorded backup time falls between the times in steps 2 and 4.
;   7. Verify the value extracted via ^%PEEKBYNAME of sgmnt_data.last_start_backup is the same as
;      the date returned.
;   8. Part 2 - start with a fresh DB, force a backup to fail using WBTEST_BACKUP_FORCE_MV_RV white
;      box test and then verify the last_start_backup field was not modified (from 'Never').
;
gtm8681
	set pipe="CmdPipe"
	;
	; Fetch the current "backup time" to verify it is 0
	;
	write "# Verify the recorded backup time is 0",!
	set backupdtime=$$^%PEEKBYNAME("sgmnt_data.last_start_backup","DEFAULT")
	if 0'=backupdtime do
	. write !,"  Backup time at start of test is not set to 0 - terminating run",!
	. zhalt 1
	else  write "  Verified",!
	;
	write !,"# Create backup directory",!
	zsystem "mkdir backup"
	if 0'=$zsystem do
	. write !,"  Backup directory creation failed - terminating run",!
	. zhalt 1
	else  write "  Directory created",!
	write !,"# Executing command: $gtm_dist/MUPIP BACKUP -record -online ""*"" ./backup",!
	set startdtime=$zut\1000\1000
	zsystem "$gtm_dist/mupip backup -record -online ""*"" ./backup"
	set enddtime=$zut\1000\1000
	if 0'=$zsystem do
	. write !,"  Backup command failed - terminating run",!
	. zhalt 1
	else  write "  Backup command succeeded",!
	write !,"# Verify that DSE DUMP -FILEHEADER -ALL shows the last backup time as other than ""Never""",!
	zsystem "$gtm_dist/dse d -f -all |& grep ""Last Record Backup Start"""
	if 0'=$zsystem do
	. write !,"  DSE DUMP or GREP command failed - terminating run",!
	. zhalt 1
	write !,"# Verify that MUPIP DUMPFHEAD dumps ""sgmnt_data.last_start_backup"" as other than ""Never""",!
	open pipe:(shell="/usr/local/bin/tcsh":command="$gtm_dist/mupip dumpfhead -reg DEFAULT |& grep ""sgmnt_data.last_start_backup""")::"PIPE"
	use pipe
	read results
	if '$zeof do
	. read dummy	; Only read second line if it might exist
	if '$zeof do
	. use $p
	. write !,"  ** Read two lines and not at EOF yet",!
	. write "  ** 1st line: ",results,!
	. write "  ** 2nd line: ",dummy,!
	. write "  ** Terminating",!
	. zhalt 1
	close pipe
	use $p
	write results,!
	;
	write !,"# Verify the binary value extracted through $$^%PEEKBYNAME is the same (when converted) as the date returned",!
	write "# by MUPIP DUMPFHEAD and that both are non-zero/non-""Never"".",!
	set backupdtime=$$^%PEEKBYNAME("sgmnt_data.last_start_backup","DEFAULT")	; Fetch time backup started logged in DB
	set timestr=$zpiece(results,"""",4)
	open pipe:(shell="/bin/sh":command="date --date='@"_backupdtime_"' +""%a %b %e %T %Y""")::"PIPE"
	use pipe
	read results2
	read dummy
	if '$zeof do
	. use $p
	. write !,"  ** Read two lines and not at EOF yet",!
	. write "  ** 1st line: ",results,!
	. write "  ** 2nd line: ",dummy,!
	. write "  ** Terminating",!
	. zhalt 1
	close pipe
	use $p
	write "  Results from date command: ",results2,!
	if timestr'=results2 do
	. write !,"  ** Error: Expected value for strtime: ",timestr,!,"  ** Error: Actual value received     : ",results2,!
	else  do
	. write "  Verified",!
	;
	write !,"# Verify recorded backup time was within our runtime",!
	if startdtime>backupdtime do
	. write !,"  Backup time (",backupdtime,") is not less than or equal to time at backup start (",startdtime,") - terminating",!
	. write "  startdtime: ",?15,startdtime,!,"backup start: ",?15,backupdtime,!,"enddtime:",?15,enddtime,!
	. zhalt 1
	if backupdtime>enddtime do
	. write !,"  End backup time (",enddtime,") is less than recorded backup start time (",backupdtime,") - terminating",!
	. write "  startdtime: ",?15,startdtime,!,"backup start: ",?15,backupdtime,!,"enddtime:",?15,enddtime,!
	. zhalt 1
	write "  Recorded backup time verified",!
	quit
