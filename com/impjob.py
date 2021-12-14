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
import datetime
import random
import sys
import time

from typing import List

import yottadb


LOCK_TIMEOUT = 900000000000  # 900 * 10^9 nanoseconds == 900 seconds == 15 minutes
MAX_PROCESSES = 32


def tpfn_stage1(parm_array: List[int]) -> int:
    # Extract parameters
    crash = parm_array[0]
    trigger = parm_array[1]
    istp = parm_array[2]
    fillid = parm_array[3]
    loop = parm_array[4]
    jobno = parm_array[5]
    i = parm_array[6]
    ztr = parm_array[7]

    assert val == yottadb.get("val")
    assert subs == yottadb.get("subs")
    assert subsMAX == yottadb.get("subsMAX")
    assert fillid == yottadb.get("fillid")
    # MCode: . set ^arandom(fillid,subsMAX)=val
    yottadb.set("^arandom", (fillid, subsMAX), val)

    # MCode: . if ((istp=1)&(crash)) do
    if crash and (1 == istp):
        # MCode: . . set rndm=$r(10)
        rand = random.randint(0, 9)

        # MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
        trestart = int(yottadb.get("$trestart").decode("utf-8"))
        if 2 < trestart:
            if 1 == rand:
                yottadb.cip("noop")
            # MCode: . . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
            if 2 == rand:
                rand = random.randint(0, 9)
                time.sleep(rand)

        # MCode: . . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow
        if trestart:
            yottadb.set("^zdummy", (str(trestart),), str(jobno))

    # MCode: . set ^brandomv(fillid,subsMAX)=valALT
    yottadb.set("^brandomv", (fillid, subsMAX), valALT)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^crandomva(fillid,subsMAX)=valALT
        yottadb.set("^crandomva", (fillid, subsMAX), valALT)

    # MCode: . set ^drandomvariable(fillid,subs)=valALT
    yottadb.set("^drandomvariable", (fillid, subs), valALT)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^erandomvariableimptp(fillid,subs)=valALT
        yottadb.set("^erandomvariableimptp", (fillid, subs), valALT)
        # MCode: . . set ^frandomvariableinimptp(fillid,subs)=valALT
        yottadb.set("^frandomvariableinimptp", (fillid, subs), valALT)

    # MCode: . set ^grandomvariableinimptpfill(fillid,subs)=val
    yottadb.set("^grandomvariableinimptpfill", (fillid, subs), val)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^hrandomvariableinimptpfilling(fillid,subs)=val
        yottadb.set("^hrandomvariableinimptpfilling", (fillid, subs), val)
        # MCode: . . set ^irandomvariableinimptpfillprgrm(fillid,subs)=val
        yottadb.set("^irandomvariableinimptpfillprgrm", (fillid, subs), val)
    else:
        # MCode. if trigger xecute ztwormstr	; fill in $ztwormhole for below update that requires "subs"
        yottadb.cip("ztwormstr")

    # MCode: . set ^jrandomvariableinimptpfillprogram(fillid,I)=val
    i = str(i)
    yottadb.set("^jrandomvariableinimptpfillprogr", (fillid, i), val)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val
        yottadb.set("^jrandomvariableinimptpfillprogr", (fillid, i, i), val)
        # MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val */
        yottadb.set("^jrandomvariableinimptpfillprogr", (fillid, i, i, subs), val)

    # MCode: . if istp'=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
    if istp:
        if ztr:
            yottadb.cip("ztrcmd")
        yottadb.set("^lasti", (fillid, str(jobno)), str(loop))

    return yottadb.YDB_OK


def tpfn_stage3(parm_array: List[int]) -> int:
    # Extract parameters
    trigger = parm_array[1]
    istp = parm_array[2]
    fillid = parm_array[3]
    dztrig = parm_array[8]

    # MCode: . do:dztrig ^imptpdztrig(2,istp<2)
    if dztrig:
        yottadb.cip("imptpdztrig")

    # MCode: . set ^entp(fillid,subs)=val
    # MCode: subscr[0] already has <fillid> value in it
    yottadb.set("^entp", (fillid, subs), val)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^fntp(fillid,subs)=val
        yottadb.set("^fntp", (fillid, subs), val)
    else:
        # MCode: . if trigger do
        # MCode: . . set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix"))
        fntp = yottadb.get("^fntp", (fillid, subs))
        fntp_len = len(fntp)
        if 6 <= fntp_len:
            fntp = fntp[: fntp_len - 6]  # 6 is $length("suffix")
        else:
            assert istp
            return yottadb.YDB_TP_RESTART
        yottadb.set("^fntp", (fillid, subs), fntp)

    # MCode: . set ^gntp(fillid,subsMAX)=valMAX
    yottadb.set("^gntp", (fillid, subsMAX), valMAX)

    # MCode: . if 'trigger do
    if not trigger:
        # MCode: . . set ^hntp(fillid,subsMAX)=valMAX
        yottadb.set("^hntp", (fillid, subsMAX), valMAX)
        # MCode: . . set ^intp(fillid,subsMAX)=valMAX
        yottadb.set("^intp", (fillid, subsMAX), valMAX)
        # MCode: . . set ^bntp(fillid,subsMAX)=valMAX
        yottadb.set("^bntp", (fillid, subsMAX), valMAX)

    return yottadb.YDB_OK


if __name__ == "__main__":
    childnum = int(sys.argv[1])
    top = 0
    pid = os.getpid()
    try:
        jobid = os.environ["gtm_test_jobid"]
    except KeyError:
        jobid = "0"

    # Redirect stdin and stdout to files
    # --> NEED ydb_stdout_stderr_adjust()???
    outfile = open(f"impjob_imptp{jobid}.mjo{childnum}", "w")
    errfile = open(f"impjob_imptp{jobid}.mje{childnum}", "w")
    newout = os.dup2(outfile.fileno(), sys.stdout.fileno())
    newerr = os.dup2(errfile.fileno(), sys.stderr.fileno())
    yottadb.adjust_stdout_stderr()

    # MCode: set jobindex=index
    yottadb.set("jobindex", value=str(childnum))

    # 5% chance we use M call-in else we use YDBPython
    rand = random.randint(1, 20)
    try:
        is_gtm8086_subtest = ("gtm8086" == os.environ["test_subtest_name"])
    except KeyError:
        is_gtm8086_subtest = False
    # If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
    # errors can happen in the imptp child process and that is expected. This is easily handled if we
    # invoke the entire child process using impjob^imptp. If we use simpleAPI for this, all the ydb_*_s()
    # calls need to be checked for return status to allow for JNLEXTEND/JNLSWITCHFAIL and it gets clumsy.
    # Since simpleAPI gets good test coverage through imptp in many dozen tests, we choose to use call-ins
    # only for this specific test.
    if is_gtm8086_subtest:
        rand = 0
    if 0 == rand:
        # Randomly chose ydb_ci method (~20% chance) to run child (impjob^imptp)
        # MCode: do impjob^imptp
        try:
            yottadb.ci("impjob")
        except yottadb.YDBError as e:
            if is_gtm8086_subtest and (yottadb.YDB_ERR_JNLEXTEND == e.code() or yottadb.YDB_ERR_JNLSWITCHFAIL == e.code()):
                pass
            else:
                raise e

        print("IMPTP JOB")
        sys.exit(0)

    # MCode: write "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    print(f"Start time : {str(datetime.datetime.now()).split('.')[0]}")
    # MCode: write "$zro=",$zro,!
    print(f"$zro={yottadb.get('$ZROUTINES')}")

    # MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE" merge %imptp=^%imptp
    # No need to translate the above M line as parent would have YDB_ASSERT failed in that case.

    # MCode: set jobno=jobindex	; Set by job.m ; not using $job makes imptp resumable after a crash!
    jobno = str(childnum)
    yottadb.set("jobno", value=jobno)

    # MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
    # Already done earlier in this function

    # MCode: set fillid=^%imptp("fillid",jobid)
    fillid = yottadb.get("^%imptp", ("fillid", str(jobid)))
    yottadb.set("fillid", value=fillid)
    # MCode: set jobcnt=^%imptp(fillid,"totaljob")
    jobcnt = int(yottadb.get("^%imptp", (fillid, "totaljob")).decode("utf-8"))
    yottadb.set("jobcnt", value=str(jobcnt))
    # MCode: set prime=^%imptp(fillid,"prime")
    prime = int(yottadb.get("^%imptp", (fillid, "prime")).decode("utf-8"))
    yottadb.set("prime", value=str(prime))
    # MCode: set root=^%imptp(fillid,"root")
    root = int(yottadb.get("^%imptp", (fillid, "root")).decode("utf-8"))
    yottadb.set("root", value=str(root))

    # MCode: set top=+$GET(^%imptp(fillid,"top"))
    top = yottadb.get("^%imptp", (fillid, "top"))
    yottadb.set("top", value=top)
    if top is None:
        top = 0
    else:
        top = int(top.decode("utf-8"))
    if 0 == top:
        top = prime // jobcnt

    # MCode: set istp=^%imptp(fillid,"istp")
    istp = yottadb.get("^%imptp", (fillid, "istp"))
    yottadb.set("istp", value=istp)
    istp = int(istp.decode("utf-8"))
    # MCode: set tptype=^%imptp(fillid,"tptype")
    tptype = yottadb.get("^%imptp", (fillid, "tptype"))
    yottadb.set("tptype", value=tptype)
    # MCode: set tpnoiso=^%imptp(fillid,"tpnoiso")
    tpnoiso = yottadb.get("^%imptp", (fillid, "tpnoiso"))
    yottadb.set("tpnoiso", value=tpnoiso)
    # MCode: set dupset=^%imptp(fillid,"dupset")
    dupset = yottadb.get("^%imptp", (fillid, "dupset"))
    yottadb.set("dupset", value=dupset)
    # MCode: set skipreg=^%imptp(fillid,"skipreg")
    skipreg = yottadb.get("^%imptp", (fillid, "skipreg"))
    yottadb.set("skipreg", value=skipreg)
    # MCode: set crash=^%imptp(fillid,"crash")
    crash = yottadb.get("^%imptp", (fillid, "crash"))
    yottadb.set("crash", value=crash)
    crash = int(crash.decode("utf-8"))
    # MCode: set gtcm=^%imptp(fillid,"gtcm")
    gtcm = yottadb.get("^%imptp", (fillid, "gtcm"))
    yottadb.set("gtcm", value=gtcm)
    gtcm = int(gtcm.decode("utf-8"))

    #  ; ONLINE ROLLBACK - BEGIN
    #  ; Randomly 50% when in TP, switch the online rollback TP mechanism to restart outside of TP
    #  ;	orlbkintp = 0 disable online rollback support - this is the default
    #  ;	orlbkintp = 1 use the TP rollback mechanism outside of TP, should be true for only TP
    #  ;	orlbkintp = 2 use the TP rollback mechanism inside of TP, should be true for only TP
    #  MCode: set orlbkintp=0
    #  MCode: new ORLBKRESUME
    #  MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE"  do
    #  MCode: . init^orlbkresume("imptp",$zlevel,"ERROR^imptp") if istp=1 set orlbkintp=($random(2)+1)
    #  ; ONLINE ROLLBACK -  END
    #
    #  The above online rollback section does not need to be migrated since we never run simpleAPI against online rollback
    #  Set "orlbkintp" M variable
    yottadb.set("orlbkintp", value="0")

    # ; Node Spanning Blocks - BEGIN

    # MCode: set keysize=^%imptp(fillid,"key_size")
    keysize = yottadb.get("^%imptp", (fillid, "key_size"))
    yottadb.set("keysize", value=keysize)
    # MCode: set recsize=^%imptp(fillid,"record_size")
    recsize = yottadb.get("^%imptp", (fillid, "record_size"))
    print(f"recsize: {recsize}")
    yottadb.set("recsize", value=recsize)
    # MCode: set span=+^%imptp(fillid,"gtm_test_spannode")
    span = yottadb.get("^%imptp", (fillid, "gtm_test_spannode"))
    print(f"span: {span}")
    yottadb.set("span", value=span)

    # ; Node Spanning Blocks - END

    # ; TRIGGERS - BEGIN

    # ; The triggers section MUST be the last update to ^%imptp during setup. Online Rollback tests use this as a marker to detect
    # ; when ^%imptp has been rolled back.
    #
    # MCode: set trigger=^%imptp(fillid,"trigger"),ztrcmd="ztrigger ^lasti(fillid,jobno,loop)",ztr=0,dztrig=0
    trigger = int(yottadb.get("^%imptp", (fillid, "trigger")).decode("utf-8"))
    yottadb.set("trigger", value=str(trigger))
    yottadb.set("ztrcmd", value="ztrigger ^lasti(fillid,jobno,loop)")
    ztr = 0
    dztrig = 0

    # MCode: if trigger do
    if trigger:
        # MCode: . set trigname="triggernameforinsertsanddels"
        yottadb.set("trigname", value="triggernameforinsertsanddels")
        # MCode: . set fulltrig="^unusedbyothersdummytrigger -commands=S -xecute=""do ^nothing"" -name="_trigname
        yottadb.set(
            "fulltrig", value='^unusedbyothersdummytrigger -commands=S -xecute="do ^nothing" -name=triggernameforinsertsanddels'
        )
        # MCode: . set ztr=(trigger#10)>1  ; ZTRigger command testing
        ztr = (trigger % 10) > 1
        # MCode: . set dztrig=(trigger>10) ; $ZTRIGger() function testing
        dztrig = trigger > 10
    yottadb.set("ztr", value=str(ztr))
    yottadb.set("dztrig", value=str(dztrig))

    # ; TRIGGERS -  END
    # set zwrcmd="zwr jobno,istp,tptype,tpnoiso,orlbkintp,dupset,skipreg,crash,gtcm,fillid,keysize,recsize,trigger" */
    # write zwrcmd,! */
    # xecute zwrcmd */
    print(f"jobno={jobno}")
    print(f"istp={istp}")
    print(f"tptype={tptype}")
    print(f"tpnoiso={tpnoiso}")
    print(f"orlbkintp=0")
    print(f"dupset={dupset}")
    print(f"skipreg={skipreg}")
    print(f"crash={crash}")
    print(f"gtcm={gtcm}")
    print(f"fillid={fillid}")
    print(f"keysize={keysize}")
    print(f"recsize={recsize}")
    print(f"trigger={trigger}")

    # MCode: write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
    print(f"PID: {pid}\nIn hex: {hex(pid)}")
    sys.stdout.flush()  # Flush stdout as soon as efficiently possible

    # MCode: lock +^%imptp(fillid,"jsyncnt")  ...
    # MCode: ...set ^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"jsyncnt")+1  lock -^%imptp(fillid,"jsyncnt")
    # MCode:
    # The "lock_incr()" and "lock_decr()" usages below are unnecessary since "incr()" is atomic.
    # But we want to test the YDBPython lock functions and so have them here just like the M version of imptp.
    yottadb.lock_incr("^%imptp", (fillid, "jsyncnt"), LOCK_TIMEOUT)
    yottadb.incr("^%imptp", (fillid, "jsyncnt"), 1)
    yottadb.lock_decr("^%imptp", (fillid, "jsyncnt"))

    # ; lfence is used for the fence type of last segment of updates of *ndxarr at the end
    # ; For non-tp and crash test meaningful application checking is very difficult
    # ; So at the end of the iteration TP transaction is used
    # ; For gtcm we cannot use TP at all, because it is not supported.
    # ; We cannot do crash test for gtcm.
    #
    # MCode: set lfence=istp
    # MCode: if (istp=0)&(crash=1) set lfence=1	; TP fence
    # MCode: if gtcm=1 set lfence=0			; No fence
    lfence = istp
    if not istp and crash:
        lfence = 1
    if gtcm:
        lfence = 0
    # Set "lfence" M variable
    yottadb.set("lfence", value=str(lfence))

    # MCode: if tpnoiso do tpnoiso^imptp
    if tpnoiso:
        yottadb.cip("tpnoiso")  # Use call-in for this as it contains VIEW commands which are not yet supported in by the Simple API

    # MCode: if dupset view "GVDUPSETNOOP":1
    if dupset:
        # Use call-in for this as it contains VIEW commands which are not yet supported in by the Simple API
        yottadb.cip("dupsetnoop")

    # MCode: set nroot=1
    # MCode: for J=1:1:jobcnt set nroot=(nroot*root)#prime
    nroot = 1
    for i in range(1, jobcnt + 1):
        nroot = (nroot * root) % prime

    # ; imptp can be restarted at the saved value of lasti
    # MCode: set lasti=+$get(^lasti(fillid,jobno))
    lasti = yottadb.get("^lasti", (fillid, jobno))
    if lasti is None:
        lasti = 0
    else:
        lasti = int(lasti.decode("utf-8"))
    yottadb.set("lasti", value=str(lasti))
    # MCode: zwrite lasti
    print(f"lasti={lasti}")

    # ; Initially we have followings:
    # ; 	Job 1: I=w^0
    # ; 	Job 2: I=w^1
    # ; 	Job 3: I=w^2
    # ; 	Job 4: I=w^3
    # ; 	Job 5: I=w^4
    # ;	nroot = w^5 (all job has same value)
    # MCode: set I=1
    # MCode: for J=2:1:jobno  set I=(I*root)#prime
    # MCode: for J=1:1:lasti  set I=(I*nroot)#prime
    i = 1  # Use lowercase 'i' to avoid "ambiguous variable name" error (occurs with "I" and "O")
    for j in range(2, childnum + 1):  # childnum == int(jobno)
        i = (i * root) % prime
    for j in range(1, lasti + 1):
        i = (i * nroot) % prime

    # MCode: write "Starting index:",lasti+1,!
    print(f"Starting index:{lasti + 1}")
    sys.stdout.flush()

    # MCode: for loop=lasti+1:1:top do  quit:$get(^endloop(fillid),0)
    for loop in range(lasti + 1, top + 1):
        # Set I and loop M variables (needed by "helper1" call-in code)
        yottadb.set("I", value=str(i))
        yottadb.set("loop", value=str(loop))

        # ; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
        # MCode: do pauseifneeded^pauseimptp
        # MCode: set subs=$$^ugenstr(I)		; I to subs  has one-to-one mapping
        # MCode: set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
        # MCode: set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
        # MCode: set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
        # MCode: set valMAX=$j(val,recpad)
        # MCode: set valALT=$select(span>1:valMAX,1:val)
        # MCode: ; padded key size minus UTF-8 bytes. ZTP uses no padding
        # MCode: set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))
        # MCode: set subsMAX=$j(subs,keypad)
        # MCode: if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
        yottadb.cip("helper1")  # Use call-in to implement the block of M code commented above

        # Copy variable names to parameter tuple
        parms = (crash, trigger, istp, fillid, loop, jobno, i, ztr, dztrig)

        # Initialize variables subsMAX, val, valALT, valMAX, subs for use by later function calls ("tpfn_stage1", etc.).
        # Each global variable must be declared as such within this function in order for any values assigned
        # here to be used outside the scope of this function.
        global subs
        global subsMAX
        global val
        global valALT
        global valMAX
        subs = yottadb.get("subs")
        subsMAX = yottadb.get("subsMAX")
        val = yottadb.get("val")
        valALT = yottadb.get("valALT")
        valMAX = yottadb.get("valMAX")
        i = yottadb.get("I")

        # MCode: . ; Stage 1
        # MCode: . if istp=1 tstart *:(serial:transaction=tptype)
        # MCode: Run a block of code as a TP or non-TP transaction based on "istp" variable
        try:
            if 1 == istp:
                yottadb.tp(tpfn_stage1, (parms,), tptype.decode("utf-8"), ("*",))
            else:
                tpfn_stage1(parms)
            # MCode: if istp=1 tcommit

            # . ; Stage 2

            # . set rndm=$random(10)
            # . if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
            # . . set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig)
            # . . set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms
            # . . xecute ztrigstr
            # . . if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error
            # . . goto:'ztrigret ERROR
            yottadb.cip("helper2")

            assert val == yottadb.get("val")
            assert subs == yottadb.get("subs")
            assert fillid == yottadb.get("fillid")
            # MCode: . set ^antp(fillid,subs)=val
            yottadb.set("^antp", (fillid, subs), val)

            # MCode: . if 'trigger do
            if not trigger:
                # . . set ^bntp(fillid,subs)=val
                yottadb.set("^bntp", (fillid, subs), val)
                # . . set ^cntp(fillid,subs)=val
                yottadb.set("^cntp", (fillid, subs), val)

            # MCode: . . set ^dntp(fillid,subs)=valALT
            yottadb.set("^dntp", (fillid, subs), valALT)

            # MCode: . ; Stage 3
            # MCode: . if istp=1 tstart ():(serial:transaction=tptype)
            # Run a block of code as a TP or non-TP transaction based on "istp" variable
            if 1 == istp:
                yottadb.tp(tpfn_stage3, (parms,), tptype.decode("utf-8"), ("*",))
            else:
                tpfn_stage3(parms)
            # if istp=1 tcommit

            # . ; Stage 4 thru 11
            yottadb.cip("helper3")
            # MCode: . ; Stage 4
            # MCode: . for J=1:1:jobcnt D
            # MCode: . . set valj=valALT_J
            # MCode: . . ;
            # MCode: . . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
            # MCode: . . set ^arandom(fillid,subs,J)=valj
            # MCode: . . if 'trigger do
            # MCode: . . . set ^brandomv(fillid,subs,J)=valj
            # MCode: . . . set ^crandomva(fillid,subs,J)=valj
            # MCode: . . . set ^drandomvariable(fillid,subs,J)=valj
            # MCode: . . . set ^erandomvariableimptp(fillid,subs,J)=valj
            # MCode: . . . set ^frandomvariableinimptp(fillid,subs,J)=valj
            # MCode: . . . set ^grandomvariableinimptpfill(fillid,subs,J)=valj
            # MCode: . . . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
            # MCode: . . . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
            # MCode: . . do:dztrig ^imptpdztrig(1,istp<2)
            # MCode: . . if istp=1 tcommit
            # MCode: . . ;
            # MCode: . ; Stage 5
            # MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
            # MCode: . do:dztrig ^imptpdztrig(2,istp<2)
            # MCode: . if ((istp=1)&(crash)) do
            # MCode: . . set rndm=$random(10)
            # MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
            # MCode: . . if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time
            # MCode: . kill ^arandom(fillid,subs,1)
            # MCode: . if 'trigger do
            # MCode: . . kill ^brandomv(fillid,subs,1)
            # MCode: . . kill ^crandomva(fillid,subs,1)
            # MCode: . . kill ^drandomvariable(fillid,subs,1)
            # MCode: . . kill ^erandomvariableimptp(fillid,subs,1)
            # MCode: . . kill ^frandomvariableinimptp(fillid,subs,1)
            # MCode: . . kill ^grandomvariableinimptpfill(fillid,subs,1)
            # MCode: . . kill ^hrandomvariableinimptpfilling(fillid,subs,1)
            # MCode: . . kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
            # MCode: . do:dztrig ^imptpdztrig(1,istp<2)
            # MCode: . do:dztrig ^imptpdztrig(2,istp<2)
            # MCode: . if istp=1 tcommit
            # MCode: . ; Stage 6
            # MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
            # MCode: . zkill ^jrandomvariableinimptpfillprogram(fillid,I)
            # MCode: . if 'trigger do
            # MCode: . . zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
            # MCode: . if istp=1 tcommit
            # MCode: . ; Stage 7 : delimited spanning nodes to be changed in Stage 10
            # MCode: . ; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan
            # MCode: . ; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef
            # MCode: . ;				 		2. ^aspan=^espan and ^bspan is undef
            # MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
            # MCode: . ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
            # MCode: . set piecesize=7
            # MCode: . set valPIECE=valMAX
            # MCode: . set totalpieces=($length(valPIECE)/piecesize)+1
            # MCode: . ; $extract beyond $length returns a null character
            # MCode: . for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|"
            # MCode: . set totalpieces=$length(valPIECE,"|")
            # MCode: . set ^aspan(fillid,I)=valPIECE
            # MCode: . if 'trigger do
            # MCode: . . set ^espan(fillid,I)=$get(^aspan(fillid,I))
            # MCode: . . set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","")
            # MCode: . if istp=1 tcommit
            # MCode: . ; Stage 8
            # MCode: . kill ^arandom(fillid,subs,1)	; This results nothing
            # MCode: . kill ^antp(fillid,subs)
            # MCode: . if 'trigger do
            # MCode: . . kill ^bntp(fillid,subs)
            # MCode: . . zkill ^brandomv(fillid,subs,1)	; This results nothing
            # MCode: . . zkill ^cntp(fillid,subs)
            # MCode: . . zkill ^dntp(fillid,subs)
            # MCode: . kill ^bntp(fillid,subsMAX)
            # MCode: . if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
            # MCode: . ; Stage 9
            # MCode: . ; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
            # MCode: . set flag=$random(2)
            # MCode: . if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
            # MCode: . set cntloop=$incr(^cntloop(fillid))
            # MCode: . set cntseq=$incr(^cntseq(fillid),(13+jobcnt))
            # MCode: . if flag=1,lfence=1 tcommit
            # MCode: . ; Stage 10 : More SET $piece
            # MCode: . ; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and
            # MCode: . ; $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece)
            # MCode: . ; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece
            # MCode: . ; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan
            # MCode: . ;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
            # MCode: . ;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and
            # MCode: . ;                           $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
            # MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
            # MCode: . set targetpiece=(loop#(totalpieces))
            # MCode: . set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X")
            # MCode: . zkill ^espan(fillid,I)
            # MCode: . set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece
            # MCode: . if 'trigger do
            # MCode: . . set $piece(^espan(fillid,I),"|",targetpiece)=subpiece
            # MCode: . . set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece
            # MCode: . if istp=1 tcommit
            # MCode: . ; Stage 11
            # MCode: . if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
            # MCode: . do:dztrig ^imptpdztrig(1,istp<2)
            # MCode: . xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole="""""
            # MCode: . set ^andxarr(fillid,jobno,loop)=I
            # MCode: . if 'trigger do
            # MCode: . . set ^bndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^cndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^dndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^endxarr(fillid,jobno,loop)=I
            # MCode: . . set ^fndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^gndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^hndxarr(fillid,jobno,loop)=I
            # MCode: . . set ^indxarr(fillid,jobno,loop)=I
            # MCode: . if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
            # MCode: . if lfence=1 tcommit

            # MCode . set I=(I*nroot)#prime
            i = (int(i.decode("utf-8")) * nroot) % prime
            yottadb.set("I", value=str(i))

            # MCode: quit:$get(^endloop(fillid),0)
            end = yottadb.get("^endloop", (fillid,))
            if end is None:
                continue
            if int(end):
                break
        # ; End For Loop
        except yottadb.YDBError as e:
            if is_gtm8086_subtest and (yottadb.YDB_ERR_JNLEXTEND == e.code() or yottadb.YDB_ERR_JNLSWITCHFAIL == e.code()):
                pass
            else:
                raise e

    # MCode: write "End index:",loop,!
    print(f"End index: {loop}")
    # MCode: write "Job completion successful",!
    print("Job completion successful")
    # MCode: write "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    print(f"End Time : {str(datetime.datetime.now()).split('.')[0]}")

    sys.stdout.flush()  # Flush stdout as soon as efficiently possible
    sys.exit(0)
