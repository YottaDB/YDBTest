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
use std::error::Error;
use std::ffi::CStr;
use std::fmt::Display;
use std::process;
use std::thread;
use std::time::Duration;

use rand::Rng;

use yottadb::{
    context_api::{Context, KeyContext as Key},
    *,
};

// 15 minutes
const LOCK_TIMEOUT: Duration = Duration::from_secs(15 * 60);

/// imptpjob is a worker process for `fill_database`
fn main() -> YDBResult<()> {
    let ctx = Context::new();
    let jobid = env::var("gtm_test_jobid").unwrap();
    let jobindex = env::args().nth(1).unwrap().parse().unwrap();
    do_job(&ctx, &jobid, jobindex)
}

/* helper functions */
fn get(ctx: &Context, val: &str) -> YDBResult<Vec<u8>> {
    Key::variable(ctx, val).get()
}

fn set(ctx: &Context, var: &str, val: impl ToString) -> YDBResult<()> {
    Key::variable(ctx, var).set(val.to_string())
}

fn env_var_is(var: &str, expected: &str) -> bool {
    env::var(var).ok().map_or(false, |val| val == expected)
}

fn now() -> impl Display {
    chrono::Local::now().format("%d-%b-%Y %T%.3f")
}

// Call an M function with no arguments and no return value.
//
// NOTE: `name` must have a null terminator
fn call(ctx: &Context, name: &[u8]) -> YDBResult<()> {
    let cstr = CStr::from_bytes_with_nul(name).unwrap();
    unsafe {
        ci_t!(ctx.tptoken(), Vec::new(), cstr)?;
    }
    Ok(())
}

// Adapted from `std::dbg`: https://doc.rust-lang.org/src/std/macros.rs.html#285-305
// This prints to stdout, while `dbg` prints to stderr.
macro_rules! zwrite {
    ($val:expr) => {
        // Use of `match` here is intentional because it affects the lifetimes
        // of temporaries - https://stackoverflow.com/a/48732525/1063961
        match $val {
            tmp => {
                println!("[{}:{}] {} = {:#?}",
                    file!(), line!(), stringify!($val), &tmp);
                tmp
            }
        }
    };
    // Trailing comma with single argument is ignored
    ($val:expr,) => { zwrite!($val) };
    // Multiple arguments are treated as if `zwrite!` was called on each individually,
    // then returned as a tuple.
    ($($val:expr),+ $(,)?) => {
        ($(zwrite!($val)),+,)
    };
}

///
/// We want to generate the data in a pseudo-random order,
/// but still ensure that every number from 1 to p-1 (where p is a prime number) is present.
///
/// To do this, we exploit some properties of modular arithmetic.
/// In the algebraic field `Z_p`, the integers modulo `p` for some prime `p`,
/// there is guaranteed to be a 'generator' of the field:
/// some number `r` such that the set S = {1, r mod p , r^2 mod p, r^3 mod p, ..., r^(p-2) mod p} has size p - 1.
/// This generator is also called a 'primitive root' of `p`.
///
/// Since we know S has every number between 1 and p, we can use that as our pseudo-random number generator.
/// Instead of
/// ```
/// for i in 0..p-1 {
///     x[i] = i;
/// }
/// ```
/// We do something like
/// ```
/// for i in 0..p-1 {
///     x[(r^i) % p] = i;
/// }
/// ```
/// This means the nodes x(1), x(3), x(2), x(6), x(4), x(5) get set in that order
/// (instead of x(1), x(2), x(3), x(4), x(5), x(6))
/// which is sort of a pseudo-random order but still lets us verify the final state of the local/global variable tree (this verification happens in checkdb.m).
///
/// # See also
/// - [Primitive roots](https://en.wikipedia.org/wiki/Primitive_root_modulo_n)
/// - [Finding the primitive root of a prime](https://www.geeksforgeeks.org/primitive-root-of-a-prime-number-n-modulo-n/)
/// - [Finite fields](https://en.wikipedia.org/wiki/Field_(mathematics)#Finite_fields). Note that all finite fields are isomorphic to Z_n.
/// - [The cyclic group Z_n under multiplication](https://en.wikipedia.org/wiki/Cyclic_group#Modular_multiplication)
///
/// # Example
///
/// Given p = 7, a generator r is 3:
/// - 3^0(mod 7) = 1
/// - 3^1(mod 7) = 3
/// - 3^2(mod 7) = 2
/// - 3^3(mod 7) = 6
/// - 3^4(mod 7) = 4
/// - 3^5(mod 7) = 5
///
/// Note that there may be multiple generators for a given prime.
fn do_job(ctx: &Context, jobid: &str, jobindex: usize) -> YDBResult<()> {
    // Adapted from `impjobgo.go`
    let pid = process::id();

    // MCode: set jobindex=index
    Key::variable(ctx, "jobindex").set(jobindex.to_string())?;

    let mut rng = rand::thread_rng();
    // If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
    // errors can happen in the imptp child process and that is expected. This is easily handled if we
    // invoke the entire child process using impjob^imptp. If we use SimpleAPI/SimpleThreadAPI for this, all the ydb_*_st()
    // calls need to be checked for return status to allow for JNLEXTEND/JNLSWITCHFAIL and it gets clumsy.
    // Since SimpleAPI/SimpleThreadAPI gets good test coverage through imptp in many dozen tests, we choose to use call-ins
    // only for this specific test.
    let gtm8086 = env_var_is("test_subtest_name", "gtm8086");

    // 5% of the time, use an M call-in instead of running in Rust natively
    let use_ci = rng.gen_range(0, 20) == 0 || gtm8086;
    if use_ci {
        println!("impjob; Elected to do M call-in to impjob^imptp for this process");
        // MCode: do impjob^imptp
        let err = match call(ctx, b"impjob\0") {
            Ok(_) => return Ok(()),
            Err(err) => err,
        };

        // GoCode: if isGtm8086Subtest && ((yottadb.YDB_ERR_JNLEXTEND == errcode) || (yottadb.YDB_ERR_JNLSWITCHFAIL == errcode)) {
        // GoCode:      return
        // GoCode: }
        if gtm8086
            && (err.status == craw::YDB_ERR_JNLEXTEND
                || err.status == craw::YDB_ERR_JNLSWITCHFAIL)
        {
            return Ok(());
        } else {
            // GoCode: panic(fmt.Sprintf("impjob: Driving impjob^imptp failed with error: %s", err))
            panic!("impjob: Driving impjob^imptp failed with error: {}", err);
        }
    }

    // Use the Rust API
    // MCode: write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    println!("Start Time : {}", now());
    // MCode: write "$zro=",$zro,!
    println!(
        "$zro={}",
        String::from_utf8_lossy(&Key::variable(ctx, "$ZROUTINES").get()?)
    );

    // MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE" merge %imptp=^%imptp
    // GoCode: No need to translate the above M line as parent would have YDB_ASSERT failed in that case.
    //
    // MCode: set jobno=jobindex	; Set by job.m ; not using $job makes imptp resumable after a crash!
    Key::variable(ctx, "jobno").set(jobindex.to_string())?;
    // MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
    // GoCode: Bypassed - this fetch has already been done in this function
    //
    // MCode: set fillid=^%imptp("fillid",jobid)
    let mut imptp = Key::new(ctx, "^%imptp", &["fillid", jobid]);
    let fillid = imptp.get()?;
    Key::variable(ctx, "fillid").set(&fillid)?;
    imptp[0] = fillid.as_slice().into();

    // Given a subscript `name`, get ^%imptp(fillid,name) and parse it as a number.
    let get_num = |name: &str| -> YDBResult<i32> {
        let imptp = Key::new(ctx, "^%imptp", &[fillid.as_slice(), name.as_bytes()]);
        let val = imptp.get()?;
        let val = String::from_utf8_lossy(&val);
        val.parse().map_err(|err| {
            panic!(
                "failed to parse {}: {}\nnote: while parsing {}",
                name, err, val
            )
        })
    };

    // Given a subscript `name`, set name=^%imptp(fillid,name) and return its value.
    let get_and_set = |name: &str| -> YDBResult<_> {
        let rust_var = Key::new(ctx, "^%imptp", &[fillid.as_slice(), name.as_bytes()]).get()?;
        Key::variable(ctx, name).set(&rust_var)?;
        Ok(rust_var)
    };

    // Same as `get_and_set`, but the value is parsed as a number.
    let get_and_set_num = |name| -> YDBResult<_> {
        let rust_var = get_num(name)?;
        set(ctx, name, rust_var)?;
        Ok(rust_var)
    };

    // MCode: set jobcnt=^%imptp(fillid,"totaljob")
    let jobcnt = i64::from(get_num("totaljob")?);
    set(ctx, "jobcnt", jobcnt)?;

    // MCode: set prime=^%imptp(fillid,"prime")
    let prime = i64::from(get_num("prime")?);
    // MCode: set root=^%imptp(fillid,"root")
    let root = i64::from(get_num("root")?);
    // MCode: set top=+$GET(^%imptp(fillid,"top"))
    // GoCode: top, err := pctImptpInt32(tptoken, nil, &shr, "top", true)
    // MCode: if top=0 set top=prime\jobcnt
    let mut top = i64::from(get_num("top").unwrap_or(0));
    if top == 0 {
        // NOTE: In Rust, `/` performs integer division (i.e. rounds towards 0) when given integer arguments
        top = prime / jobcnt;
    }
    // MCode: set istp=^%imptp(fillid,"istp")
    let istp = get_and_set_num("istp")?;
    // MCode: set tptype=^%imptp(fillid,"tptype")
    let tptype = get_and_set("tptype")?;
    let tptype = String::from_utf8_lossy(&tptype);
    // MCode: set tpnoiso=^%imptp(fillid,"tpnoiso")
    let tpnoiso = get_and_set_num("tpnoiso")?;
    // MCode: set dupset=^%imptp(fillid,"dupset")
    let dupset = get_and_set_num("dupset")?;
    // MCode: set skipreg=^%imptp(fillid,"skipreg")
    let skipreg = get_and_set_num("skipreg")?;
    // MCode: set crash=^%imptp(fillid,"crash")
    let crash = get_and_set_num("crash")?;
    // MCode: set gtcm=^%imptp(fillid,"gtcm")
    let gtcm = get_and_set_num("gtcm")?;

    // MCode: ; ONLINE ROLLBACK - BEGIN
    // MCode: ; Randomly 50% when in TP, switch the online rollback TP mechanism to restart outside of TP
    // MCode: ;	orlbkintp = 0 disable online rollback support - this is the default
    // MCode: ;	orlbkintp = 1 use the TP rollback mechanism outside of TP, should be true for only TP
    // MCode: ;	orlbkintp = 2 use the TP rollback mechanism inside of TP, should be true for only TP
    // MCode: set orlbkintp=0
    // MCode: new ORLBKRESUME
    // MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE" do init^orlbkresume("imptp",$zlevel,"ERROR^imptp") if istp=1 set orlbkintp=($random(2)+1)
    // MCode: ; ONLINE ROLLBACK -  END
    //
    // GoCode: The above online rollback section does not need to be migrated since we never run SimpleAPI/GoSimpleAPI against online rollback

    // MCode: set orlbkintp=0
    let orlbkintp = 0;
    set(ctx, "orlbkintp", orlbkintp)?;

    // MCode: ; Node Spanning Blocks - BEGIN
    // MCode: set keysize=^%imptp(fillid,"key_size")
    // Can't use `get_and_set_num` because the variable names are different
    let keysize = get_num("key_size")?;
    set(ctx, "keysize", keysize)?;
    // MCode: set recsize=^%imptp(fillid,"record_size")
    let recsize = get_num("record_size")?;
    set(ctx, "recsize", recsize)?;
    // MCode: set span=+^%imptp(fillid,"gtm_test_spannode")
    let span = get_num("gtm_test_spannode")?;
    set(ctx, "span", span)?;

    // MCode: ; Node Spanning Blocks - END

    // MCode: ; TRIGGERS - BEGIN
    // MCode: ; The triggers section MUST be the last update to ^%imptp during setup. Online Rollback tests use this as a marker to detect
    // MCode: ; when ^%imptp has been rolled back.

    // MCode: set trigger=^%imptp(fillid,"trigger"),ztrcmd="ztrigger ^lasti(fillid,jobno,loop)",ztr=0,dztrig=0
    let trigger = get_and_set_num("trigger")?;
    set(ctx, "ztrcmd", "ztrigger ^lasti(fillid,jobno,loop)")?;
    // GoCode: shr.ztr = false
    // GoCode: shr.dztrig = false
    let mut ztr = false;
    // see below for dztrig

    // MCode: if trigger do
    // MCode: . set trigname="triggernameforinsertsanddels"
    // MCode: . set fulltrig="^unusedbyothersdummytrigger -commands=S -xecute=""do ^nothing"" -name="_trigname
    // MCode: . set ztr=(trigger#10)>1  ; ZTRigger command testing
    // MCode: . set dztrig=(trigger>10) ; $ZTRIGger() function testing
    // MCode: ; TRIGGERS -  END

    // GoCode: if 0 != shr.trigger {
    // GoCode:     err = yottadb.SetValE(tptoken, nil, "triggernameforinsertsanddels", "trigname", []string{})
    // GoCode:     err = yottadb.SetValE(tptoken, nil,
    // GoCode:	        "^unusedbyothersdummytrigger -commands=S -xecute=\"do ^nothing\" -name=triggernameforinsertsanddels",
    // GoCode:	        "fulltrig", []string{})
    // GoCode: }
    let dztrig = if trigger != 0 {
        set(ctx, "trigname", "triggernameforinsertsanddels")?;
        set(ctx, "fulltrig", "^unusedbyothersdummytrigger -commands=S -xecute=\"do ^nothing\" -name=triggernameforinsertsanddels")?;
        // GoCode: shr.ztr = 1 < (shr.trigger % 10)
        ztr = 1 < (trigger % 10);
        10 < trigger
    } else {
        false
    };
    set(ctx, "ztr", ztr as i32)?;
    set(ctx, "dztrig", dztrig)?;

    // MCode: set zwrcmd="zwr jobno,istp,tptype,tpnoiso,orlbkintp,dupset,skipreg,crash,gtcm,fillid,keysize,recsize,trigger"
    // MCode: write zwrcmd,!
    // MCode: xecute zwrcm
    println!("jobno={}", jobindex);
    zwrite!(
        istp, &tptype, tpnoiso, orlbkintp, dupset, skipreg, crash, gtcm, &fillid, keysize, recsize,
        trigger
    );

    // MCode: write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
    println!("PID: {}", pid);
    println!("In hex: {:x}", pid);

    // MCode: lock +^%imptp(fillid,"jsyncnt")  set ^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"jsyncnt")+1  lock -^%imptp(fillid,"jsyncnt")
    // The "ydb_lock_incr_s" and "ydb_lock_decr_s" usages below are unnecessary since "ydb_incr_s" is atomic.
    // But we want to test the SimpleAPI/SimpleThreadAPI lock functions and so have them here just like the M version of imptp.
    imptp[1] = "jsyncnt".into();
    imptp.lock_incr(LOCK_TIMEOUT)?;
    // TODO: Go does something different than M here
    // TODO: I'm not sure what `shr.bufvalue` is - from the usage elsewhere it appears to just be a spare buffer? So why is it being used for IncrSt?
    // GoCode: if 1 == int(rand.Float64()*2) {
    // GoCode:     valptr = shr.bufvalue
    // GoCode: } else {
    // GoCode:     valptr = nil
    // GoCode: }
    // GoCode: err = shr.gblPctImptp.IncrST(tptoken, nil, nil, valptr)
    imptp.increment(None)?;
    imptp.lock_decr()?;

    // MCode: ; lfence is used for the fence type of last segment of updates of *ndxarr at the end
    // MCode: ; For non-tp and crash test meaningful application checking is very difficult
    // MCode: ; So at the end of the iteration TP transaction is used
    // MCode: ; For gtcm we cannot use TP at all, because it is not supported.
    // MCode: ; We cannot do crash test for gtcm.
    //
    // MCode: set lfence=istp
    // MCode: if (istp=0)&(crash=1) set lfence=1	; TP fence
    // MCode: if gtcm=1 set lfence=0		; No fence
    // TODO: this logic looks right but needs testing
    let lfence = if gtcm == 1 {
        0
    } else if istp == 0 && crash == 1 {
        1
    } else {
        istp
    };
    set(ctx, "lfence", lfence)?;

    // MCode: if tpnoiso do tpnoiso^imptp
    // GoCode: _, err = yottadb.CallMT(tptoken, nil, 0, "tpnoiso")
    if tpnoiso != 0 {
        call(ctx, b"tpnoiso\0")?;
    }
    // MCode: if dupset view "GVDUPSETNOOP":1
    // GoCode: _, err = yottadb.CallMT(tptoken, nil, 0, "dupsetnoop")
    if dupset != 0 {
        call(ctx, b"dupsetnoop\0")?;
    }

    // MCode: set nroot=1
    // MCode: for J=1:1:jobcnt set nroot=(nroot*root)#prime

    // Same as `nroot = pow(root, jobcnt) % prime`,
    // but using a loop avoids overflows
    let mut nroot = 1;
    for _ in 0..jobcnt {
        nroot = (nroot * root) % prime;
    }

    // MCode: ; imptp can be restarted at the saved value of lasti
    //
    // MCode: set lasti=+$get(^lasti(fillid,jobno))
    let lasti = Key::new(
        ctx,
        "^lasti",
        &[fillid.as_slice(), jobindex.to_string().as_bytes()],
    );
    let lasti = match lasti.get() {
        Err(YDBError {
            status: YDB_ERR_GVUNDEF,
            ..
        }) => 0,
        Err(other) => return Err(other),
        Ok(val) => String::from_utf8_lossy(&val).parse().unwrap(),
    };

    // MCode: zwrite lasti
    zwrite!(lasti);

    // MCode: ; Initially we have followings:
    // MCode: ; 	Job 1: I=w^0
    // MCode: ; 	Job 2: I=w^1
    // MCode: ; 	Job 3: I=w^2
    // MCode: ; 	Job 4: I=w^3
    // MCode: ; 	Job 5: I=w^4
    // MCode: ;	nroot = w^5 (all job has same value)
    // MCode: set I=1
    // MCode: for J=2:1:jobno  set I=(I*root)#prime
    // MCode: for J=1:1:lasti  set I=(I*nroot)#prime
    let mut i = 1_i64;
    // i = pow(root, jobindex) % prime
    for _ in 2..=jobindex {
        i = (i * root) % prime;
    }
    // pow(pow(root, jobindex), lasti - 1) % prime
    for _ in 1..=lasti {
        i = (i * nroot) % prime;
    }
    // MCode: write "Starting index:",lasti+1,!
    println!("Starting index: {}", lasti + 1);

    // MCode: for loop=lasti+1:1:top do  quit:$get(^endloop(fillid),0)
    // Since we need `loop_` to persist longer than the loop itself,
    // we can't use `for loop_ in lasti+i ..= top`
    let mut loop_ = lasti + 1;
    // There is another condition at the end of the loop which checks ^endloop
    while loop_ <= top {
        // GoCode: Set I and loop M variables (needed by "helper1" call-in code)
        set(ctx, "I", i)?;
        set(ctx, "loop", loop_)?;

        // MCode: ; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
        // MCode: do pauseifneeded^pauseimptp
        // MCode: set subs=$$^ugenstr(I)		; I to subs  has one-to-one mapping
        // MCode: set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
        // MCode: set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
        // MCode: set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
        // MCode: set valMAX=$j(val,recpad)
        // MCode: set valALT=$select(span>1:valMAX,1:val)
        // MCode: set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
        // MCode: set subsMAX=$j(subs,keypad)
        // MCode: if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
        // GoCode: _, err = shr.callhelper1.CallMDescT(tptoken, nil, 0)
        call(ctx, b"helper1\0")?;

        // . ; Stage 1
        // . if istp=1 tstart *:(serial:transaction=tptype)
        // Run a block of code as a TP or non-TP transaction based on "istp" variable

        // GoCode: rc = tpfnStage1(tptoken, nil, &shr)
        // GoCode: if yottadb.YDB_OK != rc {
        // GoCode: 	if yottadb.YDB_ERR_CALLINAFTERXIT == rc {
        // GoCode: 		return
        // GoCode: 	}
        // GoCode: 	panic(fmt.Sprintf("TP transaction (tpfnStage1) failed with rc = %d", rc))
        // GoCode: }

        // Returns whether the function returned `CALLINAFTERXIT`
        let call_allow_callinafterexit =
            |f: &dyn Fn(&Context) -> Result<_, Box<dyn Error + Send + Sync>>| match f(ctx) {
                Err(err) => match err.downcast_ref() {
                    Some(YDBError { status, .. }) if *status == craw::YDB_ERR_CALLINAFTERXIT => {
                        true
                    }
                    _ => panic!("{}", err),
                },
                Ok(_) => false,
            };
        if istp == 1 {
            ctx.tp(|ctx| tp_stage1(ctx, jobindex, loop_), &tptype, &[])
                .expect("transaction stage 1 failed");
        } else if call_allow_callinafterexit(&|ctx| tp_stage1(ctx, jobindex, loop_)) {
            return Ok(());
        }
        // MCode: if istp=1 tcommit

        // MCode: . ; Stage 2
        // MCode: . set rndm=$random(10)
        // MCode: . if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
        // MCode: . . set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig)
        // MCode: . . set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms
        // MCode: . . xecute ztrigstr
        // MCode: . . if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error
        // MCode: . . goto:'ztrigret ERROR
        // GoCode: _, err = shr.callhelper2.CallMDescT(tptoken, nil, 0)
        call(ctx, b"helper2\0")?;

        // MCode: . set ^antp(fillid,subs)=val
        let val = get(ctx, "val")?;
        let val_alt = get(ctx, "valALT")?;
        let subs = get(ctx, "subs")?;
        let mut ntp = Key::new(ctx, "^antp", &[fillid.as_slice(), subs.as_slice()]);
        ntp.set(&val)?;

        // MCode: . if 'trigger do
        if trigger != 0 {
            // MCode: . . set ^bntp(fillid,subs)=val
            ntp.variable = "^bntp".into();
            ntp.set(&val)?;
            // MCode: . . set ^cntp(fillid,subs)=val
            ntp.variable = "^cntp".into();
            ntp.set(&val)?;
            // MCode: . . set ^dntp(fillid,subs)=valALT
            ntp.variable = "^dntp".into();
            ntp.set(&val_alt)?;
        }

        // MCode: . ; Stage 3
        // MCode: . if istp=1 tstart ():(serial:transaction=tptype)
        if istp == 1 {
            ctx.tp(tp_stage3, &tptype.to_string(), &[])
                .expect("transaction stage 1 failed");
        } else if call_allow_callinafterexit(&tp_stage3) {
            return Ok(());
        }
        // MCode: if istp=1 tcommit

        // MCode: . ; Stages 4 thru 11
        // MCode: . ; Stage 4
        // MCode: . for J=1:1:jobcnt D
        // MCode: . . set valj=valALT_J
        // MCode: . . ;
        // MCode: . . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
        // MCode: . . set ^arandom(fillid,subs,J)=valj
        // MCode: . . if 'trigger do
        // MCode: . . . set ^brandomv(fillid,subs,J)=valj
        // MCode: . . . set ^crandomva(fillid,subs,J)=valj
        // MCode: . . . set ^drandomvariable(fillid,subs,J)=valj
        // MCode: . . . set ^erandomvariableimptp(fillid,subs,J)=valj
        // MCode: . . . set ^frandomvariableinimptp(fillid,subs,J)=valj
        // MCode: . . . set ^grandomvariableinimptpfill(fillid,subs,J)=valj
        // MCode: . . . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
        // MCode: . . . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
        // MCode: . . do:dztrig ^imptpdztrig(1,istp<2)
        // MCode: . . if istp=1 tcommit
        // MCode: . . ;
        // MCode: . ; Stage 5
        // MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
        // MCode: . do:dztrig ^imptpdztrig(2,istp<2)
        // MCode: . if ((istp=1)&(crash)) do
        // MCode: . . set rndm=$random(10)
        // MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
        // MCode: . . if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time
        // MCode: . kill ^arandom(fillid,subs,1)
        // MCode: . if 'trigger do
        // MCode: . . kill ^brandomv(fillid,subs,1)
        // MCode: . . kill ^crandomva(fillid,subs,1)
        // MCode: . . kill ^drandomvariable(fillid,subs,1)
        // MCode: . . kill ^erandomvariableimptp(fillid,subs,1)
        // MCode: . . kill ^frandomvariableinimptp(fillid,subs,1)
        // MCode: . . kill ^grandomvariableinimptpfill(fillid,subs,1)
        // MCode: . . kill ^hrandomvariableinimptpfilling(fillid,subs,1)
        // MCode: . . kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
        // MCode: . do:dztrig ^imptpdztrig(1,istp<2)
        // MCode: . do:dztrig ^imptpdztrig(2,istp<2)
        // MCode: . if istp=1 tcommit
        // MCode: . ; Stage 6
        // MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
        // MCode: . zkill ^jrandomvariableinimptpfillprogram(fillid,I)
        // MCode: . if 'trigger do
        // MCode: . . zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
        // MCode: . if istp=1 tcommit
        // MCode: . ; Stage 7 : delimited spanning nodes to be changed in Stage 10
        // MCode: . ; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan
        // MCode: . ; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef
        // MCode: . ;				 		2. ^aspan=^espan and ^bspan is undef
        // MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
        // MCode: . ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
        // MCode: . set piecesize=7
        // MCode: . set valPIECE=valMAX
        // MCode: . set totalpieces=($length(valPIECE)/piecesize)+1
        // MCode: . for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|" ; $extract beyond $length returns a null character
        // MCode: . set totalpieces=$length(valPIECE,"|")
        // MCode: . set ^aspan(fillid,I)=valPIECE
        // MCode: . if 'trigger do
        // MCode: . . set ^espan(fillid,I)=$get(^aspan(fillid,I))
        // MCode: . . set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","")
        // MCode: . if istp=1 tcommit
        // MCode: . ; Stage 8
        // MCode: . kill ^arandom(fillid,subs,1)	; This results nothing
        // MCode: . kill ^antp(fillid,subs)
        // MCode: . if 'trigger do
        // MCode: . . kill ^bntp(fillid,subs)
        // MCode: . . zkill ^brandomv(fillid,subs,1)	; This results nothing
        // MCode: . . zkill ^cntp(fillid,subs)
        // MCode: . . zkill ^dntp(fillid,subs)
        // MCode: . kill ^bntp(fillid,subsMAX)
        // MCode: . if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
        // MCode: . ; Stage 9
        // MCode: . ; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
        // MCode: . set flag=$random(2)
        // MCode: . if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
        // MCode: . set cntloop=$incr(^cntloop(fillid))
        // MCode: . set cntseq=$incr(^cntseq(fillid),(13+jobcnt))
        // MCode: . if flag=1,lfence=1 tcommit
        // MCode: . ; Stage 10 : More SET $piece
        // MCode: . ; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece)
        // MCode: . ; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece
        // MCode: . ; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan
        // MCode: . ;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
        // MCode: . ;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
        // MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
        // MCode: . set targetpiece=(loop#(totalpieces))
        // MCode: . set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X")
        // MCode: . zkill ^espan(fillid,I)
        // MCode: . set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece
        // MCode: . if 'trigger do
        // MCode: . . set $piece(^espan(fillid,I),"|",targetpiece)=subpiece
        // MCode: . . set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece
        // MCode: . if istp=1 tcommit
        // MCode: . ; Stage 11
        // MCode: . if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
        // MCode: . do:dztrig ^imptpdztrig(1,istp<2)
        // MCode: . xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole="""""
        // MCode: . set ^andxarr(fillid,jobno,loop)=I
        // MCode: . if 'trigger do
        // MCode: . . set ^bndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^cndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^dndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^endxarr(fillid,jobno,loop)=I
        // MCode: . . set ^fndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^gndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^hndxarr(fillid,jobno,loop)=I
        // MCode: . . set ^indxarr(fillid,jobno,loop)=I
        // MCode: . if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
        // MCode: . if lfence=1 tcommit
        // GoCode: _, err = shr.callhelper3.CallMDescT(tptoken, nil, 0)
        call(ctx, b"helper3\0")?;

        // MCode: . set I=(I*nroot)#prime
        i = (i * nroot) % prime;
        // MCode: quit:$get(^endloop(fillid),0)
        // GoCode: err = shr.gblendloop.ValST(tptoken, nil, shr.bufvalue)
        // GoCode: if nil != err {
        // GoCode: 	if yottadb.YDB_ERR_GVUNDEF == yottadb.ErrorCode(err) {
        // GoCode: 		continue
        // GoCode: 	}
        // GoCode: 	if imp.CheckErrorReturn(err) {
        // GoCode: 		return
        // GoCode: 	}
        // GoCode: }
        // GoCode: valstr, err = shr.bufvalue.ValStr(tptoken, nil)
        // GoCode: valint64, err = strconv.ParseInt(valstr, 10, 32)
        // GoCode: if 0 != valint64 {
        // GoCode: 	break
        // GoCode: }

        match Key::new(ctx, "^endloop", &[fillid.as_slice()]).get() {
            Err(YDBError {
                status: YDB_ERR_GVUNDEF,
                ..
            }) => {}
            // TODO: the Go implementation has a notion of recoverable errors, we should too
            Err(other) => panic!(other),
            Ok(val) => {
                if val != b"0" {
                    break;
                }
            }
        };
        loop_ += 1;
    } // MCode: ; End FOR loop
      // MCode: write "End index:",loop,!
    println!("End index: {}", loop_);
    // MCode: write "Job completion successful",!
    println!("Job completion successful");
    // MCode: write "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
    println!("End Time: {}", now());

    Ok(())
}

// GoCode: tpfnStage1 is the stage 1 TP callback routine
fn tp_stage1(ctx: &Context, jobno: usize, loop_: i64) -> Result<TransactionStatus, Box<dyn Error + Send + Sync>> {
    let mut rng = rand::thread_rng();

    // MCode: . set ^arandom(fillid,subsMAX)=val
    let fillid = Key::variable(ctx, "fillid").get()?;
    let subs_max = Key::variable(ctx, "subsMAX").get()?;
    let val = get(ctx, "val")?;
    let arandom = Key::new(ctx, "^arandom", &[fillid.as_slice(), subs_max.as_slice()]);
    arandom.set(&val)?;

    // GoCode: 	if (0 != shr.istp) && (0 != shr.crash) {
    // MCode: . . set rndm=$r(10)

    // TODO: I think this `?` will prevent downcasting later
    // TODO: that would apply to all callbacks, not just to this test code
    // TODO: maybe `tp_st` should rethink downcasting altogether?
    let istp: i32 = Key::variable(ctx, "istp").get_and_parse()?;
    let crash: i32 = Key::variable(ctx, "crash").get_and_parse()?;
    if istp != 0 && crash != 0 {
        // MCode: . . set rndm=$r(10)
        // MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
        let rndm = rng.gen_range(0, 10);
        let trestart: i32 = Key::variable(ctx, "$TRESTART").get_and_parse()?;
        if trestart > 2 {
            if rndm == 1 {
                call(ctx, b"noop\0")?;
            // MCode: . . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
            } else if rndm == 2 {
                thread::sleep(Duration::from_secs(rng.gen_range(1, 11)));
            }
        // MCode: . . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow
        } else if trestart != 0 {
            Key::new(ctx, "^zdummy", &[trestart.to_string()]).set(jobno.to_string())?;
        }
    }

    // MCode: . set ^brandomv(fillid,subsMAX)=valALT
    let val_alt = get(ctx, "valALT")?;
    let mut random = Key::new(ctx, "^brandomv", &[fillid.as_slice(), subs_max.as_slice()]);
    random.set(&val_alt)?;
    // MCode: . if 'trigger do
    let trigger = Key::variable(ctx, "trigger").get_and_parse::<isize>()? != 0;
    if !trigger {
        // MCode: . . set ^crandomva(fillid,subsMAX)=valALT
        random.variable = "^crandomva".into();
        random.set(&val_alt)?;
    }
    // MCode: . set ^drandomvariable(fillid,subs)=valALT
    random.variable = "^drandomvariable".into();
    random[1] = get(ctx, "subs")?;
    random.set(&val_alt)?;

    // MCode: . if 'trigger do
    if !trigger {
        // MCode: . . set ^erandomvariableimptp(fillid,subs)=valALT
        random.variable = "^erandomvariableimptp".into();
        random.set(&val_alt)?;

        // MCode: . . set ^frandomvariableinimptp(fillid,subs)=valALT
        random.variable = "^frandomvariableinimptp".into();
        random.set(&val_alt)?;
    }
    // MCode: . set ^grandomvariableinimptpfill(fillid,subs)=val
    random.variable = "^grandomvariableinimptpfill".into();
    random.set(&val)?;

    // MCode: . if 'trigger do
    if !trigger {
        // MCode: . . set ^hrandomvariableinimptpfilling(fillid,subs)=val
        random.variable = "^hrandomvariableinimptpfilling".into();
        random.set(&val)?;

        // MCode: . . set ^irandomvariableinimptpfillprgrm(fillid,subs)=val
        random.variable = "^irandomvariableinimptpfillprgrm".into();
        random.set(&val)?;
    } else {
        // MCode: . if trigger xecute ztwormstr	; fill in $ztwormhole for below update that requires "subs"
        // GoCode: 	shr.callztwormstr = imp.NewCallMDesc("ztwormstr")
        // GoCode: _, err = shr.callztwormstr.CallMDescT(tptoken, errstr, 0)
        call(ctx, b"ztwormstr\0")?;
    }
    // MCode: . set ^jrandomvariableinimptpfillprogram(fillid,I)=val
    let i = get(ctx, "I")?;
    let mut j = Key::new(
        ctx,
        // M silently truncates to 32 characters, but the SimpleAPI does not.
        // Instead we do this truncation manually.
        &"^jrandomvariableinimptpfillprogram"[..32],
        &[fillid.as_slice(), i.as_slice()],
    );
    j.set(&val)?;

    // MCode: . if 'trigger do
    if !trigger {
        // MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val
        j.push(i);
        j.set(&val)?;

        // MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val
        // recall that `random` is `^irandomvariableinimptpfillprgrm(fillid,subs)`
        j.push(random[1].clone());
        j.set(&val)?;
    }

    // MCode: . if istp'=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
    // GoCode: if 0 != shr.istp {
    // GoCode:     if shr.ztr {
    // GoCode:         _, err = shr.callztrcmd.CallMDescT(tptoken, errstr, 0)
    // GoCode:     }
    // GoCode:     err = shr.gbllasti.SetValST(tptoken, errstr, shr.bufvalue)
    // GoCode: }
    let ztr: i32 = Key::variable(ctx, "ztr").get_and_parse()?;
    if istp != 0 {
        if ztr != 0 {
            call(ctx, b"ztrcmd\0")?;
        }
        let lasti = Key::new(
            ctx,
            "^lasti",
            &[fillid.as_slice(), jobno.to_string().as_bytes()],
        );
        lasti.set(loop_.to_string())?;
    }
    Ok(TransactionStatus::Ok)
}

// GoCode: tpfnStage3 is the stage 3 TP callback routine
fn tp_stage3(ctx: &Context) -> Result<TransactionStatus, Box<dyn Error + Send + Sync>> {
    // MCode: . do:dztrig ^imptpdztrig(2,istp<2)
    // GoCode: if shr.dztrig {
    // GoCode:    _, err = shr.callimptpdztrig.CallMDescT(tptoken, errstr, 0)
    let dztrig = Key::variable(ctx, "dztrig").get_and_parse()?;
    if dztrig {
        call(ctx, b"imptpdztrig\0")?;
    }
    // MCode: . set ^entp(fillid,subs)=val
    let fillid = get(ctx, "fillid")?;
    let val = get(ctx, "val")?;
    let subs = get(ctx, "subs")?;
    let mut ntp = Key::new(ctx, "^entp", &[fillid.as_slice(), subs.as_slice()]);
    ntp.set(&val)?;

    // MCode: . if 'trigger do
    ntp.variable = "^fntp".into();
    let is_tp: i32 = Key::variable(ctx, "istp").get_and_parse()?;
    let trigger = Key::variable(ctx, "trigger").get_and_parse::<isize>()? != 0;
    if !trigger {
        // MCode: . . set ^fntp(fillid,subs)=val
        ntp.set(&val)?;
    } else {
        // MCode: . . set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix"))
        let mut current = ntp.get()?;
        let len = current.len();
        // GoCode: if 6 <= vallen { // 6 == $length("suffix")
        // GoCode:     vallen = vallen - 6
        // GoCode: } else {
        // GoCode:     if 0 == shr.istp { // Should only be possible in TP and is a restartable condition then
        // GoCode:         panic("Value less than 6 bytes and not using TP")
        // GoCode:     }
        // GoCode:     return yottadb.YDB_TP_RESTART
        // GoCode: }
        if 6 <= len {
            current.truncate(len - 6);
        } else if is_tp == 0 {
            panic!("Value less than 6 bytes and not using TP");
        } else {
            return Ok(TransactionStatus::Restart);
        }
        ntp.set(current)?;
    }

    // MCode: . set ^gntp(fillid,subsMAX)=valMAX
    let subs_max = get(ctx, "subsMAX")?;
    let val_max = get(ctx, "valMAX")?;
    ntp.variable = "^gntp".into();
    ntp[1] = subs_max;
    ntp.set(&val_max)?;

    // MCode: . if 'trigger do
    if !trigger {
        // MCode: . . set ^hntp(fillid,subsMAX)=valMAX
        ntp.variable = "^hntp".into();
        ntp.set(&val_max)?;
        // MCode: . . set ^intp(fillid,subsMAX)=valMAX
        ntp.variable = "^intp".into();
        ntp.set(&val_max)?;
        // MCode: . . set ^bntp(fillid,subsMAX)=valMAX
        ntp.variable = "^bntp".into();
        ntp.set(&val_max)?;
    }

    Ok(TransactionStatus::Ok)
}
