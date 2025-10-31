//////////////////////////////////////////////////////////////////
//
// Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.
// All rights reserved.
//
//	This source code contains the intellectual property
//	of its copyright holder(s), and is made available
//	under a license.  If you do not know the terms of
//	the license, please stop and do not read further.
//
//////////////////////////////////////////////////////////////////

package main

/* IMPTP: Infinite MultiProcess TP (or non-TP) database fill program (i.e. dbfill).
	* YDBGo v2 version of imptp

This is a Go implementation of imptp using multiple processes as 'workers' or 'jobs'. Small portions are still implemented in M
using call-ins because it is either impossible or easier than migration from M and does not benefit test coverage of the API.
The main program starts worker processes and then exits, leaving the workers running.
Worker processes are created by re-running this program with the '--worker' flag.
The user will typically run endtp.csh to stop the background worker processes and then
checkdb.csh should be run after the program is done.

This version enhances other imptp versions in the following ways that make it easier to test it standalone:
	* runs with just 'go run imptpgo2.go'
	* cleans its database variables to start with a clean database if --clean is specified
	* defaults gtm_badchar to "no" so that jobs don't die
	* add --verbose, --clean, --iterations, and --parentischild command line options for debugging (see below)
	* accepts on the commandline <number_of_jobs> to be started.
	* documents environment variable inputs and provides a glossary for variable names (see below)

Usage: imptpgo_v2 [--help|-h] [--worker=<n>] [--verbose|-v] [--clean] [--iterations=<n>] [<number_of_jobs>]
	* --worker=<n> determines that the new instance will be a child job and specifies the index number of the job (1 - <number_of_jobs>).
		It is used automatically by the main (parent) process to run child jobs.
	* --verbose|-v Also output child logs to /dev/tty. Can be most helpful for debugging if only 1 job is specified.
	* --clean cleans all variables used by the program before running; otherwise it tries to recover and continue the previous run.
	* --iterations=<n> (default to ^%imptp(fillid,"top") or prime/<number_of_jobs> -- takes a couple hours) number of full-loop iterations performed in each job.
	* --parentischild runs the child job (forced to 1 job) in the parent process. Useful for debugging.
	* <number_of_jobs> (default env gtm_test_jobcnt or 5 if unset). It is ignored when --worker is specified (each worker is only one job).
	* The test system calls imptp.csh to run this Go program. The caller sets environment variables below as appropriate.
	* For a quick run of the program for debug purposes:
		go run imptpgo2.go --verbose --clean --iterations=10000 && pgrep imptpgo2 -a
		checkdb.csh # To check that it filled the database with what it should have
	* This will run for maybe 5 or 10 seconds, except it occasionally randomly selects to pause for 10s in contentious TP restarts.

Note that to test imptpgo with triggers you first need to load the trigger files in $gtm_tst:
	mupip trigger -noprompt  -triggerfile=imptp.trg
	mupip trigger -noprompt  -triggerfile=imptpztr.trg
For trigger activation sequence see comment at the end of imptp.trg

Note for use within the YottaDB `gtmtest` system: to use a local development version of YDBGo, mount it as /YDBGo within docker and gtmtest will use it.
The following command is quite useful for testing with gtmtest:
	gtmtest -fg -k -nomail -dontzip -stdout 2 -env ydb_imptp_flavor=6 -env gtm_test_dbfill=IMPTP -env gtm_test_tp=[NON_]TP -t gtm8086
Note that with gtmtests, some tests take 120 seconds to detect even fast failures. You can speed these up by pre-setting duration=10.

Environment inputs:
	gtm_badchar             # (default "no") If "no", tell YottaDB not to produce errors when it encounters an illegal UTF-8 sequence; jobs bomb out otherwise
	gtm_test_jobcnt         # (default 5), stored into M local 'jobcnt' for use by M callins (instead of passing a parameter)
	gtm_test_jobid          # (default 0) jobid is stored into M local 'jobid' for use by M callins (instead of passing a parameter)
				# and is used as an index into ^%imptp("fillid",jobid) and ^%jobwait(jobid, *)
	gtm_test_dbfillid       # (default 0) set to different numbers to run multiple fills concurrently. Stored in M local 'fillid'
	gtm_test_dbfill         # (default "IMPTP") used only to produce an error if set to "IMPZTP" as ZTSTART can't be simulated with C API
	gtm_test_noisolation    # (default 0/1 randomly) if this is "TPNOISO", use M 'VIEW NOISOLATION' on variables in transactions
	gtm_test_crash          # (default 0) whether to simulate a process crash; stored into ^%imptp(fillid,"crash")
	gtm_test_is_gtcm        # (default 0) whether database is remote in client-server mode; stored into ^%imptp(fillid,"gtcm")
	gtm_test_repl_norepl    # (default 0) >0 means database replication of region HREG is off. Stored into ^%imptp(fillid,"skipreg")
	gtm_test_spannode       # (default 0) stored into ^%imptp(fillid,"gtm_test_spannode")
	gtm_test_onlinerollback # (default FALSE) panic if set to TRUE since online rollback isn't supported by the YottaDB C API
	gtm_test_tptype         # (default "BATCH") use transaction ID ONLINE if set to "ONLINE"; otherwise use "BATCH"
	gtm_test_tp             # (default "TP") NON_TP, TP, or ZTP => 0, 1, 2 stored into istp and ^%imptp(fillid,"istp")
				# if it is NON_TP, don't use TSTART/TCOMMIT; if (Z)TP use (Z)TSTART/(Z)TCOMMIT commands
				# ZTP is equivalent to TP in non-M versions

Fill algorithm
	The program fills the database by storing data in psdueo-random subscripts of the variables defined in the 'cleanups' list below.
	The test system may specify regions and specific region parameters for these variables in advance to test specific features.
	Triggers are also set on these variables during the imptp test to test the trigger system.
	After running, the validity of the filled data may be checked afterward with checkdb.m which uses the same algorithm.

	Each pseudo-random subscript is a string generated by M function ^ugenstr(I) from a pseudo-random index I.
	Each pseudo-random index I is generated by a repeatable pseudo-random generator (see below).
	If the process is stopped part way through it may be continued by re-running the imptp program and it will recover
	its last index from the database variable ^lasti(fillid,jobno) and re-calculate the random sequence up to that point,
	so that it can continue from that point onwards.

Fill algorithm variable names
	prime = prime number used in fill algorithm
	root = prime root used in fill algorithm
	top = (default prime/jobCount): maximum number of loop iterations performed in each job (see --iterations)
	keysize = size of database keys
	recordSize = size of database records

Pseudo-random index generator
	The pseudo-random number is generated with a custom generator essentially defined by the formula
		I' = I * root % prime
	where root=5 and prime=50000017.

	Note: this sequence is equivalent to a common pseudo-random number generator formula x' = (a*x+c) mod m with c=0:
	  e.g.: https://bookdown.org/manuele_leonelli/SimBook/generating-pseudo-random-numbers.html#linear-congruential-method
	We have selected root as a primitive root of a specific prime, common in pseudo-random generators to increase apparent randomness.

	The original designer went to some lengths to ensure that the pseudo-random sequence generated for one
	job didn't overlap with any other job. But then he undermined that 'feature' by limiting 0 <= I < prime.
	Since he expended such effort to achieve this, I will document how it works in code comments below, though without
	understanding the original motivation.

Glossary of variables names (I have not deobfuscated M variable names because they are used by the M code which is used by other imptp tests)
	crash = whether to simulate a process crash
	dupset = Duplicate set: whether to optimize for redundant sets
	dztrig = Dollar ZTRIGger: whether to test the $ZTRIGGER() function (cf. ztr)
	fillid = fill ID: the number value to store into the database
	gtcm = gtcm is the name of the YottaDB database server program against which yottadb can run as a remote client
	imptp = Infinite MultiProcess Transactions Procedures: Database fill program (either TP or non-TP, despite calling itself 'tp')
	isTP = is Transaction Procedure: whether to use transactions
	jobcnt = job count: number of jobs to start
	jobid = job ID: index into job-specific database fields
	jsyncnt = job sync count: should be called simply 'started'; number of job processes started
	lfence = last fence: fence type of last segment of updates of *ndxarr at the end
	orlbkintp = online rollback: presumably relates to using "MUPIP JOURNAL -rollback -online" (this test is not supported by YottaDB C API)
	repl = replicate
	spannode = whether to span database nodes; not sure what this means
	sprgde = SPan Region randomization GDE: used with gensprgde.m to randomly map (or exclude) certain subscripts to regions
	subs = stores a created random string used as a subscript
	subsMax = stores maximally-padded version of subscript
	subtest = YottaDB testing system's sub-test name
	tpnoiso = TP no isolation: use "view NOISOLATION" on variables used in transactions (i.e. do not act like transactions)
	tptype = transaction ID: whether to use transaction ID "ONLINE" or "BATCH" which bypasses waiting for the journal to flush before ending a transaction
 	trigger = type of trigger test: 0=none; >0 means perform the same database operations but mostly through triggers as follows:
			if trigger%10>1 then test ZTRIGGER command; if trigger>10 then also test $ZTRIGGER() function
	ztp = use ZTSTART and ZTCOMMIT commands instead of TSTART and TCOMMIT
	ztr = ZTRigger: whether to test the ZTRIGGER command (cf. dztrig)

Known limitations:
	* The Go version panics if environment variable gtm_test_onlinerollback is set to TRUE since the C API doesn't support online rollback.
		I'm not sure why the API wouldn't support online rollback; by contrast, imptp.m invokes orlbkresume.m if this variable is TRUE.
	* Note that checkdb will error-out if gtcm and crash test are both used
	* For NON_TP and crash, this will still do some TP (transaction) updates
	* Skipreg is allowed only for crash test. For now it skips only HREG; though imptp.m (when called) will still fill HREG.
		checkdb/extract/dbcheck need to take care of skipping the region.
	* Can be invoked concurrently with different gtm_test_dbfillid but checkdb should be called once for each value.
*/

import (
	"flag"
	"fmt"
	"io"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"lang.yottadb.com/go/yottadb/v2"
	"lang.yottadb.com/go/yottadb/v2/ydberr"
)

// job number of this child process (1 to jobcnt for each of jobcnt processes run by parent process)
// This is to be distinguished from jobid which is the same for the whole group of processes started by the parent and including the parent.
var workerNo int
var iterations int     // number of iterations of main fill loop
var verbose bool       // leave child logs on stdout
var clean bool         // start from a clean database
var parentischild bool // run single child job in the parent process

func init() {
	flag.IntVar(&workerNo, "worker", -1, "specify child worker job number when starting the program as a worker child instead of running as parent")
	flag.IntVar(&iterations, "iterations", -1, "number of iterations of main database fill loop (default 50000017/jobs)")
	flag.BoolVar(&verbose, "verbose", false, "tell program to print all child logs to stdout for debugging")
	flag.BoolVar(&verbose, "v", false, "tell program to print all child logs to stdout for debugging")
	flag.BoolVar(&clean, "clean", false, "tell program to clean the database from the previous run first")
	flag.BoolVar(&parentischild, "parentischild", false, "runs the child job (forced to 1 job) in the parent process for debugging")
	flag.Parse()
}

var callin_table string = `
	xecute: xecute^imptpxc(string)
	getdatinfo: get^datinfo(string)
	helper1: helper1^imptpxc()
	helper2: helper2^imptpxc()
	helper3: helper3^imptpxc()
	imptpdztrig: imptpdztrig^imptpxc()
	impjob: impjob^imptp()
	noop: noop^imptp()
	tpnoiso: tpnoiso^imptp()
	writecrashfileifneeded: writecrashfileifneeded^job()
	ztwormstr: ztwormstr^imptpxc()
`

var M *yottadb.MFunctions
var settingsRoot string = "^%imptp" // the YottaDB global into which to store global setting parameters fetched from environment variables
var cleanups = []string{settingsRoot,
	"^endloop", "^cntloop", "^cntseq", "^%sprgdeExcludeGbllist", "^%jobwait", "^lasti", "^zdummy",
	"^arandom", "^brandomv", "^crandomva", "^drandomvariable", "^erandomvariableimptp", "^frandomvariableinimptp",
	"^grandomvariableinimptpfill", "^hrandomvariableinimptpfilling", "^irandomvariableinimptpfillprgrm",
	"^jrandomvariableinimptpfillprogr",
	"^antp", "^bntp", "^cntp", "^dntp", "^entp", "^fntp", "^gntp", "^hntp", "^intp",
}

// main runs multiple jobs to fills the database randomly in the sequence documented above.
func main() {
	log.SetFlags(0)                  // turn off date prefix on log messages
	log.SetOutput(os.Stdout)         // Could leave as Stderr but move to Stdout since M code prints messages to Stdout anyway
	rand.Seed(time.Now().UnixNano()) // Initialize random number generator seed

	defer yottadb.Shutdown(yottadb.MustInit())

	// Disable online rollback which, in imptp.m, transfers control to an M label orlbkres^imptp, etc.
	// which is not straightforward with API wrapper. See similar comment in imptp.csh.
	if os.Getenv("gtm_test_onlinerollback") == "TRUE" {
		panic("TEST-F-NOONLINEROLLBACK Online rollback is not supported with the API wrappers")
	}

	if workerNo == -1 {
		parent()
		return
	}

	// Verbose log option (prepends job number to each line which may disrupt tester scripts, so use only for debugging
	if verbose {
		terminal, err := os.Create("/dev/tty")
		if err != nil {
			panic(err)
		}
		multi := io.MultiWriter(os.Stdout, terminal) // send child's output to stderr to separate it from parent's stdout
		log.SetPrefix(fmt.Sprintf("[job%d] ", workerNo))
		log.SetOutput(multi)
	}
	child(workerNo)
}

// parent creates numerous child jobs by spawning this same executable but flagged with the --worker option.
// This function loads all environment variables with loadParameters() and saves them into settings at ^%imptp(fillID,<setting>).
// Then it spawns jobCount child jobs
func parent() {
	conn := yottadb.NewConn()
	M = conn.MustImport(callin_table)
	log.Println("Start time of parent:", time.Now().Format("02-Jan-2006 03:04:05.000"))
	settings, jobCount, fillID, jobID := loadParameters(conn) // Store global settings into this node

	// See whether there is a command line override on iterations (which child will otherwise set to prime/jobCount)
	if iterations != -1 {
		settings.Index("top").Set(iterations)
	}
	// Precalculate primitive root for a prime and set them here
	settings.Index("prime").Set(50000017)
	settings.Index("root").Set(5)
	endLoop := conn.Node("^endloop", fillID)
	endLoop.Set(false) // Set to true to stop infinite loop
	countLoop := conn.Node("^cntloop", fillID)
	countSequence := conn.Node("^cntseq", fillID)
	// Initialize M globals before attempting Incr() in child ^helper3 -- not sure why, as Incr() will do this anyway, but I'm copying M code
	if countLoop.HasNone() {
		countLoop.Set(0)
	}
	if countSequence.HasNone() {
		countSequence.Set(0)
	}

	// Initial number of started jobs
	started := settings.Child("jsyncnt") // number of started processes (when all started, we can crash-test them)
	started.Set(0)

	// If test is running with gtm_test_spanreg'=0, we want to make sure the *xarr global variables continue to
	// cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
	// See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
	// unconditionally excluding all these globals from random mapping to multiple regions.
	// This may be done whether or not gtm_test_spanreg is 0.
	namePrefix := "abcdefgh"
	exclusions := conn.Node("^%sprgdeExcludeGbllist")
	for c := range len(namePrefix) {
		exclusions.Index(string(c) + "ndxarr").Set("")
	}

	// Since "jmaxwait" local variable (in com/imptp.m) is undefined at this point, the caller
	// will invoke "endtp.csh" later to wait for the children to die. Until then, store job waiting
	// parameters into ^%jobwait subscripts (taken from job.m)
	jobIndex := conn.Node("jobindex")        // store list of pids in M local
	jobWait := conn.Node("^%jobwait", jobID) // and job waiting stuff in M global
	jobWait.Index("njobs").Set(jobCount)
	jobWait.Index("jmaxwait").Set(7200)
	jobWait.Index("jdefwait").Set(7200)
	jobWait.Index("jprint").Set(false)
	jobWait.Index("jroutine").Set("impjob_imptp") // routine name
	jobWait.Index("jmjoname").Set("impjob_imptp") // job name
	jobWait.Index("jnoerrchk").Set(false)         // no error check

	if verbose {
		log.Printf("Settings:\n%#v", conn.Node(settingsRoot))
	}

	// Start jobs
	if parentischild {
		jobWait.Index(1).Set(os.Getpid())
		jobIndex.Index(1).Set(os.Getpid())
		M.Call("writecrashfileifneeded")
		log.Printf("Starting 1 child jobs in the parent process")
		child(1)
		return
	}
	for child := 1; child <= jobCount; child++ {
		log.Printf("Spawning job %d\n", child)
		p := spawn(jobID, child)
		jobWait.Index(child).Set(p.Process.Pid)
		jobIndex.Index(child).Set(p.Process.Pid)
		// avoid interleaved settings printouts from child jobs to terminal
		if verbose {
			time.Sleep(100 * time.Millisecond)
		}
	}

	M.Call("writecrashfileifneeded")
	// No need to run writejobinfofileifneeded^job in Go version as online rollback is disabled in main()

	// Wait up to timeout until the first update in any region happens
	// This large timeout has been used because, when multiple encrypted databases are used,
	// GnuPG takes a long time to open all the regions (typically 0.5s x regions x processes).
	// For example, test gtm8086 opens 4 regions x 20 imptpgo2 jobs so takes about 40s.
	// See this discussion of the issue: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2480#note_3031241642
	log.Printf("Waiting for first update from any job")
	timeout := 300 * time.Second
	start := time.Now()
	for countLoop.GetInt() == 0 {
		if time.Now().Sub(start) >= timeout {
			fmt.Printf("TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions in %.0f seconds!\n", time.Now().Sub(start).Seconds())
			break
		}
		time.Sleep(1 * time.Second)
	}
	jobsNode := settings.Child("totaljob")
	log.Printf("Waiting for all %d jobs to have done an update", jobsNode.GetInt())
	timeout = 600 * time.Second
	for started.Get() != jobsNode.Get() {
		if time.Now().Sub(start) >= timeout {
			fmt.Printf("TEST-E-imptpgo_v2 time out for jobs to start and sync after %.0f seconds\n", time.Now().Sub(start).Seconds())
			break
		}
		time.Sleep(1 * time.Second)
	}
	log.Printf("Started %d jobs and leaving them running in the background", jobsNode.GetInt())
	// No need to run writeinfofileifneeded^imptp here for online rollback, which is disabled in main()
	fmt.Println("End   Time of parent:", time.Now().Format("02-Jan-2006 03:04:05.000"))
}

// loadParameters loads parameters from environment variables and stores them into the database
// jobCount, fillID, jobID are the associated values read from environment variables
func loadParameters(conn *yottadb.Conn) (settings *yottadb.Node, jobCount, fillID, jobID int) {
	// Start from clean database if --clean specified
	if clean {
		for _, name := range cleanups {
			conn.Node(name).Kill()
		}
	} else {
		log.Printf("Attempting to continue previous run")
	}
	// Fetch input parameters from environment variables
	jobCount = envInt("gtm_test_jobcnt", 5) // default 5
	if flag.NArg() > 0 {                    // jobcnt may be overridden on the command line
		jobCount, _ = strconv.Atoi(flag.Arg(0))
		if parentischild {
			jobCount = 1 // force jobs to 1 in this case
		}
		if jobCount == 0 {
			log.Panic("First command line argument, if provided, must be a non-zero integer number of jobs to start")
		}
		log.Printf("JobCount=%d", jobCount)
	}
	fillID = envInt("gtm_test_dbfillid", 0) // default 0
	jobID = envInt("gtm_test_jobid", 0)     // default 0

	conn.Node(settingsRoot, "fillid", jobID).Set(fillID)
	settings = conn.Node(settingsRoot, fillID)

	settings.Index("tptype").Set(envString("gtm_test_tptype", "BATCH")) // default BATCH
	settings.Index("crash").Set(envInt("gtm_test_crash", 0))            // default to not crash mode
	settings.Index("gtcm").Set(envInt("gtm_test_is_gtcm", 0))           // default to not using client-server mode
	settings.Index("skipreg").Set(envInt("gtm_test_repl_norepl", 0))    // default to skip dbfill for 0 regions

	// Default isTP to non-transaction mode
	if os.Getenv("gtm_test_dbfill") == "IMPZTP" {
		panic("Tried to simulate ZTP in database fill using YottaDB Wrapper - not supported")
	}
	isTP := os.Getenv("gtm_test_tp") != "NON_TP"
	settings.Index("istp").Set(isTP)
	if isTP {
		fmt.Println("It is TP")
	}

	// If using transactions, default tpNoIso to repress variable isolation 50% of the time or if gtm_test_noisolation == TPNOISO
	tpNoIso := isTP && (os.Getenv("gtm_test_noisolation") == "TPNOISO" || rand.Intn(2) == 1)
	settings.Index("tpnoiso").Set(tpNoIso)

	// Default dupset to turn on/off optimization for redundant sets 50% of the time
	if settings.Index("dupset").HasNone() {
		settings.Index("dupset").Set(rand.Intn(2))
	}

	// Print input parameters
	log.Printf("jobcnt = %d\n", jobCount)
	log.Printf("$zroutines = %s\n", conn.Node("$zroutines").Get())
	log.Printf("PID = %d (0x%x)\n", os.Getpid(), os.Getpid())

	// Also set some M locals because they are used by M code called by call-ins,
	// including triggers set up by jobs and when jobs invoke imptp.m.
	// These should really be passed as parameters to M routines, had they been designed well.
	// But I have not fixed the M code to do this because it is also used by other C API tests.
	conn.Node("jobcnt").Set(jobCount)
	conn.Node("fillid").Set(fillID)
	conn.Node("jobid").Set(jobID) // Must be set in case job.m is called
	conn.Node("istp").Set(isTP)

	// Get certain database meta-info (e.g. key and record size from DSE) into settings(fillID, *)
	M.Call("getdatinfo", settings.String())
	settings.Index("gtm_test_spannode").Set(envInt("gtm_test_spannode", 0))
	settings.Index("trigger").Set(0) // disable triggers

	jobsNode := settings.Child("totaljob")
	if jobsNode.HasNone() {
		jobsNode.Set(jobCount)
	} else {
		if jobsNode.GetInt() != jobCount {
			log.Panicf("IMPTP-E-MISMATCH: Job number mismatch : %s = %d but jobCount = %d\n%#v", jobsNode, jobsNode.GetInt(), jobCount, conn.Node(settingsRoot))
		}
	}
	return
}

func spawn(jobID, child int) *exec.Cmd {
	executable, err := os.Executable()
	if err != nil {
		log.Panicf("Could not determine program's executable for re-spawn: %s", err)
	}
	args := append([]string{fmt.Sprintf("--worker=%d", child)}, os.Args[1:len(os.Args)]...)
	p := exec.Command(executable, args...)
	// Logs: we have the command we want to fork off but setup its stdout/stderr to go directly to output files.
	// Use the same naming scheme as imptp.m because it is easier for the test system.
	stdout, err := os.Create(fmt.Sprintf("impjob_imptp%d.mjo%d", jobID, child))
	if err != nil {
		panic(err)
	}
	defer stdout.Close()
	p.Stdout = stdout
	stderr, err := os.Create(fmt.Sprintf("impjob_imptp%d.mje%d", jobID, child))
	if err != nil {
		panic(err)
	}
	defer stderr.Close()
	p.Stderr = stderr
	// Start process running
	err = p.Start()
	if err != nil {
		panic(err)
	}
	return p
}

// atoi returns the integer value of string or panics on error, but empty string is returned as zero.
func atoi(s string) int {
	if s == "" {
		return 0
	}
	n, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return int(n)
}

// child runs a single worker process using jobNo specified by --worker option.
func child(jobNo int) {
	conn := yottadb.NewConn()
	M = conn.MustImport(callin_table)

	// Invert the default for gtm_badchar to "no" since jobs die otherwise
	xecute := M.Wrap("xecute")
	if os.Getenv("gtm_badchar") == "" && os.Getenv("ydb_badchar") == "" {
		xecute(`VIEW "NOBADCHAR"`)
	}

	jobID := envInt("gtm_test_jobid", 0) // default 0
	conn.Node("jobindex").Set(jobNo)

	// defer cleanup code to exit gracefully on no error and on ydberr.CALLINAFTERXIT errors
	defer func() {
		err := recover()
		code := yottadb.ErrorCode(err)
		switch {
		case err == nil || code == ydberr.CALLINAFTERXIT:
			fmt.Printf("End index:%d\n", conn.Node("loop").GetInt())
			fmt.Println("Job completion successful")
			fmt.Println("End Time :", time.Now().Format("02-Jan-2006 03:04:05.000"))
			return
		case err != nil:
			fmt.Println(err) // send to stdout as well
		}
		panic(err) // send to stderr
	}()

	// 5% of the time complete this imptp worker process by doing a callin to M code; otherwise do it (primarily) in Go.
	if rand.Intn(20) == 0 {
		log.Println("impjob; Elected to do M call-in to impjob^imptp for this process")
		M.Call("impjob")
		return
	}

	log.Println("Start Time:", time.Now().Format("02-Jan-2006 03:04:05.000"))
	log.Printf("$zroutines = %s\n", conn.Node("$zroutines").Get())

	// Set M local "jobno" because it is used later by triggers.
	// Not using os.Getpid() for jobNo makes imptp resumable after a crash
	conn.Node("jobno").Set(jobNo)

	// Fetch the settings stored by parent process
	fillID := conn.Node(settingsRoot, "fillid", jobID).GetInt()
	settings := conn.Node(settingsRoot, fillID)
	jobCount := settings.Index("totaljob").GetInt()
	prime := settings.Index("prime").GetInt()
	root := settings.Index("root").GetInt()
	top := settings.Index("top").GetInt(prime / jobCount)
	isTP := settings.Index("istp").GetBool()
	tpType := settings.Index("tptype").Get("BATCH")
	tpNoIso := settings.Index("tpnoiso").GetBool()
	dupset := settings.Index("dupset").GetBool()
	skipreg := settings.Index("skipreg").GetBool()
	crash := settings.Index("crash").GetBool()
	gtcm := settings.Index("gtcm").GetBool()
	started := settings.Child("jsyncnt") // number of started processes
	// Also set some M locals because they are used by M code called by call-ins,
	// including triggers set up by jobs and when jobs randomly invoke imptp.m as the job.
	// These should really be passed as parameters to M routines, had they been designed well.
	// But I have not fixed the M code to do this because it is also used by other C API tests.
	conn.Node("crash").Set(crash)
	conn.Node("jobcnt").Set(jobCount)
	conn.Node("fillid").Set(fillID)
	conn.Node("jobid").Set(jobID) // set just in case: I don't think it's necessary for children
	conn.Node("istp").Set(isTP)
	conn.Node("tptype").Set(tpType)

	// At this point imptp.m has a section that supports online rollback, however this does
	// not need to be migrated to Go since the C API doesn't support online rollback.
	conn.Node("orlbkintp").Set(false) // turn off online rollback

	// Node Spanning Blocks
	keySize := settings.Index("key_size").GetInt()
	recordSize := settings.Index("record_size").GetInt()
	span := settings.Index("gtm_test_spannode").GetInt()
	// Set matching M locals
	conn.Node("keysize").Set(keySize)
	conn.Node("recsize").Set(recordSize)
	conn.Node("span").Set(span)

	// Triggers -- MUST be the last update to ^%imptp during setup.
	// Online Rollback tests use this as a marker to detect when ^%imptp has been rolled back.
	trigger := settings.Index("trigger").GetInt()
	conn.Node("trigger").Set(trigger)
	zTriggerCommand := "ztrigger ^lasti(fillid,jobno,loop)"
	conn.Node("ztrcmd").Set(zTriggerCommand)
	ztriggerCommand, ztriggerFunction := false, false // whether to test ZTRIGGER command and $ZTRIGGER() function
	triggerName := "triggernameforinsertsanddels"
	fullTrigger := `^unusedbyothersdummytrigger -commands=S -xecute="do ^nothing" -name=` + triggerName
	if trigger != 0 {
		if trigger%10 > 1 {
			ztriggerCommand = true
		} // test ZTRIGGER command
		if trigger > 10 {
			ztriggerFunction = true
		} // test $ZTRIGGER() function
	}
	conn.Node("dztrig").Set(ztriggerFunction) // whether to test $ZTRIGGER(); used by helper1/3

	// Print status
	log.Printf("jobno=%d\n", jobNo)
	log.Printf("istp=%v\n", isTP)
	log.Printf("tptype=%s\n", tpType)
	log.Printf("tpnoiso=%v\n", tpNoIso)
	log.Printf("orlbkintp=0\n")
	log.Printf("dupset=%v\n", dupset)
	log.Printf("skipreg=%v\n", skipreg)
	log.Printf("crash=%v\n", crash)
	log.Printf("gtcm=%v\n", gtcm)
	log.Printf("fillid=%d\n", fillID)
	log.Printf("keysize=%d\n", keySize)
	log.Printf("recsize=%d\n", recordSize)
	log.Printf("trigger=%d\n", trigger)
	log.Printf("PID: %d (0x%x)\n", os.Getpid(), os.Getpid())

	// Tell parent we've started
	// This could be done atomically with simply started.Incr() but we want to test the
	// SimpleAPI/SimpleThreadAPI lock functions and so have them here just like the M version of imptp.
	started.Lock()
	started.Set(started.GetInt() + 1)
	started.Unlock()

	// lastfence is the fence type of the last segment of updates of *ndxarr at the end.
	// For non-tp and crash test meaningful application checking is very difficult,
	// so at the end of the iteration a TP transaction is used.
	// For gtcm we cannot use TP at all, because it is not supported,
	// so we cannot do crash test for gtcm.
	lastFence := (isTP || crash) && !gtcm
	conn.Node("lfence").Set(lastFence)

	if tpNoIso {
		M.Call("tpnoiso")
	}
	if dupset {
		xecute(`VIEW "GVDUPSETNOOP":1`)
	}

	// imptp.m handles online rollback here, but Go version doesn't need to as versions via C API do not support online rollback

	// Program can be restarted at the saved value of lasti
	lastiNode := conn.Node("^lasti", fillID, jobNo)
	lasti := lastiNode.GetInt(0)
	log.Printf("lasti=%d\n", lasti)

	// To understand the following, see section "Pseudo-random index generator" in the comments at the top.
	//
	// Calculate I = root^jobNo, but keep it within the range 0 to prime-1.
	// Then make nroot the very next in the sequence after all jobs are given a starting I.
	// For example If root==5 and jobcnt==5 then the sequence would be
	//	Job 1: I=root^0 = 1
	//	Job 2: I=root^1 = 5
	//	Job 3: I=root^2 = 25
	//	Job 4: I=root^3 = 125
	//	Job 5: I=root^4 = 625
	//	nroot = root^5 = 3125 (all jobs have the same value of nroot)
	//   5 25 125 625 3125 => final nroot = 3125
	// This sequence matches (root^n) until it reaches prime; then it goes haywire (essentially a random number generator).
	// But for values of jobCount below 11, nroot ends up being equal to root^jobCount
	nroot := 1
	for range jobCount {
		nroot = int(int64(nroot) * int64(root) % int64(prime))
	}
	I := 1
	for range jobNo-1 {
		I = int(int64(I) * int64(root) % int64(prime))
	}

	// If lasti>0 then we're recovering from a previous crashed run, so run a loop of lasti iterations to increment I back
	// to what it was using the same formula as used in the job's main loop.
	//
	// After the initialization above, calculate each next I in the sequence using nroot instead of root as the
	// multiplier so the numbers of I generated by jobs never overlap other jobs (or wouldn't if we didn't do %prime)
	// To be honest, I don't think this is any better than a simple pseudo-random number sequence
	// generator without worrying about job overlap at all. I don't know why the designer chose this.
	// Note the change of multiplier root (above) to nroot (below).
	// For example, say, w is the primitive root and we have 5 jobs:
	// Job 1: Sets index I = root^0, root^5, root^10 etc. (increment power by jobCount each I)
	// Job 2: Sets index I = root^1, root^6, root^11 etc.
	// Job 3: Sets index I = root^2, root^7, root^12 etc.
	// Job 4: Sets index I = root^3, root^8, root^13 etc.
	// Job 5: Sets index I = root^4, root^9, root^14 etc.
	// The above is achieved by multiplying I by nroot which =root^5 because there are 5 jobs
	for range lasti {
		I = int(int64(I) * int64(nroot) % int64(prime))
	}
	log.Printf("Starting index:%d\n\n", lasti+1)

	// Define Node instances that point to M locals used by M code called in the main loop at the end of this function
	INode := conn.Node("I")
	loopNode := conn.Node("loop")
	subsNode := conn.Node("subs")
	subsMaxNode := conn.Node("subsMAX")
	valNode := conn.Node("val")
	valAltNode := conn.Node("valALT")
	valMaxNode := conn.Node("valMAX")

	// Define Node instances that point to M globals used by M code called in the inner loop and its stage functions below
	endloop := conn.Node("^endloop", fillID)
	varA := conn.Node("^arandom", fillID)
	varB := conn.Node("^brandomv", fillID)
	varC := conn.Node("^crandomva", fillID)
	varD := conn.Node("^drandomvariable", fillID)
	varE := conn.Node("^erandomvariableimptp", fillID)
	varF := conn.Node("^frandomvariableinimptp", fillID)
	varG := conn.Node("^grandomvariableinimptpfill", fillID)
	varH := conn.Node("^hrandomvariableinimptpfilling", fillID)
	varI := conn.Node("^irandomvariableinimptpfillprgrm", fillID)
	varJ := conn.Node("^jrandomvariableinimptpfillprogr", fillID)
	antp := conn.Node("^antp", fillID)
	bntp := conn.Node("^bntp", fillID)
	cntp := conn.Node("^cntp", fillID)
	dntp := conn.Node("^dntp", fillID)
	entp := conn.Node("^entp", fillID)
	fntp := conn.Node("^fntp", fillID)
	gntp := conn.Node("^gntp", fillID)
	hntp := conn.Node("^hntp", fillID)
	intp := conn.Node("^intp", fillID)

	// Define stage1() and stage3() functions here inside this closure so they can access Go locals
	// The main loop of child() is after these definitions

	stage1 := func() {
		trestart := conn.Node("$TRESTART").GetInt()

		// Fetch M locals that may have been changed by previous M calls into Go locals
		I = INode.GetInt()
		subscript := subsNode.Get()
		subscriptMax := subsMaxNode.Get() // maximally-padded version of subscript (set up earlier by helper1)
		val := valNode.Get()
		valAlt := valAltNode.Get()

		varA.Index(subscriptMax).Set(val)
		if isTP && crash {
			random := rand.Intn(10)
			switch {
			case random == 1 && trestart > 2:
				// Thrash memory while randomly holding crit for a randomly long time
				M.Call("noop")
			case random == 2 && trestart > 2:
				// Hold crit for a randomly long time
				time.Sleep(time.Duration(rand.Intn(10)) * time.Second)
			case trestart > 0:
				// In case of restart cause different TP transaction flow
				conn.Node("^zdummy", trestart).Set(jobNo)
			}
		}

		varB.Index(subscriptMax).Set(valAlt)
		if trigger == 0 {
			varC.Index(subscriptMax).Set(valAlt)
		}
		varD.Index(subscript).Set(valAlt)
		if trigger == 0 {
			varE.Index(subscript).Set(valAlt)
			varF.Index(subscript).Set(valAlt)
		}
		varG.Index(subscript).Set(val)
		if trigger == 0 {
			varH.Index(subscript).Set(val)
			varI.Index(subscript).Set(val)
		} else {
			// I'm not sure why this isn't implemented in Go, but I'm just copying what imptpgo v1 did.
			M.Call("ztwormstr")
		}
		varJ.Index(I).Set(val)
		if trigger == 0 {
			varJ.Index(I, I).Set(val)
			varJ.Index(I, I, subscript).Set(val)
		}
		if isTP {
			if ztriggerFunction {
				xecute(zTriggerCommand)
			}
			// Update lastiNode in the database in case we bomb out and have to continue from where we left off
			// And also because checkdb.m uses it to check database results
			lastiNode.Set(loopNode.GetInt())
		}
	}

	stage2 := func() {
		// Calling M `helper2` is an alternative to the Go code below (up to "subscript :=")
		// but it doesn't test triggers in Go via M call-in
		// This condition is hard-coded but left in place for comparison by developers
		useHelper2 := false
		if useHelper2 {
			conn.Node("trigname").Set(triggerName) // used by helper2
			conn.Node("fulltrig").Set(fullTrigger) // used by helper2
			M.Call("helper2")
		} else {
			// $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
			var trig string
			if rand.Intn(10) < 5 && conn.Node("$tlevel").GetInt() == 0 && trigger != 0 {
				switch rand.Intn(10) {
				case 0:
					trig = "-" + fullTrigger
				case 1:
					trig = "-" + triggerName
				default:
					trig = "+" + fullTrigger
				}
				// Note: if you do not use Str2Zwr() below, any double quotes cause this error:
				//   %YDB-E-RPARENMISSING, Right parenthesis expected
				// when executing: set ztrigret=$ztrigger("item","+^unusedbyothersdummytrigger -commands=S -xecute="do ^nothing" -name=triggernameforinsertsanddels")
				ztrig, _ := conn.Str2Zwr(trig)
				command := fmt.Sprintf(`set ztrigret=$ztrigger("item",%s)`, ztrig)
				xecute(command)

				// Handle errors but ignore error from deleting a non-existent trigger
				ztrigret := conn.Node("ztrigret").GetBool() || trig == "-"+triggerName
				if !ztrigret { // Show error
					xecute(`ZSHOW "*"`) // dump dbase info to help debug cause of trigger failure
					// Note: this depends on fetching $zstatus which only works since we're not using multiple Goroutines.
					if strings.Contains(conn.Node("$zstatus").Get(), "TRIGDEFBAD") {
						// Tell all jobs to end
						for node := range conn.Node("^endloop").Children() {
							node.Set(true)
						}
					}
					// No need to conn.Rollback() on error (per ERROR^imptp) since stage2 doesn't use transactions
				}
			}
		}
		subscript := subsNode.Get()
		val := valNode.Get()
		valAlt := valAltNode.Get()
		antp.Index(subscript).Set(val)
		if trigger == 0 {
			bntp.Index(subscript).Set(val)
			cntp.Index(subscript).Set(val)
		}
		dntp.Index(subscript).Set(valAlt)
	}

	stage3 := func() {
		valMax := valMaxNode.Get()
		subscript := subsNode.Get()
		subscriptMax := subsMaxNode.Get() // maximally-padded version of subscript (set up earlier by helper1)
		if ztriggerCommand {
			M.Call("imptpdztrig")
		}
		val := valNode.Get()
		entp.Index(subscript).Set(val)
		if trigger == 0 {
			fntp.Index(subscript).Set(val)
		} else {
			fVal := fntp.Index(subscript).Get()
			fVal = fVal[0:max(0, len(fVal)-len("suffix"))] // Remove up to len("suffix") chars off the end of the fVal string
			fntp.Index(subscript).Set(fVal)
		}
		gntp.Index(subscriptMax).Set(valMax)
		if trigger == 0 {
			hntp.Index(subscriptMax).Set(valMax)
			intp.Index(subscriptMax).Set(valMax)
			bntp.Index(subscriptMax).Set(valMax)
		}
	}

	// Child's main loop
	// Note: for trigger activation sequence see comment at the end of imptp.trg
	for loop := lasti + 1; loop <= top && !endloop.GetBool(); loop++ {
		// Set M locals 'I' and 'loop' (needed by "helper1" call-in code)
		INode.Set(I)
		loopNode.Set(loop)
		M.Call("helper1")

		// Stage 1
		if isTP {
			conn.Transaction(tpType, []string{"*"}, stage1)
		} else {
			stage1()
		}

		// Stage 2
		stage2()

		// Stage 3
		if isTP {
			conn.Transaction(tpType, nil, stage3)
		} else {
			stage3()
		}

		// Stages 4-11
		M.Call("helper3")
		// See comments on the following calculation in the initialization section above
		I = int(int64(I) * int64(nroot) % int64(prime))
	}
	log.Printf("Job %d finished", jobNo)
}

// envInt returns the contents of environment variable env as an integer or panics on error.
// If the environment variable represented by env is unset or contains the empty string, return default.
func envInt(env string, default_ int) int {
	s := os.Getenv(env)
	if s == "" {
		return default_
	}
	return atoi(s)
}

// envString returns the contents of environment variable env as an integer or panics on error.
// If the environment variable represented by env is unset or contains the empty string, return default.
func envString(env string, default_ string) string {
	s := os.Getenv(env)
	if s == "" {
		return default_
	}
	return s
}
