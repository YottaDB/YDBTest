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
; GTM-8800 Test to verify semaphore ids and shared memory ids (kept in envvars) with values pulled
;          from structures within the running system.
;
	write "Not a valid entry point - drive entry point directly",!
	zhalt 1
;
; Routine to validate the fields specific to a given server are correct
; Parameters:
;   1 - dbsemid    - semid of database
;   2 - dbshmid    - shmmid of database
;   3 - jnlpsemid  - semid of journal pool
;   4 - jnlpshmid  - shmid of journal pool
;   5 - recvpsemid - semid of receive pool
;   6 - recvpshmid - shmid of receive pool
;
; Execute as $gtm_dist/mumps -run validate^gtm8800 dbsemid dbshmid jnlpsemid jnlpshmid recvpsemid recvpshmid
;
validate
	set x=$get(^someglobal,"")		; Fetch of non-existent global to open/attach everything
	; Fetch values from commandline
	set cmdline=$zcmdline
	set dbsemid=$zpiece(cmdline," ",1)
	set dbshmid=$zpiece(cmdline," ",2)
	set jnlpsemid=$zpiece(cmdline," ",3)
	set jnlpshmid=$zpiece(cmdline," ",4)
	set recvpsemid=$zpiece(cmdline," ",5)
	set recvpshmid=$zpiece(cmdline," ",6)
	; Fetch values from running processes
	set actdbsemid=$$^%PEEKBYNAME("sgmnt_data.semid","DEFAULT")
	set actdbshmid=$$^%PEEKBYNAME("sgmnt_data.shmid","DEFAULT")
	set actjnlpsemid=$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_semid")
	set actjnlpshmid=$$^%PEEKBYNAME("repl_inst_hdr.jnlpool_shmid")
	set actrecvpsemid=$$^%PEEKBYNAME("repl_inst_hdr.recvpool_semid")
	set actrecvpshmid=$$^%PEEKBYNAME("repl_inst_hdr.recvpool_shmid")
	; All values fetched - compare them and report differences
	set error=0
	if actdbsemid'=dbsemid do
	. write "DB semid not the value we expected - expected ",dbsemid," but got ",actdbsemid,!
	. if $increment(error)
	if actdbshmid'=dbshmid do
	. write "DB shmid not the value we expected - expected ",dbshmid," but got ",actdbshmid,!
	. if $increment(error)
	if actjnlpsemid'=jnlpsemid do
	. write "Jnlpool semid not the value we expected - expected ",jnlpsemid," but got ",actjnlpsemid,!
	. if $increment(error)
	if actjnlpshmid'=jnlpshmid do
	. write "Jnlpool shmid not the value we expected - expected ",jnlpshmid," but got ",actjnlpshmid,!
	. if $increment(error)
	if actrecvpsemid'=recvpsemid do
	. write "Recvpool semid not the value we expected - expected ",recvpsemid," but got ",actrecvpsemid,!
	. if $increment(error)
	if actrecvpshmid'=recvpshmid do
	. write "Recvpool shmid not the value we expected - expected ",recvpshmid," but got ",actrecvpshmid,!
	. if $increment(error)
	write:error !,"FAILURE - One or more values were NOT verified",!!
	write:'error !,"Success!",!!
	quit
