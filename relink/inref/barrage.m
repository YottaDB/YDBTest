;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Test various autorelink-related functionality. Here are some instructions on how to run this script and what it can do:
;
; This program can operate in one of three modes: 'test', 'replay', and 'analyze'. When run in the 'test' mode, the program spawns
; off a number of concurrent processes that randomly perform one of the following operations: write a source file, delete a source
; file, delete an object file, set $zroutines, compile a source file, link an object file, do a ZRUPDATE, or execute a routine
; (not necessarily directly). By "randomly" I mean that not only is the operation selected by chance (with preselected
; probabilities, though), but various aspects of the operation (such as a routine to execute, object directories and respective
; source directories to use, and so on) are maximally random as well.
;
; No checks other than those of the program's operational assumptions are performed in the 'test' mode for performance reasons.
; The program does, however, log every operation to the database for further analysis and, if required, replay. Should the main
; process hang or core, an emergency logging channel (implemented via writes to a FIFO device that an independent background
; process is reading) captures the entire sequence of operations in an executable M file with indications of which process ran
; which commands.
;
; After a 'test' run, the results can be validated in the 'analyze' mode, when a single process goes over the database records and
; "reconstructs" the state of each process involved in the test and ensures that correct errors were given, versions of routines
; executed linked and executed, and so forth. To aid debugging, execution options (discussed below) may be specified to BREAK on
; errors and enable brief on-screen or more detailed in-file log messages (with simple filtering).
;
; While the 'replay' mode provides all the functionality of the 'analyze' mode (though the validation mechanism per se can be
; disabled), it also reproduces all the operations performed during the 'test' stage in chronological order, delegating those that
; affect a process's state (such as linking an object or executing a routine) to respective subprocesses. If, for example, the test
; comprised three processes, with IDs 1, 2, and 3, then during the replay all of process 1's actions would be assigned to one
; process, all of 2's to another, and all of 3's to the other.
;
; Similarly to the 'analyze' mode, additional log messages and BREAKing on errors can be enabled in the 'replay', which gives us
; the ability to examine the state of each process exactly as it would have been during the test. Obviously, explicit BREAKs could
; be inserted inside the test program for more in-depth debugging.
;
; Two additional validation options---currently marked as debug-only because of performance implications, but easily turnable into
; default ones are---the matching of source and object files' versions against the program's bookkeeping records and inspection of
; relink control files as reported by the ZSHOW "A" command.
;
; The currently configurable functional options are the number of concurrent processes, routines, source, and object directories,
; count of operations per process, and various timeouts. My experience shows that most problems can be, in fact, discovered with
; just one process, given a sizeable number of operations and at least five-to-ten routines and directories to play with.
;
; For ease of testing and debugging, the program stipulates a few simple requirements: First of all, the global directory, database,
; and the program's object file should be kept outside the test bed to avoid accidental removal and linking problems. Secondly, the
; test relies on the gtmposix plug-in, so the appropriate environment variable should be set. Finally, the program defines a few
; external functions of its own, which should also be kept separately from the test produce. Here is my sample environment:
;
;    /testarea1/sopini/autorelink
;    |->db
;    |  |->mumps.dat
;    |  `->mumps.gld
;    |->obj
;    |  `->test.o
;    |->test
;    |  |-> ... that is where test files are created …
;    |  `->replay (may not exist)
;    |     `-> ... that is where replay files are created …
;    `->xcall
;       |->autorelink.c
;       |->autorelink.xc
;       `->libautorelink.so
;
; Relevant environment variables:
;
;    GTMXC_gtmposix		- Path to gtmposix's external calls table (typically, /usr/library/com/gtmposix/gtmposix.xc).
;    GTMXC_relink		- Path to relink's external calls table (<test dir>/tmp/relink.xc).
;    gtmroutines		- References to object and source directories ("<test dir>/obj(. $gtm_tst/$tst/inref) $gtm_dist").
;    gtmgbldir			- Path to the global directory (<test dir>/db/mumps.gld).
;    sigusrval			- Integer value of SIGUSR1 (10 on Linux, 30 on AIX, and 16 on SunOS).
;    barrage_num_of_rtns	- Number of routines to use in the test (optional).
;    barrage_num_of_src_dirs	- Number of source directories to employ in the test (optional).
;    barrage_num_of_obj_dirs	- Number of object directories to employ in the test (optional).
;    barrage_num_of_procs	- Number of processes to run concurrently in the test (optional).
;    barrage_num_of_opers	- Approximate number of operations to be assigned to each process in the test (optional).
;
; Once that is set, executing the program is trivial:
;
;    mumps -run test											(test mode)
;    mumps -run replay^test [analyze] [log to screen] [log to file] [break on errors]			(replay mode)
;    mumps -run analyze^test [log to screen] [log to file] [break on errors] [global for filter]	(analysis mode)
;
; All flags are optional and default to 0 (1 is the other legitimate value), except for the 'global for filter'. Descriptions
; follow:
;
;    analyze - enable / disable analysis (meaningful only during replay)
;    log to screen - print (or not) short informative messages to the screen during analysis or replay
;    log to file - print (or not) detailed M commands to reproduce the action performed by a particular process
;    break on errors - break (or not) on errors detected during the analysis
;    global for filter - when logging to the file, disregard operations unrelated to this specified routine
;
; Be advised that while it is safe to rerun the script in the 'replay' and 'analyze' modes, the 'test' mode wipes out all data
; recorded in a prior test.
;
; To debug a failure from barrage, proceed to the failure directory and unzip all files. Then source debug.csh; this should set
; all the environment variables required to rerun the test. A test failure is most likely from the 'analyze' mode (version
; mismatch or routine search issue) or 'replay' mode (source and object file version or routine cycle version mismatch).
;
; In terms of implementation, the test operates on several key variables:
;
;    ^REFS	  - Contains indexed references to all routine and source and object directories' names. Used only in 'test' phase.
;    ^RTNS	  - Contains the name and highest version of each routine. Used only in 'test' phase.
;    ^SRCDIRS	  - Contains name and list of contained routine sources of every source directory. Used only in 'test' phase.
;    ^OBJDIRS	  - Contains name and list of contained routine object files of every object directory. Used only in 'test' phase.
;    ^LOG	  - Perhaps, the key variable. Contains structured information about all operations performed in 'test' phase along with relevant
;		    details. It is traversed in 'analyze' and 'replay' mode to recreate and validate the sequence of events. Refer to the table
;		    below for the outline of ^LOG's structure.
;    SRCIDRS	  - Contains information about all source directories, including their names, sources of which routines they contain, as well as
;		    the versions and timestamps of those sources. Used in 'analyze' and 'replay' (with analysis enabled) mode by the master process.
;    OBJDIRS	  - Contains information about all object directories, including their names, object files of which routines they contain, as well
;		    as the versions and timestamps of those object files and versions at which they were placed in the shared memory. Used in
;		    'analyze' and 'replay' (with analysis enabled) mode by the master process.
;    PROCS	  - Contains information about the state of all processes involved in the test. It includes their $zroutines, routines they have
;		    linked (along with their cycle and version numbers, directories from which they linked, and whether they are autorelink-enabled),
;		    and directories whose relink-control files they mmapped. Used by the master process in 'replay' mode with analysis enabled.
;    RCTLSHM	  - Contains processes' references to all variants of all routines that are expected to be stored in shared memory.
;    PROCSRTNREFS - Contains process-private knowledge of what variant of a particular routine it has last linked (unless linked statically).
;
;==========================================================================================================================================================
; 							EXPLANATION OF ^LOG STRUCTURE
;
; The table lists the flags denoting possible actions performed by processes during the test phase. Each flag is accompanied with a brief description of
; the action and the structure of the respective global entry containing the specific details of the operation.
;
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTSETZROUTINES				A process is specifying new $zroutines.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"zro",0)			Number of object directories in the new $zroutines.
; ^LOG(<time>,<job>,"zro",<oidx>)		Name of the oidx-th object directory in the new $zroutines.
; ^LOG(<time>,<job>,"zro",<oidx>,"*")		Indication of whether the oidx-th object directory in the new $zourines is starred.
; ^LOG(<time>,<job>,"zro",<oidx>,0)		Number of source directories corresponding to the oidx-th object directory in the new $zroutines.
; ^LOG(<time>,<job>,"zro",<oidx>,<sidx>)	Name of the sidx-th source directory corresponding to the oidx-th object directory in the new $zroutines.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTWRITESOURCES				A process has written new sources of one or more routines to the disk.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"wrtsrc",0)			Number of new routines being written.
; ^LOG(<time>,<job>,"wrtsrc",<ridx>)		Name of the ridx-th routine being written.
; ^LOG(<time>,<job>,"wrtsrc",<ridx>,"dir")	Name of the directory where the ridx-th routine is being written.
; ^LOG(<time>,<job>,"wrtsrc",<ridx>,"ver")	Version of the ridx-th routine being written.
; ^LOG(<time>,<job>,"wrtsrc",<ridx>,"time")	Timestamp of the ridx-th routine once written.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTDELETESOURCES				A process has deleted one or more routine source files from the disk.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"dltsrc",0)			Number of routines being deleted.
; ^LOG(<time>,<job>,"dltsrc",<ridx>)		Name of the ridx-th routine being deleted.
; ^LOG(<time>,<job>,"dltsrc",<ridx>,"dir")	Name of the directory where the ridx-th routine is being deleted.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTDELETEOBJECTS				A process has deleted one or more routine object files from the disk.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"dltobj",0)			Number of routines being deleted.
; ^LOG(<time>,<job>,"dltobj",<ridx>)		Name of the ridx-th routine being deleted.
; ^LOG(<time>,<job>,"dltobj",<ridx>,"dir")	Name of the directory where the ridx-th routine is being deleted.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTCOMPILE					A process has compiled one or more routines.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"compile",0)		Number of routines being compiled.
; ^LOG(<time>,<job>,"compile",<ridx>)		Name of the ridx-th routine being compiled.
; ^LOG(<time>,<job>,"compile",<ridx>,"dir")	Name of the directory where the ridx-th routine is being compiled.
; ^LOG(<time>,<job>,"compile",<ridx>,"dst")	Name of the directory where the object for the ridx-th routine is being put.
; ^LOG(<time>,<job>,"compile",<ridx>,"result")	Result of compiling the ridx-th routine.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTLINK					A process has linked one or more routines.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"link",0)			Number of routines being compiled.
; ^LOG(<time>,<job>,"link",<ridx>)		Name of the ridx-th routine being compiled.
; ^LOG(<time>,<job>,"link",<ridx>,"dir")	Name of the directory where the ridx-th routine is being linked.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTZRUPDATE					A process has updated one or more routines' info in the autorelink control structure.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"zrupdate",0)		Number of routines being updated.
; ^LOG(<time>,<job>,"zrupdate",<ridx>,"result")	Result of zrupdating the ridx-th routine (which could be a wildcarded expression).
; ^LOG(<time>,<job>,"zrupdate",<ridx>)		Name of the ridx-th routine being updated.
; ^LOG(<time>,<job>,"zrupdate",<ridx>,"dir")	Name of the directory where the ridx-th routine is being updated.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTEXECUTE					A process has executed a routine.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"exec")			Name of the routine being executed.
; ^LOG(<time>,<job>,"exec","result")		Result of executing the routine.
; ^LOG(<time>,<job>,"exec","choice")		Index of the execution method for the routine.
; ^LOG(<time>,<job>,"exec","expression")	The exact expression used for invocation.
; ^LOG(<time>,<job>,"exec","etrap")		Flag indicating whether an extra layer of etrap protection is used.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTMKDIRS					A process has created directories.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ^LOG(<time>,<job>,"mkdir",0)			Number of directories being created.
; ^LOG(<time>,<job>,"mkdir",<didx>)		Name of the didx-th directory being created.
; ^LOG(<time>,<job>,"mkdir",<didx>,"src")	Flag indicating whether the didx-th directory being created is for source (or object) files.
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTTERM					A process is terminating (used only for replay).
;----------------------------------------------------------------------------------------------------------------------------------------------------------
; ACTRCTLDUMP					A process is dumping the relink control structures (used only for replay).
;==========================================================================================================================================================
;
;==========================================================================================================================================================
;							EXPLANATION OF THE SRCDIRS STRUCTURE
;
; The table lists the fields maintained for each source directory and source file that either was supposed to be present on disk during the test run (when
; operating in analysis mode) or is supposed to be present (when operating in replay mode with analysis).
;
; SRCDIRS(<srcdir>)				Some value. Existence of this node indicates that the source directory srcdir exists at this time.
; SRCDIRS(<srcdir>,<rtnname>)			Some value. Existence of this node indicates that rtnname's source file exists in srcdir at this time.
; SRCDIRS(<srcdir>,<rtnname>,"ver")		Version of rtnname's source file that presently exists in srcdir.
; SRCDIRS(<srcdir>,<rtnname>,"time")		Time (relative but unique) at which rtnname's source file was created in srcdir.
;==========================================================================================================================================================
;
;==========================================================================================================================================================
;							EXPLANATION OF THE OBJDIRS STRUCTURE
;
; The table lists the fields maintained for each object directory and object file that either was supposed to be present on disk during the test run (when
; operating in analysis mode) or is supposed to be present (when operating in replay mode with analysis).
;
; OBJDIRS(<objdir>)				Some value. Existence of this node indicates that the object directory objdir exists at this time.
; OBJDIRS(<objdir>,<rtnname>)			Some value. Existence of this node indicates the rtnname's object file exists ins objdir at this time.
; OBJDIRS(<objdir>,<rtnname>,"ver")		Version of rtnname's object file that presently exists in objdir.
; OBJDIRS(<objdir>,<rtnname>,"time")		Time (relative but unique) at which rtnname's object file was created in objdir.
; OBJDIRS(<objdir>,<rtnname>,"srcDir")		Source directory from which rtnname's object file was compiled in objdir.
; OBJDIRS(<objdir>,<rtnname>,"cycle")		Cycle number of rtnname in regards to objdir (such as from object-directory-specific MUPIP RCTLDUMP).
;==========================================================================================================================================================
;
;==========================================================================================================================================================
;							EXPLANATION OF THE PROCS STRUCTURE
;
; The table lists the fields maintained for each process and its view of the routines' history and environment when operated in replay mode.
;
; PROCS(<pid>,"zro")				Process pid's $zroutines.
; PROCS(<pid>,"zro",0)				Count of object directories in process pid's $zroutines.
; PROCS(<pid>,"zro",<oidx>)			Name of the oidx-th directory in process pid's $zroutines.
; PROCS(<pid>,"zro",<oidx>,"*")			Indication of whether the oidx-th directory in process pid's $zroutines is autorelink-enabled.
; PROCS(<pid>,"zro",<oidx>,0)			Count of source directories associated with oidx-th object directory in process pid's $zroutines.
; PROCS(<pid>,"zro",<oidx>,<sidx>)		Name of the sidx-th directory associated with the oidx-th object directory in process pid's $zroutines.
; PROCS(<pid>,"dirs",<objdir>)			Some value. Existence of this node indicates that process pid is autorelink-aware of directory objdir.
; PROCS(<pid>,"rtns",<rtnname>,"*")		Indication of whether process pid has routine rtnname linked in an autorelink-enabled fashion.
; PROCS(<pid>,"rtns",<rtnname>,"dir")		Object directory from which process pid has linked routine rtnname.
; PROCS(<pid>,"rtns",<rtnname>,"ver")		Version of rtnname that process pid has last linked.
; PROCS(<pid>,"rtns",<rtnname>,<objdir>,"cycle") Cycle of routine rtnname in object directory objdir as last known to process pid.
;==========================================================================================================================================================
;
;==========================================================================================================================================================
;							EXPLANATION OF THE RCTLSHM STRUCTURE
;
; The table outlines the structure maintained for each process/routine combination when the process is attached to a particular variant of that routine in
; shared memory.
;
; RCTLSHM(<rtnname>,<rtnver>,<objdir>,<srcdir>,<pid>) Some value. Existence of this node means that process pid is using routine rtnname's object code in
;                                                     shared memory that was linked from object directory objdir and compiled from source directory srcdir.
;                                                     Therefore, $data() on that node sans the pid indicates whether there are any processes attached to
;                                                     that particular variant of this routine.
;==========================================================================================================================================================
;
;==========================================================================================================================================================
;							EXPLANATION OF THE PROCSRTNREFS STRUCTURE
;
; The table lists the fields maintained for each process/routine combination when the process is attached to a particular variant of that routine in shared
; memory.
;
; PROCSRTNREFS(<pid>,"rtns",<rtnname>,"ver")	Version of routine rtnname that process pid has last linked in an autorelink-enabled fashion.
; PROCSRTNREFS(<pid>,"rtns",<rtnname>,"srcDir")	Source directory from which the routine rtnname's object that process pid has last linked in an autorelink-
;						enabled fashion was compiled.
; PROCSRTNREFS(<pid>,"rtns",<rtnname>,"dir")	Directory from which the routine rtnname's object was last linked by process pid in an autorelink-enabled
;						fashion.
;==========================================================================================================================================================
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize various constants and configuration parameters and invoke the appropriate driver function.             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init(process)
	new TRUE,FALSE,NOOP
	new NAMELEN,SRCDIRPREFIX,OBJDIRPREFIX,RTNPREFIX,PREFIXLEN,REPLAYDIR,TESTLOG,REPLAYLOG,ANALYZELOG,RCTLLOG,ZPRINTLOG
	new NUMOFRTNS,NUMOFSRCDIRS,NUMOFOBJDIRS,NUMOFPROCS,NUMOFOPERS,MAXSTARTTIME,MAXRUNTIME,MAXWAITTIME,TIMESTAMPTIME
	new ACTSETZROUTINES,ACTWRITESOURCES,ACTDELETESOURCES,ACTDELETEOBJECTS,ACTCOMPILE,ACTLINK,ACTZRUPDATE,ACTEXECUTE,ACTMAKEDIRS,ACTTERM,ACTRCTLDUMP
	new NAMES,REFS,RTNS,SRCDIRS,OBJDIRS,LBLCNT
	new TEST,ANALYZE,REPLAY,DEBUG,BADRTN,SIGUSR1
	new logToScreen,logToFile,analyze,breakOnErrors

	; General M constants
	set TRUE=1
	set FALSE=0
	set NOOP=-1

	; Constants implementing naming and other conventions
	set NAMELEN=3
	set SRCDIRPREFIX="src"
	set OBJDIRPREFIX="obj"
	set RTNPREFIX="rtn"
	set PREFIXLEN=3
	set REPLAYDIR="replay"
	set TESTLOG="log.txt"
	set REPLAYLOG="replay-log.txt"
	set ANALYZELOG="analyze-log.txt"
	set RCTLLOG="rctl-log.txt"
	set ZPRINTLOG="zprint-log.txt"

	; Configuration constants
	set NUMOFRTNS=$select(""=$ztrnlnm("barrage_num_of_rtns"):3,1:+$ztrnlnm("barrage_num_of_rtns"))
	set NUMOFSRCDIRS=$select(""=$ztrnlnm("barrage_num_of_src_dirs"):2,1:+$ztrnlnm("barrage_num_of_src_dirs"))
	set NUMOFOBJDIRS=$select(""=$ztrnlnm("barrage_num_of_obj_dirs"):2,1:+$ztrnlnm("barrage_num_of_obj_dirs"))
	set NUMOFPROCS=$select(""=$ztrnlnm("barrage_num_of_procs"):2,1:+$ztrnlnm("barrage_num_of_procs"))
	set NUMOFOPERS=$select(""=$ztrnlnm("barrage_num_of_opers"):200,1:+$ztrnlnm("barrage_num_of_opers"))
	set MAXSTARTTIME=30
	set MAXRUNTIME=900	; 15 minutes - should be very generous even for slow systems under load
	set MAXWAITTIME=30
	set TIMESTAMPTIME=0.01

	; Ensure that the number of possible names is at least ten times the specified number of routines.
	do assert((NUMOFRTNS*10)<(26**NAMELEN))

	; Various action flags
	set ACTSETZROUTINES=1
	set ACTWRITESOURCES=2
	set ACTDELETESOURCES=3
	set ACTDELETEOBJECTS=4
	set ACTCOMPILE=5
	set ACTLINK=6
	set ACTZRUPDATE=7
	set ACTEXECUTE=8
	set ACTMAKEDIRS=9
	set ACTTERM=10
	set ACTRCTLDUMP=11

	; Flags indicating what modes of operation are enabled.
	set (TEST,ANALYZE,REPLAY)=FALSE

	; Debug enables a few additional checks performed, such as the validation of rctldumps and source and
	; object file versions in replay mode.
	set DEBUG=TRUE

	; Stores the name of the routine to be solely included in the log file created in the analysis or replay modes.
	set BADRTN=""

	; We need to know the SIGUSR1 value on the current platform for process communication in the replay mode.
	set SIGUSR1=$ztrnlnm("sigusrval")

	; Select the label to proceed to.
	set process=$get(process,"testParent")
	if ("testParent"=process) do
	.	set TEST=TRUE
	.	do testParent
	else  if ("testChild"=process) do
	.	set TEST=TRUE
	.	do testChild
	else  if ("replayParent"=process) do
	.	set REPLAY=TRUE
	.	set analyze=+$piece($zcmdline," ",1)
	.	set logToScreen=+$piece($zcmdline," ",2)
	.	set logToFile=+$piece($zcmdline," ",3)
	.	set breakOnErrors=+$piece($zcmdline," ",4)
	.	set BADRTN=$piece($zcmdline," ",5)
	.	do replayAnalyzeParent(TRUE,analyze,logToScreen,logToFile,breakOnErrors)
	else  if ("replayChild"=process) do
	.	set REPLAY=TRUE
	.	do replayChild
	else  if ("analyzeParent"=process) do
	.	set ANALYZE=TRUE
	.	set logToScreen=+$piece($zcmdline," ",1)
	.	set logToFile=+$piece($zcmdline," ",2)
	.	set breakOnErrors=+$piece($zcmdline," ",3)
	.	set BADRTN=$piece($zcmdline," ",4)
	.	do replayAnalyzeParent(FALSE,TRUE,logToScreen,logToFile,breakOnErrors)

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                              TESTING ROUTINES SECTION                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start the test. Set up an emergency FIFO logging channel, produce an initial random set of directories and source ;
; files and fire up test jobs.                                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testParent
	new tvSec,tvUsec,errNum,FIFO,STARTTIME

	kill ^LOG,^SRCDIRS,^OBJDIRS,^RTNS,^REFS,^STARTTIME

	; Create a background process that would capture all attempted operations in a log file (in case the
	; process attempting the operation hangs or dies and therefore fails to log it in the database).
	set FIFO="fifo"
	open FIFO:fifo
	zsystem "cat "_FIFO_" > "_TESTLOG_" &"

	; Get a time reference point.
	do &gtmposix.gettimeofday(.tvSec,.tvUsec,.errNum)
	set (^STARTTIME,STARTTIME)=tvSec

	do generateFiles
	do startJobs

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly choose and perform one of the operations exercised in the test for as many times as specified.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testChild
	new i,action,FIFO,STARTTIME

	merge REFS=^REFS
	merge RTNS=^RTNS
	set STARTTIME=^STARTTIME

	set FIFO="fifo"
	open FIFO:(fifo:writeonly)

	do setZroutines
	write "$job is "_$job,!
	write "$zroutines is "_$zroutines,!

	; Randomly select and perform one of the preselected operations.
	for i=1:1:NUMOFOPERS do
	.	set action=$random(100)+1
	.	if (action<8) do writeSources quit		; 7% chance of writing new source files
	.	if (action<15) do deleteSources quit		; 7% chance of deleting source files
	.	if (action<22) do deleteObjects quit		; 7% chance of deleting object files
	.	if (action<30) do setZroutines quit		; 8% chance of setting new $zroutines
	.	if (action<38) do compile quit			; 8% chance of doing a compile
	.	if (action<46) do link quit			; 8% chance of doing an explicit link
	.	if (action<56) do zrupdate quit			; 10% chance of doing a zrupdate
	.	do executeRoutine quit				; 45% chance of invoking a routine
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start all the test jobs with unique log files and wait for them to terminate.                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
startJobs
	new i,j,jobCmd,pids,stop

	; Start all test jobs with unique error and output log files.
	for i=1:1:NUMOFPROCS do
	.	set jobCmd="^"_$text(+0)_"(""testChild""):(output=""job"_i_".mjo"":error=""job"_i_".mje"")"
	.	job @jobCmd
	.	set pids(i)=$zjob

	; Wait for all jobs to terminate.
	set stop=FALSE
	for i=1:1:NUMOFPROCS do  quit:stop
	.	for j=1:1:MAXRUNTIME set:(MAXRUNTIME=j) stop=TRUE quit:(stop)!($zsigproc(pids(i),0))  hang 1
	write:(stop) "TEST-E-FAIL, Process "_pids(i)_" did not terminate in "_MAXRUNTIME_" seconds.",!

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Produce a random setup of source and object directories as well as the initial versions of M routines.            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generateFiles
	new i,time,dirName,name,altName,fileName,fmode,errno,dirs,dirIndex,sources,srcIndex,text

	set (dirIndex,srcIndex)=1
	if $&gtmposix.umask(0,,.errno)
	set fmode=511

	set time=$$getTime()

	; Generate object directories.
	for i=1:1:NUMOFOBJDIRS do
	.	set dirName=OBJDIRPREFIX_$$generateName()
	.	set ^REFS("OBJDIRS",i)=dirName
	.	set ^OBJDIRS(dirName)=i
	.	if $&gtmposix.mkdir(dirName,fmode,.errno)
	.	do logMakedir($job,dirName,fmode)
	.	set dirs(dirIndex)=dirName
	.	set dirs(dirIndex,"src")=FALSE
	.	set dirIndex=dirIndex+1

	; Generate source directories.
	for i=1:1:NUMOFSRCDIRS do
	.	set dirName=SRCDIRPREFIX_$$generateName()
	.	set ^REFS("SRCDIRS",i)=dirName
	.	set ^SRCDIRS(dirName)=i
	.	if $&gtmposix.mkdir(dirName,fmode,.errno)
	.	do logMakedir($job,dirName,fmode)
	.	set ^SRCDIRS(dirName,"rtns")=0
	.	set dirs(dirIndex)=dirName
	.	set dirs(dirIndex,"src")=TRUE
	.	set dirIndex=dirIndex+1

	set dirs(0)=NUMOFOBJDIRS+NUMOFSRCDIRS
	do record(ACTMAKEDIRS,time,.dirs)

	set time=$$getTime()

	; Generate routine files and place them in available directories randomly.
	for i=1:1:NUMOFRTNS do
	.	set name=RTNPREFIX_$$generateName()
	.	; Occasionally create a name starting with an underscore.
	.	do:('$random(10))
	.	.	set altName="_"_$extract(name,2,NAMELEN+PREFIXLEN)
	.	.	do assert((NAMELEN+PREFIXLEN)=$length(altName))
	.	.	set:('$data(NAMES(altName))) name=altName,NAMES(name)=1
	.	set fileName=name_".m"
	.	set ^REFS("RTNS",i)=name
	.	set ^RTNS(name)=i
	.	set ^RTNS(name,"ver")=1
	.	set dirName=""
	.	for  set dirName=$order(^SRCDIRS(dirName)) quit:(""=dirName)  do
	.	.	do:($random(2))
	.	.	.	set text=$$generateRoutine(name,1)
	.	.	.	do logWriteSource($job,dirName,name,text)
	.	.	.	do writeFile(dirName_"/"_fileName,text)
	.	.	.	if $increment(^SRCDIRS(dirName,"rtns"))
	.	.	.	set ^SRCDIRS(dirName,"rtns",name)=1
	.	.	.	set sources(srcIndex)=name
	.	.	.	set sources(srcIndex,"dir")=dirName
	.	.	.	set sources(srcIndex,"ver")=1
	.	.	.	set srcIndex=srcIndex+1

	set sources(0)=srcIndex-1
	do record(ACTWRITESOURCES,time,.sources)

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Invoke the routine by the specified name in one of the ways, chosen randomly.                                     ;
;                                                                                                                   ;
; Arguments: routineName - Name of the routine.                                                                     ;
;            choice      - Index of a specific invocation method (optional).                                        ;
;            result      - Storage for recording the operation.                                                     ;
;            log         - Indicator of whether logging should be done.                                             ;
; Returns:   Text resulted (returned or set via a local) from the invocation of the routine.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
invokeRoutine(routineName,choice,result,log)
	new text,error,preExpr,postExpr

	do
	.	new $etrap
	.	set $etrap="set error=TRUE,result(""result"")=""error"",result(""error"")=$zstatus,$ecode="""""
	.	set error=FALSE
	.	set text=""
	.	set choice=$get(choice,$random(23)+1)
	.	set result("choice")=choice
	.	set result("etrap")=FALSE
	.
	.	do sanitizeRoutineName(.routineName)
	.
	.	if (choice=1) set result("expression")="do @routineName^@routineName" do:(log) logExecute($job,routineName,result("expression")) do @routineName^@routineName
	.	if (choice=2) set result("expression")="do @routineName^@(routineName)(.text)" do:(log) logExecute($job,routineName,result("expression")) do @routineName^@(routineName)(.text)
	.	if (choice=3) set result("expression")="do @(routineName_""^""_routineName)" do:(log) logExecute($job,routineName,result("expression")) do @(routineName_"^"_routineName)
	.	if (choice=4) set result("expression")="do @(routineName_""^""_routineName_""(.text)"")" do:(log) logExecute($job,routineName,result("expression")) do @(routineName_"^"_routineName_"(.text)")
	.	if (choice=5) set result("expression")="do @(routineName_""^""_routineName_"")@(.text)" do:(log) logExecute($job,routineName,result("expression")) do @(routineName_"^"_routineName)@(.text)
	.	if (choice=6) set result("expression")="do @(""^""_routineName_"")@(.text)" do:(log) logExecute($job,routineName,result("expression")) do @("^"_routineName)@(.text)
	.	if (choice=7) set result("expression")="xecute ""do ^""_routineName" do:(log) logExecute($job,routineName,result("expression")) xecute "do ^"_routineName
	.	if (choice=8) set result("expression")="xecute ""do ^""_routineName_""(.text)""" do:(log) logExecute($job,routineName,result("expression")) xecute "do ^"_routineName_"(.text)"
	.	if (choice=9) set result("expression")="xecute ""do ""_routineName_""^""_routineName" do:(log) logExecute($job,routineName,result("expression")) xecute "do "_routineName_"^"_routineName
	.	if (choice=10) set result("expression")="xecute ""do ""_routineName_""^""_routineName_""(.text)""" do:(log) logExecute($job,routineName,result("expression")) xecute "do "_routineName_"^"_routineName_"(.text)"
	.	if (choice=11) set result("expression")="set text=$$^@routineName" do:(log) logExecute($job,routineName,result("expression")) set text=$$^@routineName
	.	if (choice=12) set result("expression")="set text=$$^@(routineName)(.text)" do:(log) logExecute($job,routineName,result("expression")) set text=$$^@(routineName)(.text)
	.	if (choice=13) set result("expression")="set text=$$@routineName^@routineName" do:(log) logExecute($job,routineName,result("expression")) set text=$$@routineName^@routineName
	.	if (choice=14) set result("expression")="set text=$$@routineName^@(routineName)(.text)" do:(log) logExecute($job,routineName,result("expression")) set text=$$@routineName^@(routineName)(.text)
	.	if (choice=15) set result("expression")="goto @routineName^@routineName",result("etrap")=TRUE do:(log) logExecute($job,routineName,result("expression"),TRUE) do
	.	.	new $etrap
	.	.	set $etrap=""
	.	.	goto @routineName^@routineName
	.	if (choice=16) set result("expression")="set text=$piece($text(^@routineName),"""""""",2)" do:(log) logExecute($job,routineName,result("expression")) set text=$text(^@routineName)
	.	if (choice=17) set result("expression")="set text=$piece($text(@routineName^@routineName),"""""""",2)" do:(log) logExecute($job,routineName,result("expression")) set text=$text(@routineName^@routineName)
	.	if (choice=18) set result("expression")="set text=$piece($text(@routineName+0^@routineName),"""""""",2)" do:(log) logExecute($job,routineName,result("expression")) set text=$text(@routineName+0^@routineName)
	.	if (choice=19) set result("expression")="set text=$piece($text(+1^@routineName),"""""""",2)" do:(log) logExecute($job,routineName,result("expression")) set text=$text(+1^@routineName)
	.	if (choice=20) set result("expression")="set text=$piece($text(@routineName^@routineName),"""""""",2)" do:(log) logExecute($job,routineName,result("expression")) set text=$text(@routineName^@routineName)
	.	do:(choice>15)&(choice<21)
	.	.	if (""=text) set error=TRUE,result("result")="error",result("error")="ZLINK"
	.	.	else  set text=$piece(text,"""",2)
	.	do:(choice>20)&(choice<24)
	.	.	set preExpr="set ZPRINTLOG="""_ZPRINTLOG_""" open ZPRINTLOG:newversion use ZPRINTLOG "
	.	.	set postExpr=" close ZPRINTLOG open ZPRINTLOG use ZPRINTLOG read text:1 close ZPRINTLOG"
	.	.	open ZPRINTLOG:newversion
	.	.	use ZPRINTLOG
	.	.	do
	.	.	.	if (choice=21) set result("expression")=preExpr_"zprint ^@routineName"_postExpr do:(log) logExecute($job,routineName,result("expression")) zprint ^@routineName
	.	.	.	if (choice=22) set result("expression")=preExpr_"zprint @(""^""_routineName)"_postExpr do:(log) logExecute($job,routineName,result("expression")) zprint @("^"_routineName)
	.	.	.	if (choice=23) set result("expression")=preExpr_"xecute ""zprint ^""_routineName"_postExpr,result("etrap")=TRUE do:(log) logExecute($job,routineName,result("expression")) xecute "zprint ^"_routineName
	.	.	close ZPRINTLOG
	.	.	open ZPRINTLOG
	.	.	use ZPRINTLOG
	.	.	read text:MAXWAITTIME
	.	.	set text=$piece(text,"""",2)
	.	.	close ZPRINTLOG
	.
	.	set:('error) result("result")=text

	quit text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Execute a random routine, regardless of the process's $zroutines or the routine's object or source file status.   ;
; Log the result of execution.                                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
executeRoutine
	new time,routineIndex,routineName,result

	set routineIndex=$random(NUMOFRTNS)+1
	set routineName=REFS("RTNS",routineIndex)
	set result=routineName
	lock +^ACTION
	set time=$$getTime()
	if $$invokeRoutine(routineName,,.result,TRUE)
	lock -^ACTION
	do record(ACTEXECUTE,time,.result)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write new versions of randomly chosen source files to the random source directories.                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writeSources
	new i,time,choice,name,dirName,exists,text,sources

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines written at once.
	set sources(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	for i=1:1:sources(0) do
	.	; Avoid failures due to OS timestamp clustering by waiting a bit.
	.	hang TIMESTAMPTIME
	.	set choice=$random(NUMOFRTNS)+1
	.	set name=REFS("RTNS",choice)
	.	set choice=$random(NUMOFSRCDIRS)+1
	.	set dirName=REFS("SRCDIRS",choice)
	.	set version=$increment(^RTNS(name,"ver"))
	.	set text=$$generateRoutine(name,version)
	.	do logWriteSource($job,dirName,name,text)
	.	do writeFile(dirName_"/"_name_".m",text)
	.	set sources(i)=name
	.	set sources(i,"dir")=dirName
	.	set sources(i,"ver")=version
	.	set exists=$data(^SRCDIRS(dirName,"rtns",name))
	.	if ('exists) if $increment(^SRCDIRS(dirName,"rtns")) set ^SRCDIRS(dirName,"rtns",name)=1
	lock -^ACTION
	do record(ACTWRITESOURCES,time,.sources)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly select one or more source files and delete them.                                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deleteSources
	new i,time,count,choice,name,dirName,sources

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines deleted at once.
	set sources(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	for i=1:1:sources(0) do
	.	set choice=$random(NUMOFSRCDIRS)+1
	.	set dirName=REFS("SRCDIRS",choice)
	.	set count=^SRCDIRS(dirName,"rtns")
	.	if (0=count) set sources(i)=NOOP quit
	.	set name=RTNPREFIX_$$randstr(NAMELEN,"U")
	.	set name=$order(^SRCDIRS(dirName,"rtns",name))
	.	set:(""=name) name=$order(^SRCDIRS(dirName,"rtns",name))
	.	do assert(name'="")
	.	do logDeleteSource($job,dirName,name)
	.	do deleteFile(dirName_"/"_name_".m")
	.	set sources(i)=name
	.	set sources(i,"dir")=dirName
	.	kill ^SRCDIRS(dirName,"rtns",name)
	.	if $increment(^SRCDIRS(dirName,"rtns"),-1)
	lock -^ACTION
	do record(ACTDELETESOURCES,time,.sources)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomly select one or more object files and delete them.                                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deleteObjects
	new i,time,choice,name,baseName,dirName,objects

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines deleted at once.
	set objects(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	for i=1:1:objects(0) do
	.	set choice=$random(NUMOFOBJDIRS)+1
	.	set dirName=REFS("OBJDIRS",choice)
	.	set choice=$random(NUMOFRTNS)+1
	.	do
	.	.	new $etrap
	.	.	set $etrap="set $ecode="""",objects(i)=NOOP"
	.	.	if $&relink.chooseFileByIndex(dirName,choice,.name)
	.	.	do assert(name[".o")
	.	.	set baseName=$zparse(name,"NAME")
	.	.	do logDeleteObject($job,dirName,baseName)
	.	.	do deleteFile(dirName_"/"_name)
	.	.	set objects(i)=baseName
	.	.	set objects(i,"dir")=dirName
	lock -^ACTION
	do record(ACTDELETEOBJECTS,time,.objects)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Apply a random (but legitimate) $zroutines value.                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setZroutines
	new i,j,time,srcRefs,dirIndex,dirName,starred,zroutines

	set zroutines=""
	set zroutines(0)=$random(NUMOFOBJDIRS+1)
	for i=1:1:zroutines(0) do
	.	; We allow duplicate object directories in $zroutines.
	.	set dirIndex=$random(NUMOFOBJDIRS)+1
	.	set dirName=REFS("OBJDIRS",dirIndex)
	.	set starred=$random(2)
	.	set zroutines(i,"*")=starred
	.	set zroutines=zroutines_$select(i'=1:" ",1:"")_dirName_$select(starred:"*",1:"")
	.	set zroutines(i)=dirName
	.
	.	kill srcRefs
	.	merge srcRefs=REFS("SRCDIRS")
	.	set zroutines(i,0)=$random(NUMOFSRCDIRS+1)
	.	set:(zroutines(i,0)>0) zroutines=zroutines_"("
	.	for j=1:1:zroutines(i,0) do
	.	.	; Do not allow duplicate source directories per one object directory in $zroutines.
	.	.	for  set dirIndex=$random(NUMOFSRCDIRS)+1 quit:('$data(srcRefs(dirIndex,"used")))
	.	.	set srcRefs(dirIndex,"used")=1
	.	.	set dirName=srcRefs(dirIndex)
	.	.	set zroutines=zroutines_$select(j'=1:" ",1:"")_dirName
	.	.	set zroutines(i,j)=dirName
	.	set:(zroutines(i,0)>0) zroutines=zroutines_")"

	lock +^ACTION
	set time=$$getTime()
	do logSetZroutines($job,zroutines)
	set $zroutines=zroutines
	lock -^ACTION

	do record(ACTSETZROUTINES,time,.zroutines)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compile one or more randomly selected source files.                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
compile
	new i,time,choice,name,dirName,dest,routines

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines compiled at once.
	set routines(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	for i=1:1:routines(0) do
	.	; Avoid failures due to OS timestamp clustering by waiting a bit.
	.	hang TIMESTAMPTIME
	.	set choice=$random(NUMOFSRCDIRS)+1
	.	set dirName=REFS("SRCDIRS",choice)
	.	set count=^SRCDIRS(dirName,"rtns")
	.	if (0=count) set routines(i)=NOOP quit
	.	set name=RTNPREFIX_$$randstr(NAMELEN,"U")
	.	set name=$order(^SRCDIRS(dirName,"rtns",name))
	.	set:(""=name) name=$order(^SRCDIRS(dirName,"rtns",name))
	.	do
	.	.	new $etrap
	.	.	set $etrap="set routines(i,""result"")=""error"",routines(i,""error"")=$zstatus,$ecode="""""
	.	.	set routines(i)=name
	.	.	set routines(i,"dir")=dirName
	.	.	set choice=$random(NUMOFOBJDIRS)+1
	.	.	set dest=REFS("OBJDIRS",choice)
	.	.	set routines(i,"dst")=dest
	.	.	do logZcompile($job,dirName,name,dest)
	.	.	zcompile "-object="_dest_"/"_name_".o "_dirName_"/"_name_".m"
	.	.	set routines(i,"result")="success"
	lock -^ACTION
	do record(ACTCOMPILE,time,.routines)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Link one or more randomly selected object files.                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
link
	new i,time,choice,name,baseName,dirName,objects

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines linked at once.
	set objects(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	for i=1:1:objects(0) do
	.	set choice=$random(NUMOFOBJDIRS)+1
	.	set dirName=REFS("OBJDIRS",choice)
	.	set choice=$random(NUMOFRTNS)+1
	.	do
	.	.	new $etrap
	.	.	set $etrap="set $ecode="""",objects(i)=NOOP"
	.	.	if $&relink.chooseFileByIndex(dirName,choice,.name)
	.	.	do assert(name[".o")
	.	.	set baseName=$zparse(name,"NAME")
	.	.	set objects(i)=baseName
	.	.	set objects(i,"dir")=dirName
	.	.	do logZlink($job,dirName,baseName)
	.	.	zlink dirName_"/"_name
	.	.	set objects(i,"result")="success"
	lock -^ACTION
	do record(ACTLINK,time,.objects)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ZRUPDATE one or more randomly selected (potentially missing) object files.                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zrupdate
	new i,index,time,choice,name,dirName,objects,error

	set choice=$random(20)
	; 75% chance of one, 20% chance of two, and 5% chance of three routines linked at once.
	set objects(0)=$select(choice<15:1,choice<19:2,1:3)
	lock +^ACTION
	set time=$$getTime()
	set index=0
	for i=1:1:objects(0) do
	.	set choice=$random(NUMOFOBJDIRS)+1
	.	set dirName=REFS("OBJDIRS",choice)
	.	set choice=$random(NUMOFRTNS+2)-1
	.	if $increment(index)
	.	if (-1=choice) do
	.	.	; Do a ZRUPDATE on a random previously existing file.
	.	.	new $etrap
	.	.	set $etrap="set objects(index,""result"")=""error"",objects(index,""error"")=$zstatus,$ecode="""""
	.	.	set name=RTNPREFIX_$$randstr(NAMELEN,"U")
	.	.	set name=$order(^OBJDIRS(dirName,"rtns",name))
	.	.	set:(""=name) name=$order(^OBJDIRS(dirName,"rtns",name))
	.	.	if (""'=name) do
	.	.	.	do assert(name'[".o")
	.	.	.	set objects(index)=name
	.	.	.	set objects(index,"dir")=dirName
	.	.	.	do logZrupdate($job,dirName,name)
	.	.	.	zrupdate dirName_"/"_name_".o"
	.	.	.	set objects(index,"result")="success"
	.	.	else  set objects(index)=NOOP
	.	else  if (0=choice) do
	.	.	; Do a ZRUPDATE with a wildcard.
	.	.	new $etrap
	.	.	set $etrap="set objects(index,""result"")=""error"",objects(index,""error"")=$zstatus,$ecode="""""
	.	.	set objects(index)="*"
	.	.	set objects(index,"dir")=dirName
	.	.	do logZrupdate($job,dirName,"*")
	.	.	zrupdate dirName_"/*"
	.	.	set objects(index,"result")="success"
	.	else  do
	.	.	; Do a ZRUPDATE on a specific existing file.
	.	.	new $etrap
	.	.	set $etrap="set $ecode="""",objects(index)=NOOP"
	.	.	if $&relink.chooseFileByIndex(dirName,choice,.name)
	.	.	do assert(name[".o")
	.	.	set baseName=$zparse(name,"NAME")
	.	.	set objects(index)=baseName
	.	.	set objects(index,"dir")=dirName
	.	.	do logZrupdate($job,dirName,baseName)
	.	.	zrupdate dirName_"/"_name
	.	.	set objects(index,"result")="success"
	lock -^ACTION
	do record(ACTZRUPDATE,time,.objects)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate a unique name consisting of uppercase letters.                                                           ;
;                                                                                                                   ;
; Returns: A unique name.                                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generateName()
	new name
	for  set name=$$randstr(NAMELEN,"U") quit:('$data(NAMES(name)))
	set NAMES(name)=1
	quit name

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate the text of an M routine.                                                                                ;
;                                                                                                                   ;
; Arguments: rtnName - Name of the routine.                                                                         ;
;            version - Version of the routine to generate.                                                          ;
; Returns:   A text of the routine specific to the provided name and version.                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generateRoutine(rtnName,version)
	new name
	set name=rtnName
	do sanitizeRoutineName(.rtnName)
	quit rtnName_"(x) set (text,x)="""_name_" "_version_""" quit:$quit x quit"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (Over)write a file.                                                                                               ;
;                                                                                                                   ;
; Arguments: path - Path of the file to write to.                                                                   ;
;            text - Text to write.                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writeFile(path,text)
	open path:newversion
	use path
	write text,!
	close path
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Delete a file.                                                                                                    ;
;                                                                                                                   ;
; Arguments: path - Path of the file to delete.                                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deleteFile(path)
	if $&relink.removeFile(path)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obtain the current time in nanoseconds.                                                                           ;
;                                                                                                                   ;
; Returns: Current time in nanoseconds.                                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getTime()
	new tvSec,tvUsec,errNum

	do &gtmposix.gettimeofday(.tvSec,.tvUsec,.errNum)
	quit (tvSec-STARTTIME)*1E9+tvUsec

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Record in the database the operation that the current process just performed.                                     ;
;                                                                                                                   ;
; Arguments: action - Action performed.                                                                             ;
;            time   - Timestamp of the action.                                                                      ;
;            object - Variable containing the details about the operation.                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
record(action,time,object)
	new subscript

	set ^LOG(time,$job)=action
	if (ACTSETZROUTINES=action) do
	.	set subscript="zro"
	else  if (ACTWRITESOURCES=action) do
	.	set subscript="wrtsrc"
	else  if (ACTDELETESOURCES=action) do
	.	set subscript="dltsrc"
	else  if (ACTDELETEOBJECTS=action) do
	.	set subscript="dltobj"
	else  if (ACTCOMPILE=action) do
	.	set subscript="compile"
	else  if (ACTLINK=action) do
	.	set subscript="link"
	else  if (ACTZRUPDATE=action) do
	.	set subscript="zrupdate"
	else  if (ACTEXECUTE=action) do
	.	set subscript="exec"
	else  if (ACTMAKEDIRS=action) do
	.	set subscript="mkdir"
	merge ^LOG(time,$job,subscript)=object

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sanitize the specified routine name for invocation/reference purposes. Namely, replace the leading underscore     ;
; with a percent sign ('%').                                                                                        ;
;                                                                                                                   ;
; Arguments: name - Routine name to sanitize (passed by reference).                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sanitizeRoutineName(name)
	set:("_"=$extract(name,1)) name="%"_$extract(name,2,NAMELEN+PREFIXLEN)
	do assert((NAMELEN+PREFIXLEN)=$length(name))
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore the specified routine name for lookup/storage purposes. Namely, replace the leading percent sign with an  ;
; underscore ('_').                                                                                                 ;
;                                                                                                                   ;
; Arguments: name - Routine name to restore (passed by reference).                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restoreRoutineName(name)
	set:("%"=$extract(name,1)) name="_"_$extract(name,2,NAMELEN+PREFIXLEN)
	do assert((NAMELEN+PREFIXLEN)=$length(name))
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message to either an emergency channel (FIFO device) or a specific file, depending on the execution mode.   ;
;                                                                                                                   ;
; Arguments: message - Message to log.                                                                              ;
;            pid     - ID of the process for which to log the message.                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
log(message,pid)
	new file,saveIO

	set saveIO=$io
	if ('REPLAY)&('ANALYZE) do
	.	use FIFO
	.	write:(""'=$get(pid)) ";;;;;;;;;;;;;;;; "_pid_" ;;;;;;;;;;;;;;;;",!
	.	write message,!
	else  do
	.	if (REPLAY) set file=REPLAYLOG
	.	else  do assert(ANALYZE) set file=ANALYZELOG
	.
	.	open file:append
	.	use file
	.	write:(""'=$get(pid))&(1'=NUMOFPROCS) ";;;;;;;;;;;;;;;; "_pid_" ;;;;;;;;;;;;;;;;",!
	.	write " "_message,!
	.	close file
	use saveIO
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current directory creation operation.                       ;
;                                                                                                                   ;
; Arguments: pid     - ID of the process performing the operation.                                                  ;
;            dirName - Name of the created directory.                                                               ;
;            fmode   - Directory permissions to use.                                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logMakedir(pid,dirName,fmode)
	do log("if $&gtmposix.mkdir("""_dirName_""","_fmode_",.errno)",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current writing of a source file.                           ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the target directory.                                                               ;
;            fileName - Name of the target file.                                                                    ;
;            text     - Text to write to the file.                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logWriteSource(pid,dirName,fileName,text)
	do assert(fileName'[".")
	do log("hang "_TIMESTAMPTIME_" set x="""_dirName_"/"_fileName_".m"" open x:new use x write "_$zwrite(text)_",! close x",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current deletion of a source file.                          ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the target directory.                                                               ;
;            fileName - Name of the target file.                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logDeleteSource(pid,dirName,fileName)
	do assert(fileName'[".")
	do log("set x="""_dirName_"/"_fileName_".m"" open x close x:delete",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current deletion of an object file.                         ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the created directory.                                                              ;
;            fileName - Name of the target file.                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logDeleteObject(pid,dirName,fileName)
	do assert(fileName'[".")
	do log("set x="""_dirName_"/"_fileName_".o"" open x close x:delete",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current execution of a routine.                             ;
;                                                                                                                   ;
; Arguments: pid        - ID of the process performing the operation.                                               ;
;            name       - Name of the routine to execute.                                                           ;
;            expression - Expression to execute the routine.                                                        ;
;            extraEtrap - Indicates the need for an extra etrap wrap (optional); FALSE by default.                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logExecute(pid,name,expression,extraEtrap)
	do log("set routineName="""_name_"""",pid)
	do log("set text=""""")
	do log("do")
	do log(". new $etrap set $etrap=""use $principal set $ecode=""""""""""")
	if ($get(extraEtrap,FALSE)) do
	.	do log(". do")
	.	do log(". . new $etrap set $etrap=""set $ecode=""""""""""")
	.	do log(". . "_expression)
	else  do log(". "_expression)
	do log(". write ""L"_$increment(LBLCNT)_": Invocation of '"_name_"' resulted in '""_text_""'"",!")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current setting of $zroutines.                              ;
;                                                                                                                   ;
; Arguments: pid       - ID of the process performing the operation.                                                ;
;            zroutines - The $zroutines value to set.                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logSetZroutines(pid,zroutines)
	do log("set $zroutines="""_zroutines_"""",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current zcompile operation.                                 ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the source file's directory.                                                        ;
;            fileName - Name of the source file.                                                                    ;
;            dest     - Name of the target object directory.                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logZcompile(pid,dirName,fileName,dest)
	do assert(fileName'[".")
	do log("hang "_TIMESTAMPTIME_" zcompile ""-object="_dest_"/"_fileName_".o "_dirName_"/"_fileName_".m""",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current zlink operation.                                    ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the object file's directory.                                                        ;
;            fileName - Name of the object file.                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logZlink(pid,dirName,fileName)
	do assert(fileName'[".")
	do log("zlink """_dirName_"/"_fileName_".o""",pid)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message with the M code needed to reproduce the current zrupdate operation.                                 ;
;                                                                                                                   ;
; Arguments: pid      - ID of the process performing the operation.                                                 ;
;            dirName  - Name of the object file's directory.                                                        ;
;            fileName - Name of the object file.                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logZrupdate(pid,dirName,fileName)
	do assert(fileName'[".")
	do log("do",pid)
	do log(". new $etrap set $etrap=""set $ecode=""""""""""")
	do log(". zrupdate """_dirName_"/"_$select(fileName="*":"*",1:fileName_".o")_"""")
	do log(". write ""L"_$increment(LBLCNT)_": ZRUPDATE of '"_dirName_"/"_fileName_"' succeeded"",!")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verify whether the expression asserted evaluates to TRUE. If not, print the issuing line, create a zjobexam dump, ;
; and halt.                                                                                                         ;
;                                                                                                                   ;
; Arguments: statement - Statement to evaluate.                                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
assert(statement)
	new i,level,location,text,char,parens

	quit:(1=statement)

	; Go up until the assert is found; then obtain the text of the statement.
	for level=$stack:-1:0 set location=$stack(level,"PLACE") quit:($stack(level,"PLACE")'["assert")
	set text=$piece($text(@location),"assert(",2)

	; Extract the actual thing for which we assert.
	set parens=0
	for i=1:1 set char=$extract(text,i) quit:(""=char)  do  quit:(parens<0)
	.       set:("("=char) parens=parens+1
	.       set:(")"=char) parens=parens-1
	set text=$extract(text,1,i-1)

	; Print the failed assert, dump a ZJOBEXAM, and terminate.
	use $principal
	write "TEST-E-FAIL, Assert failed in "_location_": "_text,!
	if $zjobexam()
	zhalt 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return a random string.                                                                                           ;
;                                                                                                                   ;
; Arguments: strlen   - Length of the string to generate.                                                           ;
;            patcodes - String specifying sets characters that can be used in the string.                           ;
; Returns:   A random string of length strlen consisting of characters from the set(s) specified in patcodes.       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randstr(strlen,patcodes)
	new i,n,z,charset
	new a,x,y
	for i=1:1:127 set x=$get(x)_$char(i)
	for i=$ascii("A"):1:$ascii("Z"),$ascii("a"):1:$ascii("z") set a=$get(a)_$char(i)
	set patcodes="1."_$select($length($get(patcodes)):$translate(patcodes,$translate(patcodes,a)),1:"AN")
	for i=1:1:$length(x) set y=$extract(x,i) set:y?@patcodes charset=$get(charset)_y
	set n=$length(charset),z=""
	for i=1:1:$select($length($get(strlen)):strlen,1:8) set z=z_$extract(charset,$random(n)+1)
	quit z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                        REPLAY AND ANALYSIS ROUTINES SECTION                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entry point for test replay.                                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
replay
	do init("replayParent")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Entry point for test analysis.                                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
analyze
	do init("analyzeParent")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start the replay and/or analysis of a prior test run. In case of replay, create and sanitize the replay directory ;
; and start up replay jobs. Using interrupts and a global, delegate, in chronological order, the operations to the  ;
; appropriate jobs (unless can be performed by this process directly) and wait for their completion. If analysis is ;
; desired, verify that the results are valid, issuing errors if they are not.                                       ;
;                                                                                                                   ;
; Arguments: replay        - Flag to instruct the program to replay the actions of a prior test.                    ;
;            analyze       - Flag to instruct the program to analyze a prior test.                                  ;
;            logToScreen   - Flag to instruct the program to log generic actions to the screen.                     ;
;            logToFile     - Flag to instruct the program to log detailed actions to a file.                        ;
;            breakOnErrors - Flag to instruct the program to break on validation errors (only if analyze is TRUE).  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
replayAnalyzeParent(replay,analyze,logToScreen,logToFile,breakOnErrors)
	new i,j,file,jobCmd,jobs,time,pid,index,curPid,refs,action,name,choice,expression,extraEcode
	new fmode,dir,dst,ver,isSrcDir,zroutines,errno,proceed
	new JOBPIDS

	do assert(replay!analyze)

	if $&gtmposix.umask(0,,.errno)
	set fmode=511

	; In case we will be logging to a file, make sure to delete previous logs.
	if (logToFile) do
	.	if (REPLAY) set file=REPLAYLOG
	.	else  do assert(ANALYZE) set file=ANALYZELOG
	.	open file
	.	close file:delete

	if (replay) do
	.	; Create a new file for RCTLDUMPs of the jobs.
	.	if (DEBUG) do
	.	open RCTLLOG:newversion
	.	close RCTLLOG
	.
	.	; Set up an interrupt handler for communication with child processes.
	.	set $zinterrupt="set proceed=TRUE"
	.
	.	; (Re)create the replay directory.
	.	do &relink.removeDirectory("replay")
	.	if $&gtmposix.mkdir(REPLAYDIR,fmode,.errno)
	.
	.	; Start the replay jobs.
	.	set ^PARENTPID=$job
	.	set ^JOBS=NUMOFPROCS
	.	for i=1:1:NUMOFPROCS do
	.	.	set jobCmd="^"_$text(+0)_"(""replayChild""):(output=""replay_job"_i_".mjo"":error=""replay_job"_i_".mje"":default="""_REPLAYDIR_""")"
	.	.	job @jobCmd
	.	.	set jobs(i)=$zjob
	.	merge JOBPIDS=jobs
	.
	.	; Make sure that all jobs are started before proceeding.
	.	for i=1:1:MAXSTARTTIME quit:(0=^JOBS)  hang 1
	.	if (0'=^JOBS) write "TEST-E-FAIL, Processes did not start up in "_MAXSTARTTIME_" seconds.",! zhalt 1
	.
	.	; Finally make the replay directory our current one.
	.	set $zdirectory=REPLAYDIR

	set time=""
	for  set time=$order(^LOG(time)) quit:(""=time)  do
	.	set pid=""
	.	for i=1:1 set pid=$order(^LOG(time,pid)) quit:(""=pid)  do
	.	.	; Two or more jobs cannot submit their actions per one timestamp.
	.	.	do assert(i=1)
	.	.	set action=^LOG(time,pid)
	.	.
	.	.	; When replaying, we need to know what action to assign to what process, so we remap the pids from the test run
	.	.	; to the current children's pids in a one-to-one and onto fashion. Otherwise, we keep the current pids.
	.	.	if (replay) do
	.	.	.	if (ACTSETZROUTINES=action)!(ACTCOMPILE=action)!(ACTLINK=action)!(ACTEXECUTE=action)!(ACTZRUPDATE=action) do
	.	.	.	.	if ($data(refs(pid))) set curPid=refs(pid)
	.	.	.	.	else  do
	.	.	.	.	.	set index=$order(jobs(""))
	.	.	.	.	.	do assert(""'=index)
	.	.	.	.	.	set curPid=jobs(index)
	.	.	.	.	.	set refs(pid)=curPid
	.	.	.	.	.	kill jobs(index)
	.	.	.	else  set curPid=$job
	.	.	else  do
	.	.	.	set curPid=pid
	.	.
	.	.	; Identify the action and act accordingly.
	.	.	if (ACTSETZROUTINES=action) do
	.	.	.	merge zroutines=^LOG(time,pid,"zro")
	.	.	.	write:(logToScreen) "ACTSETZROUTINES: "_zroutines_" ("_pid_")",!
	.	.	.	if (replay) do
	.	.	.	.	set ^ACTION(curPid)=action
	.	.	.	.	set ^ACTION(curPid,"object")=zroutines
	.	.	.	.	do issueSignalAndWait(curPid)
	.	.	.	if (analyze) do
	.	.	.	.	do simulateSetZroutines(pid,.zroutines)
	.	.	.	.	merge PROCS(pid,"zro")=zroutines
	.	.	.	do:(logToFile) logSetZroutines(curPid,PROCS(pid,"zro"))
	.	.	else  if (ACTWRITESOURCES=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"wrtsrc",0) do
	.	.	.	.	set name=^LOG(time,pid,"wrtsrc",j)
	.	.	.	.	set dir=^LOG(time,pid,"wrtsrc",j,"dir")
	.	.	.	.	set ver=^LOG(time,pid,"wrtsrc",j,"ver")
	.	.	.	.	set text=$$generateRoutine(name,ver)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	write:(logToScreen) "ACTWRITESOURCES: "_dir_"/"_name_".m ("_ver_")"_" ("_pid_")",!
	.	.	.	.	do:(replay) writeFile(dir_"/"_name_".m",text)
	.	.	.	.	if (analyze) do
	.	.	.	.	.	set SRCDIRS(dir,name)=1
	.	.	.	.	.	set SRCDIRS(dir,name,"ver")=ver
	.	.	.	.	.	set SRCDIRS(dir,name,"time")=time
	.	.	.	.	do:(logToFile)&(name[BADRTN) logWriteSource(curPid,dir,name,text)
	.	.	else  if (ACTDELETESOURCES=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"dltsrc",0) do
	.	.	.	.	set name=^LOG(time,pid,"dltsrc",j)
	.	.	.	.	quit:(NOOP=name)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	set dir=^LOG(time,pid,"dltsrc",j,"dir")
	.	.	.	.	write:(logToScreen) "ACTDELETESOURCES: "_dir_"/"_name_".m"_" ("_pid_")",!
	.	.	.	.	do:(replay) deleteFile(dir_"/"_name_".m")
	.	.	.	.	kill:(analyze) SRCDIRS(dir,name)
	.	.	.	.	do:(logToFile)&(name[BADRTN) logDeleteSource(curPid,dir,name)
	.	.	else  if (ACTDELETEOBJECTS=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"dltobj",0) do
	.	.	.	.	set name=^LOG(time,pid,"dltobj",j)
	.	.	.	.	quit:(NOOP=name)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	set dir=^LOG(time,pid,"dltobj",j,"dir")
	.	.	.	.	write:(logToScreen) "ACTDELETEOBJECTS: "_dir_"/"_name_".o"_" ("_pid_")",!
	.	.	.	.	do:(replay) deleteFile(dir_"/"_name_".o")
	.	.	.	.	zkill:(analyze) OBJDIRS(dir,name)
	.	.	.	.	do:(logToFile)&(name[BADRTN) logDeleteObject(curPid,dir,name)
	.	.	else  if (ACTCOMPILE=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"compile",0) do
	.	.	.	.	set name=^LOG(time,pid,"compile",j)
	.	.	.	.	quit:(NOOP=name)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	set dir=^LOG(time,pid,"compile",j,"dir")
	.	.	.	.	set dst=^LOG(time,pid,"compile",j,"dst")
	.	.	.	.	write:(logToScreen) "ACTCOMPILE: "_dir_"/"_name_".m -> "_dst_"/"_name_".o"_" ("_pid_")",!
	.	.	.	.	if (replay) do
	.	.	.	.	.	set ^ACTION(curPid)=action
	.	.	.	.	.	set ^ACTION(curPid,"object")="-object="_dst_"/"_name_".o "_dir_"/"_name_".m"
	.	.	.	.	.	do issueSignalAndWait(curPid)
	.	.	.	.	if (analyze) do
	.	.	.	.	.	set OBJDIRS(dst,name)=1
	.	.	.	.	.	set OBJDIRS(dst,name,"ver")=SRCDIRS(dir,name,"ver")
	.	.	.	.	.	set OBJDIRS(dst,name,"time")=time
	.	.	.	.	.	set OBJDIRS(dst,name,"srcDir")=dir
	.	.	.	.	do:(logToFile)&(name[BADRTN) logZcompile(curPid,dir,name,dst)
	.	.	else  if (ACTLINK=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"link",0) do
	.	.	.	.	set name=^LOG(time,pid,"link",j)
	.	.	.	.	quit:(NOOP=name)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	set dir=^LOG(time,pid,"link",j,"dir")
	.	.	.	.	write:(logToScreen) "ACTLINK: "_dir_"/"_name_".o"_" ("_pid_")",!
	.	.	.	.	if (replay) do
	.	.	.	.	.	set ^ACTION(curPid)=action
	.	.	.	.	.	set ^ACTION(curPid,"object")=dir_"/"_name_".o"
	.	.	.	.	.	do issueSignalAndWait(curPid)
	.	.	.	.	do:(analyze) simulateLink(pid,dir,name,breakOnErrors)
	.	.	.	.	do:(logToFile)&(name[BADRTN) logZlink(curPid,dir,name)
	.	.	else  if (ACTZRUPDATE=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"zrupdate",0) do
	.	.	.	.	set name=^LOG(time,pid,"zrupdate",j)
	.	.	.	.	quit:(NOOP=name)
	.	.	.	.	do assert(name'[".")
	.	.	.	.	set dir=^LOG(time,pid,"zrupdate",j,"dir")
	.	.	.	.	write:(logToScreen) "ACTZRUPDATE: "_dir_"/"_$select(name="*":"*",1:name_".o")_" ("_pid_")",!
	.	.	.	.	if (replay) do
	.	.	.	.	.	set ^ACTION(curPid)=action
	.	.	.	.	.	set ^ACTION(curPid,"object")=dir_"/"_$select(name="*":"*",1:name_".o")
	.	.	.	.	.	do issueSignalAndWait(curPid)
	.	.	.	.	do:(logToFile)&((name[BADRTN)!(name["*")) logZrupdate(curPid,dir,name)
	.	.	.	.	do:(analyze)
	.	.	.	.	.	set result=^LOG(time,pid,"zrupdate",j,"result")
	.	.	.	.	.	set error=$select("error"=result:^LOG(time,pid,"exec","error"),1:"")
	.	.	.	.	.	do simulateZrupdate(pid,dir,name,result,error,breakOnErrors)
	.	.	else  if (ACTEXECUTE=action) do
	.	.	.	set name=^LOG(time,pid,"exec")
	.	.	.	write:(logToScreen) "ACTEXECUTE: "_name_" ("_pid_")",!
	.	.	.	if (replay) do
	.	.	.	.	set choice=^LOG(time,pid,"exec","choice")
	.	.	.	.	set ^ACTION(curPid)=action
	.	.	.	.	set ^ACTION(curPid,"object")=name
	.	.	.	.	set ^ACTION(curPid,"choice")=choice
	.	.	.	.	do issueSignalAndWait(curPid)
	.	.	.	if (logToFile)&(name[BADRTN) do
	.	.	.	.	set expression=^LOG(time,pid,"exec","expression")
	.	.	.	.	set extraEtrap=^LOG(time,pid,"exec","etrap")
	.	.	.	.	do logExecute(curPid,name,expression,extraEtrap)
	.	.	.	if (analyze) do
	.	.	.	.	set result=^LOG(time,pid,"exec","result")
	.	.	.	.	set error=$select("error"=result:^LOG(time,pid,"exec","error"),1:"")
	.	.	.	.	do simulateExec(pid,time,name,result,error,breakOnErrors)
	.	.	else  if (ACTMAKEDIRS=action) do
	.	.	.	for j=1:1:^LOG(time,pid,"mkdir",0) do
	.	.	.	.	set dir=^LOG(time,pid,"mkdir",j)
	.	.	.	.	write:(logToScreen) "ACTMAKEDIRS: "_dir_" ("_pid_")",!
	.	.	.	.	if (replay) do
	.	.	.	.	.	if $&gtmposix.mkdir(dir,fmode,.errno)
	.	.	.	.	if (analyze) do
	.	.	.	.	.	set isSrcDir=^LOG(time,pid,"mkdir",j,"src")
	.	.	.	.	.	set:(isSrcDir) SRCDIRS(dir)=0
	.	.	.	.	.	set:('isSrcDir) OBJDIRS(dir)=0
	.	.	.	.	do:(logToFile) logMakedir(curPid,dir,fmode)
	.	.	; DEBUG-ONLY:
	.	.	if (DEBUG&replay) do
	.	.	.	do validateFileVersions
	.	.	.	do:(analyze)
	.	.	.	.	set curPid=""
	.	.	.	.	for  set curPid=$order(refs(curPid)) quit:(""=curPid)  do
	.	.	.	.	.	; Open the file in which we log RCTLDUMPs in APPEND mode, so that we can first print an identification line
	.	.	.	.	.	; to it before a child process follows with some data. Then we still have the file open and at a position
	.	.	.	.	.	; from which we can read to the end (in validateRctlDump()) to get the exact content printed by the child.
	.	.	.	.	.	open RCTLLOG:append
	.	.	.	.	.	use RCTLLOG
	.	.	.	.	.	write ";;;;;;;;;;;;;;;;;; "_curPid_" ("_refs(curPid)_") ;;;;;;;;;;;;;;;;;;",!
	.	.	.	.	.	use $principal
	.	.	.	.	.	set ^ACTION(refs(curPid))=ACTRCTLDUMP
	.	.	.	.	.	set ^ACTION(refs(curPid),"object")=""
	.	.	.	.	.	do issueSignalAndWait(refs(curPid))
	.	.	.	.	.	do validateRctlDump(curPid)

	; Instruct all children to terminate.
	do:(replay) terminateJobs

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform the operation the parent replay process has assigned to the current process (via a global) and respond    ;
; (by sending back an interrupt) upon its completion.                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
replayChild
	new i,action,object,choice,interrupt

	; Area of future improvement: add logging for the children too and consider returning the result of such operations
	; as ZRUPDATE and routine invocation on replay.
	write "$job is "_$job,!
	set parentPid=^PARENTPID
	set $zinterrupt="set interrupt=1"
	set interrupt=0
	if $increment(^JOBS,-1)
	for i=1:1 do:interrupt  hang TIMESTAMPTIME if (i=100) set i=0 if $zsigproc(parentPid,0) write "TEST-E-FAIL, Master replay process died." zhalt 1
	.	quit:('$data(^ACTION($job)))
	.	set action=^ACTION($job)
	.	set object=^ACTION($job,"object")
	.	if (ACTSETZROUTINES=action) do
	.	.	set $zroutines=object
	.	else  if (ACTCOMPILE=action) do
	.	.	zcompile object
	.	else  if (ACTLINK=action) do
	.	.	zlink object
	.	else  if (ACTZRUPDATE=action) do
	.	.	do
	.	.	.	new $etrap
	.	.	.	set $etrap="write $zstatus,! set $ecode="""""
	.	.	.	zrupdate object
	.	else  if (ACTEXECUTE=action) do
	.	.	set choice=^ACTION($job,"choice")
	.	.	set text=$$invokeRoutine(object,choice,,FALSE)
	.	.	write text,!
	.	else  if (ACTRCTLDUMP=action) do
	.	.	open RCTLLOG:append
	.	.	use RCTLLOG
	.	.	zshow "A"
	.	.	close RCTLLOG
	.	else  if (ACTTERM=action) do
	.	.	if $zsigproc(parentPid,SIGUSR1)
	.	.	zhalt 0
	.	kill ^ACTION($job)
	.	set interrupt=0
	.	if $zsigproc(parentPid,SIGUSR1) write "TEST-E-FAIL, Master replay process died." zhalt 1
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Send a SIGUSR1 to all child processes with an instruction to terminate.                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
terminateJobs
	new i

	for i=1:1:NUMOFPROCS do
	.	set ^ACTION(JOBPIDS(i))=ACTTERM
	.	set ^ACTION(JOBPIDS(i),"object")=""
	.	do issueSignalAndWait(JOBPIDS(i))
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Send a SIGUSR1 to a process and wait for acknowledgement (via a reciprocal interrupt).                            ;
;                                                                                                                   ;
; Arguments: pid - ID of the process to be hit with an interrupt.                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
issueSignalAndWait(pid)
	new i

	set proceed=0
	if $zsigproc(pid,SIGUSR1)
	for i=1:1:(MAXWAITTIME*100) quit:proceed  hang TIMESTAMPTIME
	if ('proceed) write "TEST-E-FAIL, Did not receive a response from process "_pid_" in "_MAXWAITTIME_" seconds.",! break:DEBUG  zhalt 1
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go through all source and object directories known to this process and make sure that source and object files'    ;
; versions are what we expect them to be.                                                                           ;
;                                                                                                                   ;
; NOTE: DEBUG-ONLY                                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validateFileVersions
	new i,dir,name,invName,ver,file,actualVer,zroutines,zdirectory

	; First, go through all the source directories and read the text of every routine, making sure it is correct.
	set dir=""
	for  set dir=$order(SRCDIRS(dir)) quit:(""=dir)  do
	.	set name=""
	.	for  set name=$order(SRCDIRS(dir,name)) quit:(""=name)  do
	.	.	set ver=SRCDIRS(dir,name,"ver")
	.	.	set file=dir_"/"_name_".m"
	.	.	open file:readonly
	.	.	use file
	.	.	read actualVer
	.	.	close file
	.	.	set actualVer=+$piece($piece(actualVer,"""",2)," ",2)
	.	.	if (actualVer'=ver) do
	.	.	.	write "TEST-E-FAIL, Routine "_name_"'s actual version in "_dir_" is "_actualVer_" while "_ver_" was expected.",!
	.	.	.	break

	set zroutines=$zroutines
	set zdirectory=$zdirectory
	; Then go through all the object directories, temporarily changing $zroutines and $zdirectory to avoid potential compilations, and execute
	; every routine, making sure that the ascertained version is correct.
	for  set dir=$order(OBJDIRS(dir)) quit:(""=dir)
	.	set name=""
	.	for  set (name,invName)=$order(OBJDIRS(dir,name)) quit:(""=name)  do:($data(OBJDIRS(dir,name))#10)
	.	.	set ver=OBJDIRS(dir,name,"ver")
	.	.	set $zdirectory=zdirectory_dir
	.	.	set $zroutines="."
	.	.	zlink name_".o"
	.	.	do sanitizeRoutineName(.invName)
	.	.	set actualVer=$piece($$^@invName," ",2)
	.	.	if (actualVer'=ver) do
	.	.	.	write "TEST-E-FAIL, Routine "_name_"'s actual version in "_dir_" is "_actualVer_" while "_ver_" was expected.",!
	.	.	.	break
	set $zdirectory=zdirectory
	set $zroutines=zroutines

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Validate that the set of relink control structures that the specified process has open is valid and that the      ;
; information contained in those structures is correct.                                                             ;
;                                                                                                                   ;
; Arguments: pid - ID of the process whose view of relink control structures is to be validated.                    ;
;                                                                                                                   ;
; NOTE: DEBUG-ONLY                                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validateRctlDump(pid)
	new i,line,entries,num,pos1,pos2,objDirs,objDir,rtnName

	; Read whatever lines have been added by job processes and extract relevant information. A typical RCTL dump looks like this:
	;
	;   Object Directory         : /extra1/testarea1/.../relink_0/memleak
	;   Relinkctl filename       : /tmp/gtm-relinkctl-945748b645177f392aa3698ac6c65f92
	;   # of routines / max      : 4 / 50000
	;   # of attached processes  : 3
	;   Relinkctl shared memory  : shmid: 1314848795  shmlen: 0x57c6000
	;   Rtnobj shared memory # 1 : shmid: 1314914375  shmlen: 0x100000  shmused: 0x2000  shmfree: 0xfe000  objlen: 0x1910
	;   Rtnobj shared memory # 2 : shmid: 1314979916  shmlen: 0x200000  shmused: 0x100000  shmfree: 0x100000  objlen: 0xfe2d0
	;       rec#1: rtnname: memleak  cycle: 1  objhash: 0xcf13390b55a9f488  numvers: 1  objlen: 0x1910  shmlen: 0x2000
	;       rec#2: rtnname: rtn1  cycle: 1  objhash: 0x45f8fcc37decff0  numvers: 0  objlen: 0x0  shmlen: 0x0
	;       rec#3: rtnname: rtn2  cycle: 1  objhash: 0x524ac1e14b0bdb86  numvers: 0  objlen: 0x0  shmlen: 0x0
	;       rec#4: rtnname: rtn3  cycle: 1  objhash: 0xa9fd144499e782cb  numvers: 0  objlen: 0x0  shmlen: 0x0
	;   ...

	use RCTLLOG:follow
	set entries=0
	for i=1:1 use RCTLLOG read line:0 quit:('$test)  do
	.	if (line["Object Directory") do
	.	.	set entries=entries+1
	.	.	set entries(entries)=$zparse($piece(line," ",12),"NAME")
	.	.	set entries(entries,0)=0
	.	else  if (line["    rec#") do
	.	.	set pos1=$find(line,"rec#")
	.	.	set pos2=$find(line,":",pos1)-2
	.	.	do assert((0<pos1)&(0<pos2))
	.	.	set num=+$translate($extract(line,pos1,pos2)," ")
	.	.	do assert((0<entries)&((entries(entries,0)+1)=num))
	.	.	set num=$increment(entries(entries,0))
	.	.	set entries(entries,num)=$piece(line," ",7)
	.	.	set entries(entries,num,"cycle")=+$piece(line," ",10)
	close RCTLLOG
	use $principal

	; First, copy all object directory information, then remove whatever the process cannot know about.
	merge objDirs=OBJDIRS
	set objDir=""
	for  set objDir=$order(objDirs(objDir)) quit:(""=objDir)  do
	.	kill:('$data(PROCS(pid,"dirs",objDir))) objDirs(objDir)

	for i=1:1:entries do
	.	set objDir=entries(i)
	.	for j=1:1:entries(i,0) do
	.	.	set rtnName=entries(i,j)
	.	.	do restoreRoutineName(.rtnName)
	.	.	; We are not verifying whether the object still exists because we may have deleted it after it has been shared.
	.	.	if ('$data(objDirs(objDir,rtnName))) do
	.	.	.	write "TEST-E-FAIL, Routine "_rtnName_" is not expected to be found in "_objDir_"'s relink control file.",!
	.	.	.	break
	.	.	; Yet the cycles better match because we know of all processes that update the routine.
	.	.	if (entries(i,j,"cycle")'=$get(objDirs(objDir,rtnName,"cycle"),-1)) do
	.	.	.	write "TEST-E-FAIL, Routine "_rtnName_"'s cycle number in "_objDir_" is "_entries(i,j,"cycle")
	.	.	.	write " while "_$get(objDirs(objDir,rtnName,"cycle"),-1)_" was expected.",!
	.	.	.	break
	.	.	kill objDirs(objDir,rtnName)

	kill entries
	set objDir=""
	for  set objDir=$order(objDirs(objDir)) quit:(""=objDir)  do
	.	set rtnName=""
	.	for  set rtnName=$order(objDirs(objDir,rtnName)) quit:(""=rtnName)  do
	.	.	if (0<=$get(objDirs(objDir,rtnName,"cycle"),-1)) set entries(objDir,rtnName)=1

	if ($data(entries)) do
	.	write "TEST-E-FAIL, The following autorelink-enabled routines are not present in autorelink control structures:",!
	.	zwrite entries
	.	break

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mark every routine that the process linked in autorelink-enabled fashion as requiring a relink and enrich the     ;
; process with the knowledge of rctl info for each of the starred directories in the new $zroutines.                ;
;                                                                                                                   ;
; Arguments: pid          - ID of the process to update the status of its routines.                                 ;
;            newZroutines - Process's new $zroutines.                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simulateSetZroutines(pid,newZroutines)
	new i,name

	set name=""
	for  set name=$order(PROCS(pid,"rtns",name)) quit:(""=name)  kill:(PROCS(pid,"rtns",name,"*")) PROCS(pid,"rtns",name)
	for i=1:1:newZroutines(0) set:(newZroutines(i,"*")) PROCS(pid,"dirs",newZroutines(i))=1
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simulate a zlink of a particular routine (with .o extension specified to avoid recompiles) by updating the        ;
; process- and object-directory-specific state structures.                                                          ;
;                                                                                                                   ;
; Arguments: pid   - ID of the process to simulate a link.                                                          ;
;            dir   - Directory of the object routine to link.                                                       ;
;            name  - Name of the linked routine.                                                                    ;
;            break - Flag instructing to break on validation errors.                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simulateLink(pid,dir,name,break)
	new i,ver,starred,stop,dirName,dirsToUpdateCycle

	set ver=OBJDIRS(dir,name,"ver")
	set starred=FALSE
	set stop=FALSE

	; See if we have the specified directory in our $zroutines.
	for i=1:1:PROCS(pid,"zro",0) do  quit:stop
	.	set dirName=PROCS(pid,"zro",i)
	.	set starred=PROCS(pid,"zro",i,"*")
	.	set:(starred) dirsToUpdateCycle(dirName)=1
	.	set:(dirName=dir) stop=TRUE

	; We are going to replace the old search history and link information for the routine with the new ones.
	kill PROCS(pid,"rtns",name)

	; If so and the directory is autorelink-enabled, initialize the cycle (if not yet done) in every directory we looked.
	do:(stop&starred)
	.	set dirName=""
	.	for  set dirName=$order(dirsToUpdateCycle(dirName)) quit:(""=dirName)  do
	.	.	set OBJDIRS(dirName,name,"cycle")=$get(OBJDIRS(dirName,name,"cycle"),0)
	.	.	set PROCS(pid,"rtns",name,dirName,"cycle")=OBJDIRS(dirName,name,"cycle")

	; Update the process knowledge of the routine with the directory from which it is to be linked.
	set PROCS(pid,"rtns",name,"*")=$select(stop:starred,1:FALSE)
	set PROCS(pid,"rtns",name,"dir")=dir

	write:(logToScreen&stop) "-- Routine "_name_" is linked from "_dir_" ("_$select(starred:"starred",1:"non-starred")_")",!

	; If we found the routine in an autorelink-enabled directory, see if the new object needs to put in shared memory. However,
	; if the routine is now to be linked statically, remove all references to it in shared memory.
	if (starred&stop) do
	.	do simulateObjectSharing(pid,dir,OBJDIRS(dir,name,"srcDir"),name,ver,break)
	else  do
	.	do clearRoutineSharedRefs(pid,name)

	; When we do an explicit ZLINK on an object file directly, we do not check if a newer source is available,
	; regardless of whether our $zroutines includes the file and whether the directory that does is "starred."
	set PROCS(pid,"rtns",name,"ver")=ver

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove process-specific references to a particular routine in shared memory, so that if all such references are   ;
; gone, simulateObjectSharing() would actually simulate place a particular variant of this routine (in regards to   ;
; the version and object and source directories) in shared memory.                                                  ;
;                                                                                                                   ;
; Arguments: pid       - ID of the process sharing the new object code.                                             ;
;            name      - Name of the routine.                                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clearRoutineSharedRefs(pid,name)
	kill RCTLSHM(name,$get(PROCSRTNREFS(pid,"rtns",name,"ver")),$get(PROCSRTNREFS(pid,"rtns",name,"dir")),$get(PROCSRTNREFS(pid,"rtns",name,"srcDir")),pid)
	kill PROCSRTNREFS(pid,"rtns",name)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simulate the conditional placement of the new object code in shared memory based on the routine's version.        ;
;                                                                                                                   ;
; Arguments: pid       - ID of the process sharing the new object code.                                             ;
;            dir       - Directory of the object file to share.                                                     ;
;            srcDir    - Directory containing the source file of the routine.                                       ;
;            name      - Name of the routine.                                                                       ;
;            ver       - Version of the routine to be placed in shared memory; if equal to the current, then the    ;
;                        operation is a no-op.                                                                      ;
;            break     - Flag instructing to break on validation errors.                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simulateObjectSharing(pid,dir,srcDir,name,ver,break)
	; To update the object in shared memory, this particular variant should not be there. The uniqueness of an object variant depends on
	; the version of the routine, object directory from which it was linked, and the source directory from which the object was compiled.
	if ('$data(RCTLSHM(name,ver,dir,srcDir))) do
	.	write:(logToScreen) "-- Variant of routine "_name_" in "_dir_" (in regards to version and object and source directories) "
	.	write:(logToScreen) "is not found in shared memory - loading...",!
	.
	.	; Loading a new object in shared memory, so a ZRUPDATE is required.
	.	do simulateZrupdate(pid,dir,name,"success",,break)
	.
	.	; Update process-private knowledge of the updated cycle number.
	.	set PROCS(pid,"rtns",name,dir,"cycle")=OBJDIRS(dir,name,"cycle")
	else  do
	.	write:(logToScreen) "-- Variant of routine "_name_" in "_dir_" (in regards to version and object and source directories) "
	.	write:(logToScreen) "is already found in shared memory - loading...",!

	; Whether *we* loaded the object into shared memory or someone else did, make sure we have a reference to it. Since, however, this
	; process might be referencing a different variant of the routine than before, remove any prior reference first, and then add the
	; new one (which might or might not be the same).
	do clearRoutineSharedRefs(pid,name)
	set RCTLSHM(name,ver,dir,srcDir,pid)=1
	set PROCSRTNREFS(pid,"rtns",name,"ver")=ver
	set PROCSRTNREFS(pid,"rtns",name,"srcDir")=srcDir
	set PROCSRTNREFS(pid,"rtns",name,"dir")=dir
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simulate a zrupdate of a particular routine by bumping up its cycle number in the respective object directory's   ;
; state structure.                                                                                                  ;
;                                                                                                                   ;
; Arguments: pid    - ID of the process to simulate a zrupdate.                                                     ;
;            dir    - Directory of the object routine to zrupdate.                                                  ;
;            name   - Name of the zrupdated routine (could be '*').                                                 ;
;            result - Result of zrupdating the routine in a prior test.                                             ;
;            error  - Error encountered while zrupdating the routine in a prior test (may be empty).                ;
;            break  - Flag instructing to break on validation errors.                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simulateZrupdate(pid,dir,name,result,error,break)
	new rtnName,expectedError,found

	set found=0
	set expectedError=""
	; Expand the wildcard, if present.
	if ("*"=name) do
	.	set rtnName=""
	.	for  set rtnName=$order(OBJDIRS(dir,rtnName)) quit:(""=rtnName)  do:(1=($data(OBJDIRS(dir,rtnName))#10))
	.	.	set OBJDIRS(dir,rtnName,"cycle")=$get(OBJDIRS(dir,rtnName,"cycle"),0)+1
	.	.	set found=1
	else  set OBJDIRS(dir,name,"cycle")=$get(OBJDIRS(dir,name,"cycle"),0)+1,found=1

	; Indicate that this process now knows the dir rctldump info.
	set:(found) PROCS(pid,"dirs",dir)=1

	if (""'=expectedError) do  quit
	.	if ("error"'=result) do  quit
	.	.	write "TEST-E-FAIL, Expected an error ('"_expectedError_"') from process "_pid_" but got none.",!
	.	.	break:break
	.
	.	if (error'[expectedError) do  quit
	.	.	write "TEST-E-FAIL, Expected error '"_expectedError_"' from process "_pid_" but got '"_error_"'.",!
	.	.	break:break

	if (""=expectedError)&("error"=result) do  quit
	.	write "TEST-E-FAIL, Did not expect an error from process "_pid_" but got one ('"_error_"').",!
	.	break:break

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simulate an execution of a particular routine, updating various state structures based on the need to recompile   ;
; and relink, as determined by the comparison of source and object files' timestamps and cycle numbers of a routine ;
; in-process and in the relink control structure.                                                                   ;
;                                                                                                                   ;
; Arguments: pid    - ID of the process to simulate a routine execution.                                            ;
;            time   - Timestamp to assign to an object file in case of a (re)compilation.                           ;
;            name   - Name of the executed routine.                                                                 ;
;            result - Result of executing the routine in a prior test.                                              ;
;            error  - Error encountered while executing the routine in a prior test (may be empty).                 ;
;            break  - Flag instructing to break on validation errors.                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
simulateExec(pid,time,name,result,error,break)
	new i,j,dir,objVersion,srcVersion,objTime,srcTime,objDir,srcDir,expectedError,needsLink,stop,dirsToUpdateCycle

	set (objVersion,srcVersion)=0
	set (objTime,srcTime)=0
	set starred=FALSE
	set expectedError=""
	set needsLink=FALSE

	if ('$data(PROCS(pid,"rtns",name))) do
	.	write:(logToScreen) "-- Routine "_name_" never linked before",!
	.	set needsLink=TRUE
	else  do
	.	write:(logToScreen) "-- Routine "_name_" is still linked (from "_PROCS(pid,"rtns",name,"dir")_")",!
	.	; If the directory from which we last linked the routine is starred, then we need to go over the relink control structures of
	.	; all starred directories in our $zroutines and see if any of them has a cycle number higher than what the process has on record.
	.	if (PROCS(pid,"rtns",name,"*")) do
	.	.	set stop=FALSE
	.	.	for i=1:1:PROCS(pid,"zro",0) do:(PROCS(pid,"zro",i,"*"))  quit:(needsLink)!(stop)
	.	.	.	; See if we found the directory from which the routine was last linked; no need to search past it.
	.	.	.	set objDir=PROCS(pid,"zro",i)
	.	.	.	set:(objDir=PROCS(pid,"rtns",name,"dir")) stop=TRUE
	.	.	.
	.	.	.	; It is not possible to not have this directory in the routine's validation list if the routine has been linked.
	.	.	.	do assert(-1'=$get(PROCS(pid,"rtns",name,objDir,"cycle"),-1))
	.	.	.
	.	.	.	; It is also not possible for the directory to not contain an entry for this routine if the routine has been linked from some
	.	.	.	; (not necessarily same) starred directory.
	.	.	.	do assert(-1'=$get(OBJDIRS(objDir,name,"cycle"),-1))
	.	.	.
	.	.	.	; The cycle of a particular routine per a particular object directory cannot exceed the object directory's cycle because the
	.	.	.	; latter reflects the maximum across all processes that ever updated the routine in that directory.
	.	.	.	do assert(PROCS(pid,"rtns",name,objDir,"cycle")<=OBJDIRS(objDir,name,"cycle"))
	.	.	.
	.	.	.	; Indicate that a relink is needed if the cycle has been incremented.
	.	.	.	if (PROCS(pid,"rtns",name,objDir,"cycle")<OBJDIRS(objDir,name,"cycle")) do
	.	.	.	.	write:(logToScreen) "-- Routine "_name_"'s cycle in "_objDir_" is higher than in process",!
	.	.	.	.	set needsLink=TRUE

	if (needsLink) do
	.	write:(logToScreen) "-- Routine "_name_" needs to be linked",!
	.
	.	; Go through $zroutines and find the first available version of the routine.
	.	for i=1:1:PROCS(pid,"zro",0) do  quit:(0'=objVersion)!(0'=srcVersion)
	.	.	set objDir=PROCS(pid,"zro",i)
	.	.	for j=1:1:PROCS(pid,"zro",i,0) do  quit:(0'=srcVersion)
	.	.	.	set srcDir=PROCS(pid,"zro",i,j)
	.	.	.	if ($data(SRCDIRS(srcDir,name))) do
	.	.	.	.	set srcVersion=SRCDIRS(srcDir,name,"ver")
	.	.	.	.	set srcTime=SRCDIRS(srcDir,name,"time")
	.	.	if ($data(OBJDIRS(objDir,name))#10) do
	.	.	.	set objVersion=OBJDIRS(objDir,name,"ver")
	.	.	.	set objTime=OBJDIRS(objDir,name,"time")
	.
	.	if (0<objVersion) do
	.	.	; Found an object file.
	.	.	if (srcTime>objTime) do
	.	.	.	; A process found a newer source which it would compile.
	.	.	.	set OBJDIRS(objDir,name,"ver")=srcVersion
	.	.	.	set OBJDIRS(objDir,name,"time")=time
	.	.	.	set OBJDIRS(objDir,name,"srcDir")=srcDir
	.	.	.
	.	.	.	write:(logToScreen) "-- Compiling "_srcDir_"/"_name_".m to "_objDir_" (newer source)",!
	.	.
	.	.	; Now simulate linking.
	.	.	do simulateLink(pid,objDir,name,break)
	.	else  if (0<srcVersion) do
	.	.	; Found a source file but no object, so the source gets compiled.
	.	.	set OBJDIRS(objDir,name)=1
	.	.	set OBJDIRS(objDir,name,"ver")=srcVersion
	.	.	set OBJDIRS(objDir,name,"time")=time
	.	.	set OBJDIRS(objDir,name,"srcDir")=srcDir
	.	.
	.	.	write:(logToScreen) "-- Compiling "_srcDir_"/"_name_".m to "_objDir_" (missing object)",!
	.	.
	.	.	; Now simulate linking.
	.	.	do simulateLink(pid,objDir,name,break)
	.	else  do
	.	.	; Neither source nor object was found.
	.	.	write:(logToScreen) "-- Routine "_name_" could not be linked",!
	.	.
	.	.	; Expect the ZLINK error.
	.	.	set expectedError="ZLINKFILE"

	if (""'=expectedError)&("error"'=result) do  quit
	.	write "TEST-E-FAIL, Expected an error ('"_expectedError_"') from process "_pid_" but got none.",!
	.	break:break

	if (""=expectedError)&("error"=result) do  quit
	.	write "TEST-E-FAIL, Did not expect an error from process "_pid_" but got one ('"_error_"').",!
	.	break:break

	if ("error"=result)&(error'["ZLINK") do  quit
	.	write "TEST-E-FAIL, An error other than 'ZLINK' occurred in process "_pid_": "_error_".",!
	.	break:break

	quit:(""'=expectedError)!("error"=result)

	if (result'[name) do  quit
	.	write "TEST-E-FAIL, Text of the routine executed by process "_pid_" ('"_result_"') does not match the name of the routine ('"_name_"').",!
	.	break:break

	if ($piece(result," ",2)'=$get(PROCS(pid,"rtns",name,"ver"),-1)) do  quit
	.	write "TEST-E-FAIL, Expected the version of the routine ('"_name_"') executed by process "_pid_" to be "_$get(PROCS(pid,"rtns",name,"ver"),-1)_" rather than "_$piece(result," ",2)_".",!
	.	break:break

	quit
