//! Rust implementation of imptp using multiple threads as workers.
//! Adapted from `imptpgo.go` and `impjobgo.go`.

/****************************************************************
*                                                               *
* Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.  *
* All rights reserved.                                          *
*                                                               *
*       This source code contains the intellectual property     *
*       of its copyright holder(s), and is made available       *
*       under a license.  If you do not know the terms of       *
*       the license, please stop and do not read further.       *
*                                                               *
****************************************************************/

use std::env;
use std::ffi::CStr;
use std::fmt::Display;
use std::fs::File;
use std::io::{self, Write};
use std::process::{self, Command};
use std::thread;
use std::time::Duration;

use rand::Rng;

use yottadb::context_api::{Context, KeyContext as Key};
use yottadb::*;

/// Main routine for imptp. This uses the `context_api`.
fn main() -> YDBResult<()> {
    let (ctx, fillid, jobid, jobcnt) = setup()?;
    fill_database(&ctx, &fillid, &jobid, &jobcnt)?;

    Ok(())
}

// helper functions
fn env_var_is(var: &str, expected: &str) -> bool {
    env::var(var).ok().map_or(false, |val| val == expected)
}
fn parse_env_var(var: &str) -> i32 {
    env::var(var)
        .ok()
        .and_then(|val| val.parse().ok())
        .unwrap_or(0)
}
fn now() -> impl Display {
    chrono::Local::now().format("%d-%b-%Y %T%.3f")
}

// end helper functions

/// This sets global variables based on the environment of the prcoess.
///
/// Returns `(ctx, fillid, jobid, jobcnt)`
fn setup() -> YDBResult<(Context, String, String, String)> {
    let ctx = Context::new();
    let mut rng = rand::thread_rng();

    // setup from `v4imptp.csh`
    // MCode: set jobcnt=$$jobcnt
    let jobcnt = if let Ok(var) = env::var("gtm_test_jobcnt") {
        var.parse().unwrap_or(0)
    } else {
        0
    }
    .to_string();
    println!("jobcnt = {}", jobcnt);
    Key::variable(&ctx, "jobcnt").set(&jobcnt)?;

    // Adapted from `imptp.m`, `imptpgo.go`

    // MCode: write "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    println!("Start time of parent: {}", now());
    // MCode: write "$zro=",$zro,!
    let routines = Key::variable(&ctx, "$zroutines").get()?;
    println!("$zro={}", String::from_utf8_lossy(&routines));

    // MCode: write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
    let pid = process::id();
    println!("PID: {}\nIn hex: {:x}", pid, pid);

    // Start processing test system parameters
    //
    // istp = 0 non-tp
    // istp = 1 TP
    // istp = 2 ZTP
    //
    // MCode: set fillid=+$ztrnlnm("gtm_test_dbfillid")
    let fillid = env::var("gtm_test_dbfillid")
        .map(|id| id.parse().unwrap_or(0))
        .unwrap_or(0)
        .to_string();
    Key::variable(&ctx, "fillid").set(&fillid)?;

    // MCode: if $ztrnlnm("gtm_test_tp")="NON_TP"  do
    // MCode: . set istp=0
    // MCode: . write "It is Non-TP",!
    // MCode: else  do
    // MCode: . if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
    // MCode: . else  set istp=1  write "It is TP",!
    // MCode: set ^%imptp(fillid,"istp")=istp
    let is_tp = if env_var_is("gtm_test_tp", "NON_TP") {
        println!("It is Non-TP");
        0
    } else if env_var_is("gtm_test_dbfill", "IMPZTP") {
        println!("It is ZTP");
        panic!("cannot simulate ZTP with SimpleAPI");
    } else {
        println!("It is TP");
        1
    };
    let mut imptp = Key::new(&ctx, "^%imptp", &[fillid.as_bytes(), b"istp"]);
    imptp.set(is_tp.to_string())?;

    // MCode: if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp(fillid,"tptype")="ONLINE"
    // MCode: else  set ^%imptp(fillid,"tptype")="BATCH"
    let tptype = if env_var_is("gtm_test_tptype", "ONLINE") {
        "ONLINE"
    } else {
        "BATCH"
    };
    imptp[1] = "tptype".into();
    imptp.set(tptype)?;

    // MCode: ; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
    // MCode: if '$data(^%imptp(fillid,"tpnoiso")) do
    // MCode: .  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
    // MCode: .  else  set ^%imptp(fillid,"tpnoiso")=0

    // ^%imptp(fillid,"tpnoiso")
    imptp[1] = "tpnoiso".into();
    // 0 == NoData
    if let DataReturn::NoData = imptp.data()? {
        let isolation = is_tp == 1 && env_var_is("gtm_test_noisolation", "TPNOISO") && rng.gen();
        imptp.set((isolation as u8).to_string())?;
    }

    // MCode: ; Randomly 50% time use optimization for redundant sets, only if not already set.
    // MCode: if '$data(^%imptp(fillid,"dupset")) do
    // MCode: .  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
    // MCode: .  else  set ^%imptp(fillid,"dupset")=
    imptp[1] = "dupset".into();
    if let DataReturn::NoData = imptp.data()? {
        let dupset = rng.gen::<bool>();
        imptp.set((dupset as u8).to_string())?;
    }

    // MCode: set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
    imptp[1] = "crash".into();
    let crash = parse_env_var("gtm_test_crash");
    imptp.set(crash.to_string())?;

    // MCode: set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
    imptp[1] = "gtcm".into();
    let gtcm = parse_env_var("gtm_test_is_gtcm");
    imptp.set(gtcm.to_string())?;

    // MCode: set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
    imptp[1] = "skipreg".into();
    let skipreg = parse_env_var("gtm_test_repl_norepl");
    imptp.set(skipreg.to_string())?;

    // MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
    let jobid = parse_env_var("gtm_test_jobid").to_string();
    Key::variable(&ctx, "jobid").set(&jobid)?;

    // MCode: set ^%imptp("fillid",jobid)=fillid
    let imptp_fillid = Key::new(&ctx, "^%imptp", &["fillid", jobid.as_str()]);
    imptp_fillid.set(&fillid)?;

    // Throughout this program small portions of code are implemented using call-ins (instead of SimpleAPI/SimpleThreadAPI)
    // because either it is not possible to migrate or because it is easier to keep it as is (no benefit of extra
    // test coverage for SimpleAPI/SimpleThreadAPI).
    //
    // MCode: ; Grab the key and record size from DSE
    // MCode: do get^datinfo("^%imptp("_fillid_")")
    let getdatinfo = CStr::from_bytes_with_nul(b"getdatinfo\0").unwrap();
    unsafe {
        ci_t!(YDB_NOTTP, Vec::new(), getdatinfo)?;
    }

    // MCode: set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode")
    imptp[1] = "gtm_test_spannode".into();
    let spannode = parse_env_var("gtm_test_spannode");
    imptp.set(spannode.to_string())?;

    // MCode: ; if triggers are installed, the following will invoke the trigger
    // MCode: ; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
    // MCode: ; ^%imptp(fillid,"trigger") to 1
    // MCode: set ^%imptp(fillid,"trigger")=0
    imptp[1] = "trigger".into();
    imptp.set("0")?;

    // MCode: if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
    // MCode: else  if ^%imptp(fillid,"totaljob")'=jobcnt  write "IMPTP-E-MISMATCH: Job number mismatch",!  zwrite ^%imptp  h
    imptp[1] = "totaljob".into();
    if let DataReturn::NoData = imptp.data()? {
        imptp.set(&jobcnt)?;
    } else {
        let totaljob = imptp.get()?;
        if totaljob != jobcnt.as_bytes() {
            let display = String::from_utf8_lossy(&totaljob);
            println!("IMPTP-E-MISMATCH: Job number mismatch : ^%%imptp(fillid,totaljob) = {} : jobcnt = {}\n", display, jobcnt);
        }
    }

    Ok((ctx, fillid, jobid, jobcnt))
}

/// Do a bit more setup and spawn all the worker subprocesses
fn fill_database(ctx: &Context, fillid: &str, jobid: &str, jobcnt: &str) -> YDBResult<()> {
    // MCode:
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
    let mut imptp = Key::new(ctx, "^%imptp", &[fillid, "prime"]);
    imptp.set("50000017")?;

    // MCode: set ^%imptp(fillid,"root")=5          ;Precalculated
    imptp[1] = "root".into();
    imptp.set("5")?;

    // MCode: set ^endloop(fillid)=0	;To stop infinite loop
    Key::new(ctx, "^endloop", &[fillid]).set("0")?;

    // MCode: if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child
    let cntloop = Key::new(ctx, "^cntloop", &[fillid]);
    if let DataReturn::NoData = cntloop.data()? {
        cntloop.set("0")?;
    }

    // MCode: if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child
    let cntseq = Key::new(ctx, "^cntseq", &[fillid]);
    if let DataReturn::NoData = cntseq.data()? {
        cntseq.set("0")?;
    }

    // MCode: set ^%imptp(fillid,"jsyncnt")=0	; To count number of processes that are ready to be killed by crash scripts
    imptp[1] = "jsyncnt".into();
    imptp.set("0")?;

    // MCode: ; If test is running with gtm_test_spanreg'=0, we want to make sure the xarr global variables continue to
    // MCode: ; cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
    // MCode: ; See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
    // MCode: ; unconditionally (gtm_test_spanreg is 0 or not) excluding all these globals from random mapping to multiple regions.
    //
    // MCode: set gblprefix="abcdefgh"
    // MCode: for i=1:1:$length(gblprefix) set ^%sprgdeExcludeGbllist($extract(gblprefix,i)_"ndxarr")=""
    let gblprefix = "abcdefgh";
    let mut exclude = Key::new(ctx, "^%sprgdeExcludeGbllist", &["0"]);
    for c in gblprefix.chars() {
        exclude[0] = format!("{}ndxarr", c).into();
        exclude.set("")?;
    }

    // MCode: ; Before forking off children, make sure all buffered IO is flushed out (or else the children would inherit
    // MCode: ; the unflushed buffers and will show up duplicated in the children's stdout/stderr.
    // CCode: fflush(NULL);
    io::stdout().flush().unwrap();
    io::stderr().flush().unwrap();

    // MCode: ; Since "jmaxwait" local variable (in com/imptp.m) is undefined at this point, the caller
    // MCode: ; will invoke "endtp.csh" later to wait for the children to die. Therefore set ^%jobwait global
    // MCode: ; to point to those pids.
    //
    // MCode: set ^%jobwait(jobid,"njobs")=njobs   ; Taken from com/job.m
    let mut jobwait = Key::new(ctx, "^%jobwait", &[jobid, "njobs"]);
    jobwait.set(jobcnt)?;

    // MCode: set ^%jobwait(jobid,"jmaxwait")=7200 ; Taken from com/job.m
    jobwait[1] = "jmaxwait".into();
    jobwait.set("7200")?;

    // MCode: set ^%jobwait(jobid,"jdefwait")=7200 ; Taken from com/job.m
    jobwait[1] = "jdefwait".into();
    jobwait.set("7200")?;

    // MCode: set ^%jobwait(jobid,"jprint")=0      ; Taken from com/job.m
    jobwait[1] = "jprint".into();
    jobwait.set("0")?;

    // MCode: set ^%jobwait(jobid,"jroutine")="impjob_imptp" ; Taken from com/job.m
    jobwait[1] = "jroutine".into();
    jobwait.set("impjob_imptp")?;

    // MCode: set ^%jobwait(jobid,"jmjoname")="impjob_imptp" ; Taken from com/job.m
    jobwait[1] = "jmjoname".into();
    jobwait.set("impjob_imptp")?;

    // MCode: set ^%jobwait(jobid,"jnoerrchk")="0" ; Taken from com/job.m
    jobwait[1] = "jnoerrchk".into();
    jobwait.set("0")?;

    // Note - this Rust version won't be calling ydb_child_init() on its own
    //      - let that part of the testing rest with the C version of this routine.
    //
    // MCode: do ^job("impjob^imptp",jobcnt,"""""")	; Taken from com/imptp.m

    // MCode switches now to `com/job.m`
    // MCode: [for i=1:1:njobs]  set ^(i)=jobindex(i)

    // 0 is just a dummy so it doesn't complain about subscripts out of bounds
    let mut jobwait = Key::new(ctx, "^%jobwait", &[jobid, "0"]);
    let mut jobindex = Key::new(ctx, "jobindex", &["0"]);
    // we already called `parse().to_string()`, so we know it's valid
    let jobs = jobcnt.parse().unwrap();
    let mut processes = Vec::with_capacity(jobs);
    for i in 0..jobs {
        // MCode: set ^(i)=jobindex(i)
        // imptp.m used a 1-indexed count
        let m_index = (i + 1).to_string();

        // 	Set stdout & stderr to child specific files
        let out_file = File::create(format!("impjob_imptp{}.mjo{}", jobid, m_index))
            .expect("failed to create stdout file");
        let err_file = File::create(format!("impjob_imptp{}.mje{}", jobid, m_index))
            .expect("failed to create stderr file");

        // TODO: we should probably call `wait` on these `processes` at some point
        // Use absolute paths so that it will be clear these are part of the test suite
        let mut cmd = env::current_dir().expect("TEST-E-FAILED : Could not find current working directory");
        cmd.push("imptpjobrust");
        let child_pid = Command::new(cmd)
            .arg(&m_index)
            .stdout(out_file)
            .stderr(err_file)
            .spawn()
            .expect("failed to spawn do_job process")
            .id();

        // GoCode: pidstr = fmt.Sprintf("%d", proc[child].Process.Pid)
        // GoCode: err = yottadb.SetValE(tptoken, nil, pidstr, "^%jobwait", []string{jobidstr, childstr})
        jobwait[1] = m_index.as_bytes().into();
        jobwait.set(child_pid.to_string())?;

        // MCode: set jobindex(index)=$zjob
        // CCode: status = ydb_set_s(&ylcl_jobindex, 1, &subscr[1], &value);
        jobindex[0] = m_index.into();
        jobindex.set(child_pid.to_string())?;
        processes.push(child_pid);
    }
    // MCode: do writecrashfileifneeded
    // MCode: do writejobinfofileifneeded
    let crash = CStr::from_bytes_with_nul(b"writecrashfileifneeded\0").unwrap();
    let jobinfo = CStr::from_bytes_with_nul(b"writejobinfofileifneeded\0").unwrap();
    unsafe {
        ci_t!(YDB_NOTTP, Vec::new(), crash)?;
        ci_t!(YDB_NOTTP, Vec::new(), jobinfo)?;
    }

    // MCode: ; Wait until the first update on all regions happen
    // MCode: set start=$horolog
    // MCode: for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
    // MCode: write:$$^difftime(stop,start)>300 "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
    let count = Key::new(ctx, "^cntloop", &[fillid]);
    let mut finished = false;
    for _ in 0..300 {
        let status = String::from_utf8_lossy(&count.get()?)
            .parse()
            .expect("status should be valid integer");
        if 0 != status {
            finished = true;
            break;
        }
        thread::sleep(Duration::from_secs(1));
    }
    if !finished {
        println!("TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!");
    }

    // MCode: ; Wait for all M child processes to start and reach a point when it is safe to simulate crash
    // MCode: set timeout=600	; 10 minutes to start and reach the sync point for kill
    // MCode: for i=1:1:600 hang 1 quit:^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"totaljob")
    // MCode: if ^%imptp(fillid,"jsyncnt")<^%imptp(fillid,"totaljob") do
    // MCode: . write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
    // MCode: . zwrite ^%imptp
    let mut jsyncnt = imptp.clone();
    jsyncnt[1] = "jsyncnt".into();
    let mut totaljob = imptp;
    totaljob[1] = "totaljob".into();
    // this initial value is never used, it's just to make the compiler happy
    let (mut j_int, mut total_int) = (0, 0);
    for _ in 0..600 {
        j_int = String::from_utf8_lossy(&jsyncnt.get()?).parse().unwrap();
        total_int = String::from_utf8_lossy(&totaljob.get()?).parse().unwrap();
        if j_int == total_int {
            break;
        }
        thread::sleep(Duration::from_secs(1));
    }
    if j_int < total_int {
        println!("TEST-E-imptp.m time out for jobs to start and synch after 600 seconds");
    }

    // MCode:  do writeinfofileifneeded ;(not sure what this comment means - it isn't what is being done)
    // GoCode: valstr = os.Getenv("gtm_test_onlinerollback")
    // GoCode: if "TRUE" == valstr {
    // GoCode:     panic("TEST-F-NOONLINEROLLBACK Online rollback cannot be supported with the Simple[Thread]API")
    // GoCode: }
    if env_var_is("gtm_test_onlinerollback", "TRUE") {
        panic!("TEST-F-NOONLINEROLLBACK Online rollback cannot be supported with the Simple[Thread]API");
    }

    // MCode: write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    println!("End   Time of parent: {}", now());

    Ok(())
}
