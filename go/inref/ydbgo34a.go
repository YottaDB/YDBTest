//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries. //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
// Test the yottadb.RegisterSignalNotify() function for various signals.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
	"os"
	"runtime"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
)

const MaximumSignalWait int = 15     // Maximum seconds to wait for our signal to be processed (should be more or less instant)
const MAXGORTNS int = 4              // Number of worker goroutines to start
const tptoken uint64 = yottadb.NOTTP // No TP in this test currently
const debug bool = false             // Debugging indicator (turns on more messages)

// List of signal types and names (for output). Note this list needs to be kept in sync with the list of signals at the end of
// ydbgo34.m. Note the flag in this structure (type YDBHandlerFlag) is chosen based on whether the signal is a
// fatal signal or not. This makes sure all Fatal signals are handled BEFORE the YottaDB handler is called (or NEVER). Otherwise,
// the YottaDB handler will likely tear the process down and the user handler would never run. This is also why this field is
// not randomized itself.
//
// A note on the sigWhen value - right now NotifyBeforeYDBSigHandler causes problems by exiting early with os.Exi()t so we only
// have the one signal with that handling value (SIGHUP) at this time (and with the os.Exit() call commented out). Note there had
// been a suggestion to randomize the value of sigWhen but that's not possible. The fatal signals especially only work with the
// NotifyInsteadOfYDBSigHnalder flag right now as we MUST prevent the YDB handler from running with these signals because that code
// does not work correctly as described in YDB#790 [TODO].
var sigTypes = [12]struct {
	sigId   syscall.Signal
	sigName string
	sigWhen yottadb.YDBHandlerFlag
}{
	{syscall.SIGABRT, "SIGABRT", yottadb.NotifyInsteadOfYDBSigHandler},
	// {syscall.SIGALRM, "SIGALRM", yottadb.NotifyAfterYDBSigHandler}, // not testing since it occurs naturally during test
	{syscall.SIGBUS, "SIGBUS", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGCONT, "SIGCONT", yottadb.NotifyAsyncYDBSigHandler},
	{syscall.SIGFPE, "SIGFPE", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGHUP, "SIGHUP", yottadb.NotifyBeforeYDBSigHandler}, // Treated mostly same as ^C but only if ydb_hupenable=1
	{syscall.SIGILL, "SIGILL", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGINT, "SIGINT", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGQUIT, "SIGQUIT", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGSEGV, "SIGSEGV", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGTERM, "SIGTERM", yottadb.NotifyInsteadOfYDBSigHandler},
	{syscall.SIGTRAP, "SIGTRAP", yottadb.NotifyInsteadOfYDBSigHandler},
	// {syscall.SIGURG, "SIGURG", yottadb.NotifyAfterYDBSigHandler}, // same as SIGIO - occurs constantly so not testing
	{syscall.SIGUSR1, "SIGUSR1", yottadb.NotifyAfterYDBSigHandler},
}

// List of global names incremented by the various worker tasks
var gblNames = []string{"^a", "^b", "^y", "^z"}

// Wait group so we know when all goroutines are started or finished and when the signal is received/processed
var wgWorker, wgWorkerStartup sync.WaitGroup

// Global value used to indicate it is time to shut down
var allDone uint32

// Given that a handful of valid errors codes are possible, this function returns true if we hit a valid error code and should
// "restart". For TP, this means returning from the TP callback and letting the engine call it again. For non-TP, it means we
// caught a CALLINAFTEREXIT error which is possible if the C managed thread that detected a fatal condition shutsdown YDB but
// another thread running a goroutine doesn't know it yet and tries a call. If a thread gets a CALLINAFTEREXIT in the normal
// course of things it either a programming error - where a call has been made after intentionally shutting down YDB by
// driving yottadb.Exit() or it is unintentional with YDB shutting the process down but some goroutines not yet aware of it.
//
// Any other error types are problems that we can't reasonably recover from without knowledge of the calling application.
// Customize this to your needs, paying special attention to cases where more than one valid error code could happen (i.e.,
// a NODEEND inside a TP callback)
//
// Note the action taken if this routine returns true is currently just "return" because for the errors possible in each
// section
//
// This is a standard suggested base error checker for return codes from calls to the YottaDB wrapper that return errors.
func checkErrorReturn(err error) bool {
	if err == nil {
		return false
	}
	if ydb_err, ok := err.(*yottadb.YDBError); ok {
		switch yottadb.ErrorCode(ydb_err) {
		case yottadb.YDB_TP_RESTART:
			// If an appplication uses transactions, TP_RESTART must be handled inside the transaction callback;
			// it is here. For completeness, but ensure that one modifies this routine as needed, or copies bits
			// from it. A transaction must be restarted; this can happen if some other process modifies a value
			// we read before we commit the transaction.
			return true
		case yottadb.YDB_TP_ROLLBACK:
			// If an appplication uses transactions, TP_ROLLBACK must be handled inside the transaction callback;
			// it is here for completeness, but ensure that one modifies this routine as needed, or copies bits
			// from it. The transaction should be aborted; this can happen if a subtransaction return YDB_TP_ROLLBACK
			// This return will be a bit more situational.
			return true
		case yottadb.YDB_ERR_CALLINAFTERXIT:
			// The database engines was told to close, yet we tried to perform an operation. Either reopen the
			// database, or exit the program. Since the behavior of this depends on how your program should behave,
			// it is commented out so that a panic is raised.
			return true
		case yottadb.YDB_ERR_NODEEND:
			// This should be detected seperately, and handled by the looping function; calling a more generic error
			// checker should be done to check for other errors that can be encountered
			panic("checkErrorReturn: YDB_ERR_NODEEND encountered; this should be handled before in the code local to the subscript/node function")
		default:
			_, file, line, ok := runtime.Caller(1)
			if ok {
				panic(fmt.Sprintf("checkErrorReturn: Assertion failure in %v at line %v with error (%d): %v", file, line,
					yottadb.ErrorCode(err), err))
			} else {
				panic(fmt.Sprintf("checkErrorReturn: Assertion failure (%d): %v", yottadb.ErrorCode(err), err))
			}
		}
	} else {
		panic(err)
	}
}

// Routine to increment the value of a certain global given the index to its name. Used as one of a number of "worker bee"
// goroutine.
func workerBee(gblIndx int) {
	var errStr yottadb.BufferT
	var err error

	defer wgWorker.Done()
	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	//defer func() {
	//	if r := recover(); nil != r {
	//		// We've caught a panic - send verbage then exit
	//		fmt.Printf("workerBee: Caught panic for error index (%d): %s\n", gblIndx, r)
	//		atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
	//		yottadb.Exit()
	//		os.Exit(1)
	//	}
	//}() Remove until YDB#790 is committed [TODO]
	//
	// Run a quickie YottaDB Go Wrapper call so we initialize YDB (the first one to start will need to) but we'd like
	// to make sure that initialization is complete before we start our timer or acknowledge that we are "running".
	_, err = yottadb.DataE(tptoken, &errStr, "^A", []string{})
	if nil != err { // Check for expected potential errors that mean we need to return
		if !checkErrorReturn(err) {
			fmt.Printf("workerBee-DataE(%d)A: Stopping due to error - %v\n", gblIndx, err)
		}
		atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
		wgWorkerStartup.Done()          // Main need no longer wait for us
		return
	}
	wgWorkerStartup.Done() // Tell main we are running!
	// Set a timer that will shut our loop down after 30 seconds whether it has been told to shutdown or not
	go func() {
		time.Sleep(30 * time.Second)    // Loop runs for a max of 30 seconds
		atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
	}()
	// Start up a processing loop
	ourGbl := gblNames[gblIndx-1] // This is the global we will be incrementing as fast as we are able to
	for 0 == atomic.LoadUint32(&allDone) {
		// Do our update under a TP fence
		err = yottadb.TpE(tptoken, &errStr, func(tptoken uint64, errPtr *yottadb.BufferT) int32 {
			var errStrInner yottadb.BufferT

			defer errStrInner.Free()
			errStrInner.Alloc(yottadb.YDB_MAX_ERRORMSG)
			_, err = yottadb.IncrE(tptoken, &errStrInner, "1", ourGbl, []string{})
			if nil != err { // Check for expected potential errors that mean we need to return
				if !checkErrorReturn(err) {
					fmt.Printf("workerBee-IncrE(%d)A: Stopping due to error - %v\n", gblIndx, err)
				}
				atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
				return int32(yottadb.ErrorCode(err))
			}
			return yottadb.YDB_OK
		}, "", []string{})
		if nil != err {
			if !checkErrorReturn(err) {
				fmt.Printf("workerBee-IncrE(%d)B: Stopping due to error - %v\n", gblIndx, err)
			}
			atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
			break
		}
	}
}

func main() {
	var errStr yottadb.BufferT

	defer yottadb.Exit()
	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	// Create channels we use for notification/acknowledgement for our two handlers (expected and unexpected)
	correctSigNotify := make(chan bool, 2)
	correctSigAck := make(chan bool, 2)
	incorrectSigNotify := make(chan bool, 2)
	incorrectSigAck := make(chan bool, 2)
	// Verify we have (at least) as many gblNames as we do worker processes
	if MAXGORTNS > len(gblNames) {
		fmt.Printf("main: Number of workers (%d) exceeds length of gblNames array (%d) - terminating\n", MAXGORTNS,
			len(gblNames))
		os.Exit(1)
	}
	// Initialize random number generator seed
	rand.Seed(time.Now().UnixNano())
	// Get index to which signal we'll be using
	sigIndx := rand.Intn(len(sigTypes))
	// Write our chosen signal number out to a file so our script can get to it
	sig := sigTypes[sigIndx].sigId
	fd, err := os.Create("ydbgo34.signum")
	if nil != err {
		panic(err)
	}
	_, err = fd.WriteString(fmt.Sprintf("%d\n", sig))
	if nil != err {
		panic(err)
	}
	fd.Close()
	// Notify of the signal we chose for this run
	fmt.Printf("main: Chosen signal this run: %s\n", sigTypes[sigIndx].sigName)
	// Set the signal we want to have the CORRECT notify
	err = yottadb.RegisterSignalNotify(sigTypes[sigIndx].sigId, correctSigNotify, correctSigAck, sigTypes[sigIndx].sigWhen)
	if checkErrorReturn(err) {
		fmt.Println("main: Failed in RegisterSignalNotify() call for our chosen signal", sigTypes[sigIndx].sigId, ":", err)
		return
	}
	// Set all other signals to have the INCORRECT notify
	for _, v := range sigTypes {
		if v.sigId == sigTypes[sigIndx].sigId {
			continue
		}
		err = yottadb.RegisterSignalNotify(v.sigId, incorrectSigNotify, incorrectSigAck, v.sigWhen)
		if checkErrorReturn(err) {
			fmt.Println("main: Failed in RegisterSignalNotify() call for a not-chosen signal", sigTypes[sigIndx].sigId,
				":", err)
			return
		}
	}
	// Set up a panic catcher
	//defer func() {
	//	if r := recover(); nil != r {
	//		// We've caught a panic - send verbage then exit
	//		fmt.Println("main: Caught panic for error:", r)
	//		yottadb.Exit()
	//		os.Exit(1)
	//	}
	//}()  Uncomment the above section when YDB#790 is complete [TODO]
	fmt.Println("main: Starting goroutines to be doing busy-work when signal comes in")
	// Start up a few goroutines that will be doing some work when the signal comes in
	for i := 1; i <= MAXGORTNS; i++ {
		wgWorkerStartup.Add(1) // Add worker to list we wait for to startup
		wgWorker.Add(1)        // Add this worker to the pending list used to sync exits
		go workerBee(i)
	}
	if debug {
		fmt.Println("Waiting for signal routines to start and indicate they are running")
	}
	wgWorkerStartup.Wait() // Wait for all workers to be up and running
	// Now actually send the signal
	fmt.Println("main: Sending signal", sigTypes[sigIndx].sigName, "to ourselves")
	syscall.Kill(syscall.Getpid(), sigTypes[sigIndx].sigId)
	if debug {
		fmt.Println("main: Signal sent - Waiting for signal to be received/processed")
	}
	seenSig := false
	select {
	case _ = <-incorrectSigNotify:
		fmt.Println("main: Incorrect signal notify done - unexpected notification")
	case _ = <-correctSigNotify:
		seenSig = true
		fmt.Println("main: Expected notification occurred for our signal")
		// If this is a handler being driven BEFORE the YottaDB handler, flip a coin - if heads, drive yottadb.Exit()
		// and shut things down to bypass fatal panic. If the coin is tails, let the handler proceed.
		if yottadb.NotifyBeforeYDBSigHandler == sigTypes[sigIndx].sigWhen {
			coin := rand.Intn(1) // heads = 1; tails = 0
			// Below is a temporary work-around to prevent this test from failing. If we allow the YottaDB handler to
			// run for a fatal signal (here we just treat them all as fatal for simplicity), YDB will do a callback to
			// YDBWrapperPanic in init.go to drive a panic() but this panic sometimes gets launched in its own context
			// so no defer/recover block can catch it. Once YDB#790 is complete, we can remove this override and let
			// the YottaDB signal handler run randomly and also convert of few of the currently set to "never" let the
			// YDB handler run back to "Before". But for now, we always choose the quick-exit path.
			coin = 0 // [TODO] Remove when YDB#790 is done *** TEMP ***
			if 0 == coin {
				if debug {
					fmt.Println("main: ** Starting yottadb.Exit() call")
				}
				yottadb.Exit()
				// fmt.Println("main: Exiting to avoid fatal panic") // waiting for YDB#790 [TODO]
				if debug {
					fmt.Println("main: ** yottadb.Exit() call has returned")
				}
				// os.Exit(1) Avoid this at this time - no out-of-band exits or risk DB corruption. YDB#790 [TODO]
			} else {
				fmt.Println("main: Allowing potentially fatal handler to run")
			}
		}
		fmt.Println("main: Returning back to interrupt point")
		correctSigAck <- true // Notify signal handling process that our processing is complete
	case <-time.After(time.Duration(MaximumSignalWait) * time.Second):
		fmt.Println("main: Time-out waiting for signal notification - shutting down")
	}
	if debug && seenSig {
		fmt.Println("main: Signal received - shutting down go routines and exiting")
	}
	atomic.StoreUint32(&allDone, 1) // Indicate it is time to shut everything down
	wgWorker.Wait()                 // Wait for any worker not yet complete
	fmt.Println("main: Exiting")
}
