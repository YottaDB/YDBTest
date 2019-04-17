//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.     //
// All rights reserved.                                         //
//                                                              //
//      This source code contains the intellectual property     //
//      of its copyright holder(s), and is made available       //
//      under a license.  If you do not know the terms of       //
//      the license, please stop and do not read further.       //
//                                                              //
//////////////////////////////////////////////////////////////////

package main

import (
	"fmt"
	"imp"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
	"os"
	"os/exec"
	"strconv"
	"time"
)

// Constant definition(s)
const tptoken uint64 = yottadb.NOTTP

// Golang implementation of imptp using multiple processes as workers (basically a translation of simplethreadapi_imptp.c). This file
// contains the main routine that handles initialization and firing off of the workers after which time it exits leaving the workers
// running. The imptpjobgo routine is what is run in each process. This could have been made into a single unified file but since golang
// requires driving an exec() that executes something and reinitializes the process (unlike the C versions do), we have split imptp.m
// functionality into two pieces rather than having some super secret argument to indicate a separate process is being initialited and
// bypassing all the main routine's initialization stuff like how threeenp1C2 was written.

// Main routine for imptp. Generally speaking, we are using the Easy API in this main routine since most accesses are one-off with no
// looping to speak of but will use SimpleAPI (threaded) in the actual workers we create (impjobgo) where looping is prevalent.
func main() {
	var valint, valint2, secs, istp, tpnoiso, dupset int32
	var valint64 int64
	var dataval uint32
	var valstr string
	var err error
	var i int
	var pidstr, childstr string
	var stdoutp, stderrp *os.File
	var gblprefix = []string{"a", "b", "c", "d", "e", "f", "g", "h"}

	defer yottadb.Exit() // Needed to assure proper cleanup
	processID := os.Getpid()
	// Initialize random number generator seed
	rand.Seed(time.Now().UnixNano())
	// Implement M code
	//
	// MCode: set jobcnt=$$jobcnt
	valstr = os.Getenv("gtm_test_jobcnt")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	if 0 == valint {
		valint = 5
	}
	jobcnt := valint
	fmt.Println("jobcnt =", jobcnt)
	jobcntstr := fmt.Sprintf("%d", jobcnt)
	err = yottadb.SetValE(tptoken, nil, jobcntstr, "jobcnt", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// Implement M entryref : imptp^imptp
	//
	// MCode: write "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	fmt.Println("Start time of parent:", time.Now().Format("01/02/2019 01:02:03.000"))
	// MCode: write "$zro=",$zro,!
	zro, err := yottadb.ValE(tptoken, nil, "$zroutines", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	fmt.Printf("$zro=%s\n", zro)
	// MCode: write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
	fmt.Printf("PID: %d\nIn hex: %x\n", processID, processID)

	// Start processing test system parameters
	//
	// istp = 0 non-tp
	// istp = 1 TP
	// istp = 2 ZTP
	//
	// MCode: set fillid=+$ztrnlnm("gtm_test_dbfillid")
	valstr = os.Getenv("gtm_test_dbfillid")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	fillid := valint
	fillidstr := fmt.Sprintf("%d", fillid)
	err = yottadb.SetValE(tptoken, nil, fillidstr, "fillid", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if $ztrnlnm("gtm_test_tp")="NON_TP"  do
	// MCode: . set istp=0
	// MCode: . write "It is Non-TP",!
	// MCode: else  do
	// MCode: . if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
	// MCode: . else  set istp=1  write "It is TP",!
	// MCode: set ^%imptp(fillid,"istp")=istp
	valstr = os.Getenv("gtm_test_tp")
	if "NON_TP" == valstr {
		istp = 0
		fmt.Println("It is Non-TP")
	} else {
		valstr = os.Getenv("gtm_test_dbfill")
		if ("" != valstr) && ("IMPZTP" == valstr) {
			istp = 2
			fmt.Println("It is ZTP")
			panic("Cannot simulate ZTP with SimpleAPI - should not be using this imptp flavor")
		} else {
			istp = 1
			fmt.Println("It is TP")
		}
	}
	istpstr := fmt.Sprintf("%d", istp)
	err = yottadb.SetValE(tptoken, nil, istpstr, "istp", []string{}) // set local istp
	if imp.CheckErrorReturn(err) {
		return
	}
	err = yottadb.SetValE(tptoken, nil, istpstr, "^%imptp", []string{fillidstr, "istp"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp(fillid,"tptype")="ONLINE"
	// MCode: else  set ^%imptp(fillid,"tptype")="BATCH"
	valstr = os.Getenv("gtm_test_tptype")
	if ("" != valstr) && ("ONLINE" == valstr) {
		err = yottadb.SetValE(tptoken, nil, "ONLINE", "^%imptp", []string{fillidstr, "tptype"})
	} else {
		err = yottadb.SetValE(tptoken, nil, "BATCH", "^%imptp", []string{fillidstr, "tptype"})
	}
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
	// MCode: if '$data(^%imptp(fillid,"tpnoiso")) do
	// MCode: .  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
	// MCode: .  else  set ^%imptp(fillid,"tpnoiso")=0
	dataval, err = yottadb.DataE(tptoken, nil, "^%imptp", []string{fillidstr, "tpnoiso"})
	if imp.CheckErrorReturn(err) {
		return
	}
	if 0 == dataval {
		tpnoiso = 0
		if 1 == istp {
			valstr = os.Getenv("gtm_test_noisolation")
			if (("" != valstr) && ("TPNOISO" == valstr)) || (1 == int(rand.Float64()*2)) {
				tpnoiso = 1
			}
		}
		err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", tpnoiso), "^%imptp", []string{fillidstr, "tpnoiso"})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: ; Randomly 50% time use optimization for redundant sets, only if not already set.
	// MCode: if '$data(^%imptp(fillid,"dupset")) do
	// MCode: .  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
	// MCode: .  else  set ^%imptp(fillid,"dupset")=
	dataval, err = yottadb.DataE(tptoken, nil, "^%imptp", []string{fillidstr, "dupset"})
	if imp.CheckErrorReturn(err) {
		return
	}
	if 0 == dataval {
		dupset = int32(rand.Float64() * 2)
		err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", dupset), "^%imptp", []string{fillidstr, "dupset"})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
	valstr = os.Getenv("gtm_test_crash")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	crash := valint
	err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", crash), "^%imptp", []string{fillidstr, "crash"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
	valstr = os.Getenv("gtm_test_is_gtcm")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	isgtcm := valint
	err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", isgtcm), "^%imptp", []string{fillidstr, "gtcm"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
	valstr = os.Getenv("gtm_test_repl_norepl")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	replnorepl := valint
	err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", replnorepl), "^%imptp", []string{fillidstr, "skipreg"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
	valstr = os.Getenv("gtm_test_jobid")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	jobid := valint
	jobidstr := fmt.Sprintf("%d", jobid)
	err = yottadb.SetValE(tptoken, nil, jobidstr, "jobid", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%imptp("fillid",jobid)=fillid
	err = yottadb.SetValE(tptoken, nil, fillidstr, "^%imptp", []string{"fillid", jobidstr})
	if imp.CheckErrorReturn(err) {
		return
	}
	// Throughout this C program small portions of code are implemented using call-ins (instead of SimpleAPI/SimpleThreadAPI)
	// because either it is not possible to migrate or because it is easier to keep it as is (no benefit of extra
	// test coverage for SimpleAPI/SimpleThreadAPI).
	//
	// MCode: ; Grab the key and record size from DSE
	// MCode: do get^datinfo("^%imptp("_fillid_")")
	_, err = yottadb.CallMT(tptoken, nil, 0, "getdatinfo")
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode")
	valstr = os.Getenv("gtm_test_spannode")
	if "" != valstr {
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	spannode := valint
	err = yottadb.SetValE(tptoken, nil, fmt.Sprintf("%d", spannode), "^%imptp", []string{fillidstr, "gtm_test_spannode"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; if triggers are installed, the following will invoke the trigger
	// MCode: ; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
	// MCode: ; ^%imptp(fillid,"trigger") to 1
	// MCode: set ^%imptp(fillid,"trigger")=0
	err = yottadb.SetValE(tptoken, nil, "0", "^%imptp", []string{fillidstr, "trigger"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
	// MCode: else  if ^%imptp(fillid,"totaljob")'=jobcnt  write "IMPTP-E-MISMATCH: Job number mismatch",!  zwrite ^%imptp  h
	dataval, err = yottadb.DataE(tptoken, nil, "^%imptp", []string{fillidstr, "totaljob"})
	if imp.CheckErrorReturn(err) {
		return
	}
	if 0 == dataval {
		err = yottadb.SetValE(tptoken, nil, jobcntstr, "^%imptp", []string{fillidstr, "totaljob"})
		if imp.CheckErrorReturn(err) {
			return
		}
	} else {
		valstr, err = yottadb.ValE(tptoken, nil, "^%imptp", []string{fillidstr, "totaljob"})
		if imp.CheckErrorReturn(err) {
			return
		}
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
		if valint != jobcnt {
			fmt.Printf("IMPTP-E-MISMATCH: Job number mismatch : ^%%imptp(fillid,totaljob) = %d : jobcnt = %d\n",
				valint, jobcnt)
			os.Exit(-1)
		}
	}
	// MCode: ;
	// MCode: ; End of processing test system paramters
	// MCode: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	// MCode: ;
	// MCode: ;   This program fills database randomly using primitive root of a field.
	// MCode: ;   Say, w is the primitive root and we have 5 jobs
	// MCode: ;   Job 1 : Sets index w^0, w^5, w^10 etc.
	// MCode: ;   Job 2 : Sets index w^1, w^6, w^11 etc.
	// MCode: ;   Job 3 : Sets index w^2, w^7, w^12 etc.
	// MCode: ;   Job 4 : Sets index w^3, w^8, w^13 etc.
	// MCode: ;   Job 5 : Sets index w^4, w^9, w^14 etc.
	// MCode: ;   In above example nroot = w^5
	// MCode: ;   In above example root =  w
	// MCode: ;   Precalculate primitive root for a prime and set them here
	//
	// MCode: set ^%imptp(fillid,"prime")=50000017	;Precalculated
	err = yottadb.SetValE(tptoken, nil, "50000017", "^%imptp", []string{fillidstr, "prime"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%imptp(fillid,"root")=5          ;Precalculated
	err = yottadb.SetValE(tptoken, nil, "5", "^%imptp", []string{fillidstr, "root"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^endloop(fillid)=0	;To stop infinite loop
	err = yottadb.SetValE(tptoken, nil, "0", "^endloop", []string{fillidstr})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child
	dataval, err = yottadb.DataE(tptoken, nil, "^cntloop", []string{fillidstr})
	if imp.CheckErrorReturn(err) {
		return
	}
	if 0 == dataval {
		err = yottadb.SetValE(tptoken, nil, "0", "^cntloop", []string{fillidstr})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child
	dataval, err = yottadb.DataE(tptoken, nil, "^cntseq", []string{fillidstr})
	if imp.CheckErrorReturn(err) {
		return
	}
	if 0 == dataval {
		err = yottadb.SetValE(tptoken, nil, "0", "^cntseq", []string{fillidstr})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: set ^%imptp(fillid,"jsyncnt")=0	; To count number of processes that are ready to be killed by crash scripts
	err = yottadb.SetValE(tptoken, nil, "0", "^%imptp", []string{fillidstr, "jsyncnt"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; If test is running with gtm_test_spanreg'=0, we want to make sure the// MCode:xarr global variables continue to
	// MCode: ; cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
	// MCode: ; See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
	// MCode: ; unconditionally (gtm_test_spanreg is 0 or not) excluding all these globals from random mapping to multiple regions.
	//
	// MCode: set gblprefix="abcdefgh"
	// MCode: for i=1:1:$length(gblprefix) set ^%sprgdeExcludeGbllist($extract(gblprefix,i)_"ndxarr")=""
	for i = 0; i < len(gblprefix); i++ {
		err = yottadb.SetValE(tptoken, nil, "", "^%sprgdeExcludeGbllist", []string{gblprefix[i] + "ndxarr"})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: Before forking off children, make sure all buffered IO is flushed out (or else the children would inherit
	// MCode: the unflushed buffers and will show up duplicated in the children's stdout/stderr.
	// CCode: fflush(NULL);
	// ** Note this flush is not done in Golang because os.Stdout is not buffered.
	//
	// MCode: Since "jmaxwait" local variable (in com/imptp.m) is undefined at this point, the caller
	// MCode: will invoke "endtp.csh" later to wait for the children to die. Therefore set ^%jobwait global
	// MCode: to point to those pids.
	//
	// MCode: set ^%jobwait(jobid,"njobs")=njobs   ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, jobcntstr, "^%jobwait", []string{jobidstr, "njobs"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jmaxwait")=7200 ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "7200", "^%jobwait", []string{jobidstr, "jmaxwait"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jdefwait")=7200 ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "7200", "^%jobwait", []string{jobidstr, "jdefwait"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jprint")=0      ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "0", "^%jobwait", []string{jobidstr, "jprint"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jroutine")="impjob_imptp" ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "impjob_imptp", "^%jobwait", []string{jobidstr, "jroutine"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jjoname")="impjob_imptp" ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "impjob_imptp", "^%jobwait", []string{jobidstr, "jmjoname"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set ^%jobwait(jobid,"jnoerrchk")="0" ; Taken from com/job.m
	err = yottadb.SetValE(tptoken, nil, "0", "^%jobwait", []string{jobidstr, "jnoerrchk"})
	if imp.CheckErrorReturn(err) {
		return
	}
	// Note - this golang version won't be calling ydb_child_init() on its own - let that part of the testing rest with the
	//        C version of this routine.
	//
	// MCode: do ^job("impjob^imptp",jobcnt,"""""")	; Taken from com/imptp.m
	// For golang, we create this proc array but index it starting at 1 so make the array one larger than it needs to be
	proc := make([]*exec.Cmd, jobcnt + 1, jobcnt + 1)
	for child := int32(1); child <= jobcnt; child++ {
		childstr = fmt.Sprintf("%d", child)
		proc[child] = exec.Command("go/src/impjobgo/impjobgo", childstr)
		// We have the command we want to fork off but setup its stdout/stderr to go directly to output files
		stdoutp, err = os.Create("./impjob_imptp" + jobidstr + ".mjo" + childstr) // should be gjo/gje but easier for testsystem this way
		if imp.CheckErrorReturn(err) {
		}
		proc[child].Stdout = stdoutp
		defer stdoutp.Close()
		stderrp, err = os.Create("./impjob_imptp" + jobidstr + ".mje" + childstr)
		if imp.CheckErrorReturn(err) {
		}
		proc[child].Stderr = stderrp
		defer stderrp.Close()
		err = proc[child].Start() // Start new process
		if imp.CheckErrorReturn(err) {
		}
		// MCode: [for i=1:1:njobs]  set ^(i)=jobindex(i)	: com/job.m
		pidstr = fmt.Sprintf("%d", proc[child].Process.Pid)
		err = yottadb.SetValE(tptoken, nil, pidstr, "^%jobwait", []string{jobidstr, childstr})
		if imp.CheckErrorReturn(err) {
			return
		}
		err = yottadb.SetValE(tptoken, nil, pidstr, "jobindex", []string{childstr})
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: do writecrashfileifneeded			: com/job.m
	_, err = yottadb.CallMT(tptoken, nil, 0, "writecrashfileifneeded")
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: do writejobinfofileifneeded			: com/job.m
	_, err = yottadb.CallMT(tptoken, nil, 0, "writejobinfofileifneeded")
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; Wait until the first update on all regions happen
	// MCode: set start=$horolog
	// MCode: for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
	// MCode: write:$$^difftime(stop,start)>300 "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
	for secs = 0; 300 > secs; secs++ {
		valstr, err = yottadb.ValE(tptoken, nil, "^cntloop", []string{fillidstr})
		if imp.CheckErrorReturn(err) {
			return
		}
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
		if 0 != valint {
			break
		}
		time.Sleep(1 * time.Second)
	}
	if 300 == secs {
		fmt.Println("TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!")
	}
	// MCode: ; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	// MCode: set timeout=600	; 10 minutes to start and reach the sync point for kill
	// MCode: for i=1:1:600 hang 1 quit:^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"totaljob")
	// MCode: if ^%imptp(fillid,"jsyncnt")<^%imptp(fillid,"totaljob") do
	// MCode: . write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
	// MCode: . zwrite ^%imptp
	for secs = 0; 600 > secs; secs++ {
		valstr, err = yottadb.ValE(tptoken, nil, "^%imptp", []string{fillidstr, "jsyncnt"})
		if imp.CheckErrorReturn(err) {
			return
		}
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
		valstr, err = yottadb.ValE(tptoken, nil, "^%imptp", []string{fillidstr, "totaljob"})
		if imp.CheckErrorReturn(err) {
			return
		}
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint2 = int32(valint64)
		if valint2 == valint {
			break
		}
		time.Sleep(1 * time.Second)
	}
	if valint < valint2 {
		fmt.Println("TEST-E-imptp.m time out for jobs to start and synch after 600 seconds")
	}
	// MCode: do writeinfofileifneeded ;(not sure what this comment means - it isn't what is being done)
	valstr = os.Getenv("gtm_test_onlinerollback")
	if "TRUE" == valstr {
		panic("TEST-F-NOONLINEROLLBACK Online rollback cannot be supported with the Simple[Thread]API")
	}
	// MCode: write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	fmt.Println("End   Time of parent:", time.Now().Format("01/02/2019 01:02:03.000"))
	// MCode: quit
	return
}
