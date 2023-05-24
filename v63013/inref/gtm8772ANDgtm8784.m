;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This routine provides entry points for testing MUPIP SET commands while FREEZE -ONLINE is enabled. Additionally
; we test MUPIP BACKUP and MUPIP RUNDOWN similarly. Lastly, as part of GTM-8784, we check a certain set of commands
; to be certain they only update the file header of the database.
;
	write "This routine should only be entered at one of the entry points. The main routine is not an entry point.",!
	zhalt 1
;
; Routine to try to run all the possible MUPIP SET commands in a non-standalone environment (while frozen)
MupipSetNonStandaloneFrozen
	write !,"# Try MUPIP SET commands while NOT able to get standalone lock(s) - a process has DB open",!
	write "# Spawn a process to do a single SET into the DB to prevent standalone commands from functioning correctly",!
	set cmdpipe="mupipSetPipe"
	open cmdpipe:(command="$gtm_dist/mumps -dir")::"PIPE"
	use cmdpipe
	read reply use $p write reply,! use cmdpipe
	write "set ^x=1",!
	read reply use $p write reply,!
	use $p
	do drivecommands("MUPIPSETTests","MUPIP SET commands with FREEZE -ONLINE (standalone not available):",1)
	write !,"# Shutting down process keeping database open",!
	use cmdpipe
	write "halt",!
	read reply use $p write reply,! use cmdpipe
	read reply use $p write reply,!
	close cmdpipe  	  	; This close also terminates the process tied to the pipe
	write !,"# MUPIPSETTests complete - database is UNFROZEN!",!
	quit

; Routine to try to run all the possible MUPIP SET commands in a standalone (but frozen) environment
MupipSetStandaloneFrozen
	write !,"# MUPIP SET commands when standalone is available (except for the freeze)",!
	do drivecommands("MUPIPSETTests","MUPIP SET commands with FREEZE -ONLINE (standalone available):",1)
	write !,"# MUPIPSETTests complete - note database is UNFROZEN!",!
	quit

; Routine to try to run all the possible MUPIP SET commands in a standalone environment to show the commands work
MupipSetStandaloneUnFrozen
	write !,"# MUPIP SET commands when standalone is available and NOT frozen",!
	do drivecommands("MUPIPSETTests","MUPIP SET commands (standalone available and NO FREEZE):",0)
	write !,"# MUPIPSETTests complete",!
	quit

;
; Routine to try to run a MUPIP RUNDOWN command in a standalone environment (while frozen)
;
MupipRundownStandaloneFrozen
	write !,"# MUPIP RUNDOWN command(s) when standalone is available (except for the freeze)",!
	do drivecommands("MUPIPRUNDOWNTests","MUPIP RUNDOWN command(s) with FREEZE -ONLINE (standalone available):",1)
	write !,"# MUPIPRUNDOWNTests complete - note database is UNFROZEN!",!
	quit

;
; Routine to try to run a MUPIP BACKUP in a standalone environment (while frozen)
;
MupipBackupStandaloneFrozen
	write !,"# Try MUPIP BACKUP command(s) when standalone is available (except for the freeze)",!
	do drivecommands("MUPIPBACKUPTests","MUPIP BACKUP command(s) with FREEZE -ONLINE (standalone available):",1)
	write !,"# MUPIPBACKUPTests complete - note database is UNFROZEN!",!
	quit

;
; Routine to try to run certain MUPIP SET commands and verify (when not frozen) that they flush only the
; file header to the database.
;
MupipSetFileHeaderFlushUnFrozen
	write !,"# Try MUPIP SET command when standalone is available verifying only fileheader is flushed",!
	do drivecommandsfhflush("MUPIPSETFHFLUSHTests","MUPIP SET commands - Verify fileheader only is flushed (not frozen):")
	write !,"# MUPIPSETFHFLUSHTests complete",!
	quit

;
; Routine to drive commands that run with database FREEZE -ONLINE (and noautorelease).
;
drivecommands(label,text,freeze)
	new cmd,i
	;
	if freeze do
	. write !,"# Freeze the database",!
	. zsystem "$MUPIP freeze -online -noautorelease -on DEFAULT"
	write !,"# ",text,!
	for i=1:1 do  quit:""=cmd
	. set cmd=$$fetchcommand(label,i)
	. quit:""=cmd
	. write !,"# Try ",cmd,!
	. zsystem cmd
	if freeze do
	. write !,"# Releasing the freeze",!
	. zsystem "$MUPIP freeze -off DEFAULT"
	quit

;
; Routine to drive commands that create strace listings - investigate the created listings to verify only the
; file-headers are being written out.
;
drivecommandsfhflush(label,text)
	new cmd,i,fn
	;
	write !,"# ",text,!
	for i=1:1 do  quit:""=cmd
	. set cmd=$$fetchcommand(label,i)
	. quit:""=cmd
	. write !,"# Try ",cmd,!
	. zsystem cmd
	. ; Now verify the file it created - first look for what command was just run
	. set fn=$zpiece(cmd," ",3)
	. do validatestrace(fn)
	quit

;
; Routine to fetch comment lines below to run them. Preprocess the lines before returning to pull the comment
; indicator off the front so the lines can be executed.
;
fetchcommand(label,idx)
	new cmd,line
	set cmd="line=$text("_label_"+"_idx_"^"_$text(+0)_")"
	set @cmd
	set:(""'=line) line=$zpiece(line,"; ",2,999)
	quit line

;
; Validate the passed-in strace file does no more than a fileheader flush to the DB (no other pages in the DB)
;
validatestrace(fn)
	new line,quit,srchstr,datalen,dataxtr,dataoff,i
	; Transform open() calls into openat() calls in the trace. This is primarily needed for Redhat 7.
	; Doing this makes the parse code less complex as we only have to look for one thing (openat).
	zsystem "sed -i 's/^open(/openat(/g' "_fn
	; Read the file to verify the writes done to the DB are only for the file header (0 offset, length 8192)
	open fn:readonly
	; First step - figure out which file-descriptor to look for - locate openat call referencing mumps.dat
	set quit=0
	for i=1:1  use fn read line quit:$ZEOF  do  quit:quit
	. quit:""=line			; Ignore blank lines
	. quit:line'["openat("		; Ignore lines that don't have openat
	. quit:line'["mumps.dat"	; Ignore lines that don't reference mumps.dat
	. set fd=$zpiece(line,"= ",2)	; Extrace the file descriptor from that line
	. set quit=1
	. quit
	do:'quit			; If we didn't stop because we found what we want, we have a problem to report
	. use $p
	. write "validatestrace: For filename ",fn," - could not find the open call (openat) for mumps.dat"
	. zgoto -2			; Return from validatestrace
	;
	; At this point, we've found the open for the file and extracted the file descriptor from it.
	; Now search the rest of the file for pwrite64 invocations with the requisite file descriptor and parse the
	; writes to verify a 0 offset and a write length of 8192 for the file header.
	set srchstr="pwrite64("_fd_","
	for i=i:1  use fn read line quit:$ZEOF  do
	. quit:line'[srchstr
	. ; This line has a pwrite64 - find out the offset of the write and the data length.
	. set datalen=$zpiece(line,", ",3)	; Extract the write length
	. set dataxtr=$zpiece(line,", ",4)	; Extract chunk that contains the data offset
	. set dataoff=$zpiece(dataxtr,")",1)	; Isolate the data offset value
	. if (8192'=datalen)!(0'=dataoff) do
	. . use $p
	. . write "validatestrace: For filename ",fn," - On line ",i," found a pwrite64() for other than the DB file header",!
	. . write "              : ",line,!
	. else  use $p write "validatestrace - line validated: ",line,!
	use $p
	quit
;
; The following list of command are bypassed as they don't work with BG databases:
;
; $MUPIP SET -REGION DEFAULT -DEFER_TIME=42
; $MUPIP SET -REGION DEFAULT -READ_ONLY

MUPIPSETTests		; Test all of the MUPIP SET options we can
; $MUPIP SET -REGION DEFAULT -ACCESS_METHOD=BG
; $MUPIP SET -REGION DEFAULT -ASYNCIO
; $MUPIP SET -REGION DEFAULT -DEFER_ALLOCATE
; $MUPIP SET -REGION DEFAULT -NOEPOCHTAPER
; $MUPIP SET -REGION DEFAULT -EXTENSION=42
; $MUPIP SET -REGION DEFAULT -FLUSH_TIME=42
; $MUPIP SET -REGION DEFAULT -GLOBAL_BUFFERS=4242
; $MUPIP SET -REGION DEFAULT -HARD_SPIN_COUNT=42
; $MUPIP SET -REGION DEFAULT -INST_FREEZE_ON_ERROR
; $MUPIP SET -REGION DEFAULT -KEY_SIZE=142
; $MUPIP SET -REGION DEFAULT -LOCK_SPACE=420
; $MUPIP SET -REGION DEFAULT -MUTEX_SLOTS=4242
; $MUPIP SET -REGION DEFAULT -NULL_SUBSCRIPTS=NEVER
; $MUPIP SET -REGION DEFAULT -NOLCK_SHARES_DB_CRIT
; $MUPIP SET -REGION DEFAULT -QDBRUNDOWN
; $MUPIP SET -REGION DEFAULT -PARTIAL_RECOV_BYPASS
; $MUPIP SET -REGION DEFAULT -RECORD_SIZE=4242
; $MUPIP SET -REGION DEFAULT -REORG_SLEEP_NSEC=424242
; $MUPIP SET -REGION DEFAULT -RESERVED_BYTES=42
; $MUPIP SET -REGION DEFAULT -SLEEP_SPIN_COUNT=84
; $MUPIP SET -REGION DEFAULT -NOSTATS
; $MUPIP SET -REGION DEFAULT -NOSTDNULLCOL
; $MUPIP SET -REGION DEFAULT -TRIGGER_FLUSH=2424
; $MUPIP SET -REGION DEFAULT -WAIT_DISK=42
; $MUPIP SET -REGION DEFAULT -WRITES_PER_FLUSH=42

; The following line needs to be in the previous section but is currently not included because MUPIP SET -VERSION is
; not supported currently. [UPGRADE_DOWNGRADE_UNSUPPORTED]
; $MUPIP SET -REGION DEFAULT -VERSION=V7

; Must have a blank line above this line to terminate the set of MUPIP SET tests

MUPIPRUNDOWNTests	; Test MUPIP RUNDOWN
; $MUPIP RUNDOWN -REGION DEFAULT

; Must have a blank line above this line to terminate the set of MUPIP RUNDOWN tests

MUPIPBACKUPTests	; Test MUPIP BACKUP
; $MUPIP BACKUP -NEWJNLFILES DEFAULT backup

; Must have a blank line above this line to terminate the set of MUPIP BACKUP tests

MUPIPSETFHFLUSHTests	; Test certain MUPIP SET options that only flush file header (when not frozen)
; strace -o strace_EPOCHTAPER.trclist $MUPIP SET -REGION DEFAULT -EPOCHTAPER
; strace -o strace_FLUSH_TIME.trclist $MUPIP SET -REGION DEFAULT -FLUSH_TIME=24
; strace -o strace_HARD_SPIN_COUNT.trclist $MUPIP SET -REGION DEFAULT -HARD_SPIN_COUNT=24
; strace -o strace_NOINST_FREEZE_ONERROR.trclist $MUPIP SET -REGION DEFAULT -NOINST_FREEZE_ON_ERROR
; strace -o strace_SLEEP_SPIN_COUNT.trclist $MUPIP SET -REGION DEFAULT -SLEEP_SPIN_COUNT=84

; Must have a blank line above this line to terminate the set of MUPIP flush-fileheader tests
