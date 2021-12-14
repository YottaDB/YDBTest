#!/usr/bin/env python
#################################################################
#                                                               #
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################
import os
import subprocess
import datetime
import random
import sys
import time

import yottadb


if __name__ == '__main__':
    try:
        jobcnt = os.environ["gtm_test_jobcnt"]
    except KeyError:
        # If this test is run outside of YDBTest, need to set `jobcnt` manually
        jobcnt = "5"
    yottadb.set("jobcnt", value=jobcnt)

    print(f"jobcnt = {jobcnt}")
    print(f"Start time of parent: {datetime.datetime.now()}")
    print(f'$zro={yottadb.get("$zroutines")}')
    print(f"PID: {os.getpid()}")

    # Start processing test system parameters
    #
    # istp = 0 non-tp
    # istp = 1 TP
    # istp = 2 ZTP
    #
    # MCode: set fillid=+$ztrnlnm("gtm_test_dbfillid")
    try:
        fillid = os.environ["gtm_test_dbfillid"]
    except KeyError:
        # If this test is run outside of YDBTest, need to set `fillid` manually
        fillid = "0"
    yottadb.set("fillid", value=fillid)

    # MCode: if $ztrnlnm("gtm_test_tp")="NON_TP"  do
    # MCode: . set istp=0
    # MCode: . write "It is Non-TP",!
    # MCode: else  do
    # MCode: . if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
    # MCode: . else  set istp=1  write "It is TP",!
    # MCode: set ^%imptp(fillid,"istp")=istp
    try:
        istp = os.environ["gtm_test_tp"]
    except KeyError:
        istp = 1

    if "NON_TP" == istp:
        istp = 0
        print("It is Non-TP")
    else:
        try:
            dbfill = os.environ["gtm_test_dbfill"]
        except KeyError:
            dbfill = "IMPTP"
        if "IMPZTP" == dbfill:
            istp = 2
            print("It is ZTP")
            raise Exception("Cannot simulate ZTP with YDBPython - should not be using this imptp flavor")
        else:
            istp = 1
            print("It is TP")

    yottadb.set("istp", value=str(istp))
    yottadb.set("^%imptp", (fillid, "istp"), str(istp))

    # MCode: if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp(fillid,"tptype")="ONLINE"
    # MCode: else  set ^%imptp(fillid,"tptype")="BATCH"
    try:
        tptype = os.environ["gtm_test_tptype"]
        if "ONLINE" != tptype:
            tptype = "BATCH"
    except KeyError:
        tptype = "BATCH"
    yottadb.set("^%imptp", (fillid, "tptype"), tptype)

    # MCode: ; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
    # MCode: if '$data(^%imptp(fillid,"tpnoiso")) do
    # MCode: .  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
    # MCode: .  else  set ^%imptp(fillid,"tpnoiso")=0
    if 0 == yottadb.data("^%imptp", (fillid, "tpnoiso")):
        tpnoiso = 0
        if 1 == istp:
            try:
                noisolation = os.environ["gtm_test_noisolation"]
            except KeyError:
                noisolation = ""
            if "TPNOISO" == noisolation or 1 == random.randint(0, 1):
                tpnoiso = 1
        yottadb.set("^%imptp", (fillid, "tpnoiso"), str(tpnoiso))

    # MCode: ; Randomly 50% time use optimization for redundant sets, only if not already set.
    # MCode: if '$data(^%imptp(fillid,"dupset")) do
    # MCode: .  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
    # MCode: .  else  set ^%imptp(fillid,"dupset")=
    if 0 == yottadb.data("^%imptp", (fillid, "dupset")):
        dupset = random.randint(0, 1)
        yottadb.set("^%imptp", (fillid, "dupset"), str(dupset))

    # MCode: set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
    try:
        crash = os.environ["gtm_test_crash"]
    except KeyError:
        crash = "0"
    yottadb.set("^%imptp", (fillid, "crash"), str(int(crash)))

    # MCode: set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
    try:
        is_gtcm = os.environ["gtm_test_is_gtcm"]
    except KeyError:
        is_gtcm = "0"
    yottadb.set("^%imptp", (fillid, "gtcm"), str(int(is_gtcm)))

    # MCode: set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
    try:
        replnorepl = os.environ["gtm_test_repl_norepl"]
    except KeyError:
        replnorepl = "0"
    yottadb.set("^%imptp", (fillid, "skipreg"), str(int(replnorepl)))

    # MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
    try:
        jobid = os.environ["gtm_test_jobid"]
    except KeyError:
        jobid = "0"
    yottadb.set("jobid", value=jobid)
    # MCode: set ^%imptp("fillid",jobid)=fillid
    yottadb.set("^%imptp", ("fillid", jobid), str(int(fillid)))

    # Throughout this Python small portions of code are implemented using call-ins instead of YDBPython API calls.
    # This is done when it is either not possible to migrate or because it is easier to keep it as is without any
    # loss of test coverage.
    #
    # MCode: ; Grab the key and record size from DSE
    # MCode: do get^datinfo("^%imptp("_fillid_")")
    yottadb.ci("getdatinfo")

    # MCode: set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode")
    try:
        spannode = os.environ["gtm_test_spannode"]
    except KeyError:
        spannode = "0"
    print(f"spannode: {spannode}")
    yottadb.set("^%imptp", (fillid, "gtm_test_spannode"), str(int(spannode)))

    # MCode: ; if triggers are installed, the following will invoke the trigger
    # MCode: ; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
    # MCode: ; ^%imptp(fillid,"trigger") to 1
    # MCode: set ^%imptp(fillid,"trigger")=0
    yottadb.set("^%imptp", (fillid, "trigger"), "0")

    # MCode: if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
    # MCode: else  if ^%imptp(fillid,"totaljob")'=jobcnt  write "IMPTP-E-MISMATCH: Job number mismatch",!  zwrite ^%imptp  h
    if 0 == yottadb.data("^%imptp", (fillid, "totaljob")):
        yottadb.set("^%imptp", (fillid, "totaljob"), str(int(jobcnt)))
    else:
        totaljob = int(yottadb.get("^%imptp", (fillid, "totaljob")).decode("utf-8"))
        if totaljob != int(jobcnt):
            raise Exception(f"IMPTP-E-MISMATCH: Job number mismatch : ^%%imptp(fillid,totaljob) = {totaljob} : jobcnt = {jobcnt}\n")

    # MCode: ;
    # MCode: ; End of processing test system paramters
    # MCode: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    # MCode: ;
    # MCode: ;   This program fills database randomly using primitive root of a field.
    # MCode: ;   Say, w is the primitive root and we have 5 jobs
    # MCode: ;   Job 1 : Sets index w^0, w^5, w^10 etc.
    # MCode: ;   Job 2 : Sets index w^1, w^6, w^11 etc.
    # MCode: ;   Job 3 : Sets index w^2, w^7, w^12 etc.
    # MCode: ;   Job 4 : Sets index w^3, w^8, w^13 etc.
    # MCode: ;   Job 5 : Sets index w^4, w^9, w^14 etc.
    # MCode: ;   In above example nroot = w^5
    # MCode: ;   In above example root =  w
    # MCode: ;   Precalculate primitive root for a prime and set them here
    #
    # MCode: set ^%imptp(fillid,"prime")=50000017	;Precalculated
    # yottadb.set("^%imptp", (fillid, "prime"), "50000017")
    yottadb.set("^%imptp", (fillid, "prime"), "50000017")
    # MCode: set ^%imptp(fillid,"root")=5          ;Precalculated
    yottadb.set("^%imptp", (fillid, "root"), "5")
    # MCode: set ^endloop(fillid)=0	;To stop infinite loop
    yottadb.set("^endloop", (fillid,), "0")
    # MCode: if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child
    if 0 == yottadb.data("^cntloop", (fillid,)):
        yottadb.set("^cntloop", (fillid,), "0")
    # MCode: if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child
    if 0 == yottadb.data("^cntseq", (fillid,)):
        yottadb.set("^cntseq", (fillid,), "0")
    # MCode: set ^%imptp(fillid,"jsyncnt")=0	; To count number of processes that are ready to be killed by crash scripts
    yottadb.set("^%imptp", (fillid, "jsyncnt"), "0")

    # MCode: ; If test is running with gtm_test_spanreg'=0, we want to make sure the xarr global variables continue to
    # MCode: ; cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
    # MCode: ; See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
    # MCode: ; unconditionally (gtm_test_spanreg is 0 or not) excluding all these globals from random mapping to multiple regions.
    #
    # MCode: set gblprefix="abcdefgh"
    # MCode: for i=1:1:$length(gblprefix) set ^%sprgdeExcludeGbllist($extract(gblprefix,i)_"ndxarr")=""
    for c in "abcdefgh":
        yottadb.set("^%sprgdeExcludeGbllist", (c + "ndxarr",), "")

    # MCode: Before forking off children, make sure all buffered IO is flushed out (or else the children would inherit
    # MCode: the unflushed buffers and will show up duplicated in the children's stdout/stderr.
    # CCode: fflush(NULL);
    sys.stdout.flush()
    #
    # MCode: Since "jmaxwait" local variable (in com/imptp.m) is undefined at this point, the caller
    # MCode: will invoke "endtp.csh" later to wait for the children to die. Therefore set ^%jobwait global
    # MCode: to point to those pids.
    #
    # MCode: set ^%jobwait(jobid,"njobs")=njobs   ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "njobs"), jobcnt)
    # MCode: set ^%jobwait(jobid,"jmaxwait")=7200 ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jmaxwait"), "7200")
    # MCode: set ^%jobwait(jobid,"jdefwait")=7200 ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jdefwait"), "7200")
    # MCode: set ^%jobwait(jobid,"jprint")=0      ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jprint"), "0")
    # MCode: set ^%jobwait(jobid,"jroutine")="impjob_imptp" ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jroutine"), "impjob_imptp")
    # MCode: set ^%jobwait(jobid,"jmjoname")="impjob_imptp" ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jmjoname"), "impjob_imptp")
    # MCode: set ^%jobwait(jobid,"jnoerrchk")="0" ; Taken from com/job.m
    yottadb.set("^%jobwait", (jobid, "jnoerrchk"), "0")

    # Note - this Python version won't be calling ydb_child_init() on its own - let that part of the testing rest with the
    #        C version of this routine.
    #
    # MCode: do ^job("impjob^imptp",jobcnt,"""""")	; Taken from com/imptp.m
    exefile = os.getcwd() + "/impjob.py"
    for child in range(1, int(jobcnt) + 1):
        process = subprocess.Popen([exefile, str(child)])
        # MCode: for i=1:1:njobs  set ^(i)=jobindex(i)	: com/job.m
        yottadb.set("^%jobwait", (jobid, str(child)), str(process.pid))
        # MCode set jobindex(index)=$zjob			: com/job.m
        yottadb.set("jobindex", (str(child),), str(process.pid))

    # MCode: do writecrashfileifneeded			: com/job.m
    yottadb.ci("writecrashfileifneeded")
    # MCode: do writejobinfofileifneeded			: com/job.m
    yottadb.ci("writejobinfofileifneeded")
    # MCode: ; Wait until the first update on all regions happen
    # MCode: set start=$horolog
    # MCode: for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
    # MCode: write:$$^difftime(stop,start)>300
    #    "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
    seconds = 0
    while 300 > seconds:
        cntloop = int(yottadb.get("^cntloop", (fillid,)).decode("utf-8"))
        if 0 != cntloop:
            break
        seconds += 1
        time.sleep(1)
    if 300 == seconds:
        print("TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!")

    # MCode: ; Wait for all M child processes to start and reach a point when it is safe to simulate crash
    # MCode: set timeout=600	; 10 minutes to start and reach the sync point for kill
    # MCode: for i=1:1:600 hang 1 quit:^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"totaljob")
    # MCode: if ^%imptp(fillid,"jsyncnt")<^%imptp(fillid,"totaljob") do
    # MCode: . write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
    # MCode: . zwrite ^%imptp
    seconds = 0
    while 600 > seconds:
        jsyncnt = int(yottadb.get("^%imptp", (fillid, "jsyncnt")).decode("utf-8"))
        totaljob = int(yottadb.get("^%imptp", (fillid, "totaljob")).decode("utf-8"))
        if jsyncnt == totaljob:
            break
        time.sleep(1)
        seconds += 1
    if jsyncnt < totaljob:
        print("TEST-E-imptp.m time out for jobs to start and synch after 600 seconds")
    # MCode: do writeinfofileifneeded ;(not sure what this comment means - it isn't what is being done)
    try:
        if "TRUE" == os.environ["gtm_test_onlinerollback"]:
            raise Exception("TEST-F-NOONLINEROLLBACK Online rollback cannot be supported with the Simple[Thread]API")
    except KeyError:
        # $gtm_test_onlinerollback is not set, which means there is no rollback.
        # So just ignore the exception and continue execution.
        pass
    # MCode: write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    print(f"End   Time of parent: {str(datetime.datetime.now()).split('.')[0]}")

    sys.exit(0)
    # MCode: quit
