//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries. //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////

package main

import (
	"bufio"
	"fmt"
	"io"
	"lang.yottadb.com/go/yottadb"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"
)

// This is an implementation of 3n+1 in Golang. See "Solving the 3n+1 Problem with YottaDB" at
// https://yottadb.com/solving-the-3n1-problem-with-yottadb/ for details.
// This is the second of two flavors that differ as follows:
// - threeenp1B1 - All of the entry entry points except the two right up top are implemented as closure functions including
//                 the TP callback functions. This allows them to share variables and not have to pass them individually.
//                 This is suitable for small callback functions but not so much for large ones. This routine drives
//                 multiple goroutines as workers.
// - threeenp1B2 - All of the functions are separate functions with the exception of the one line TP callback closure
//                 functions. These functions pass around a large block that contains all the keys, buffers, etc that need
//                 to be referenced by the routines. This allows callback functions to even be in separate files. This
//                 routine drives multiple goroutines as workers.
// - threeenp1C2 - Similar to threeenp1B2 except uses separate processes instead of of goroutines.

// Constant definitions
const tptoken uint64 = yottadb.NOTTP
const debugMode bool = false

// Define structure passed between routines containing KeyT and, BufferT structures plus a statistical field that allows these
// fields to be shared between routines and most importantly shared with TP callback routines. Additional benefit is the keys
// don't need to be recreated for every call.
type shrStuff struct {
	readsGbl, updatesGbl, highestGbl, limitsGbl, stepGbl, resultGbl yottadb.KeyT
	readsLcl, updatesLcl, highestLcl, currpathLcl yottadb.KeyT
	value, value2, errstr yottadb.BufferT
	maxpath int64
}

// Routine to print lines of debugging information if debugging is enabled
func debugPrint(lineText string) {
	if debugMode {
		fmt.Println(lineText)
	}
}

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
// section return is the correct action as described in the comments below. This applies to calls to the yottadb package.
// When the macro is used to check error codes from system services, there is no return as the only reason the check is done
// is to look for panic type errors it handles.
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
			// checker should be done to check for other errors that can be encountered.
			panic("YDB_ERR_NODEEND encountered; this should be handled before in the code local to the subscript/node function")
		default:
			_, file, line, ok := runtime.Caller(1)
			if ok {
				panic(fmt.Sprintf("Assertion failure in %v at line %v with error (%d): %v", file, line,
					yottadb.ErrorCode(err), err))
			} else {
				panic(fmt.Sprintf("Assertion failure (%d): %v", yottadb.ErrorCode(err), err))
			}
		}
	} else {
		panic(err)
	}
}

//
// Main routine threenp1 implements 3n+1 problem.
//
// Find the maximum number of steps for the 3n+1 problem for all integers through an input integer.
// Assumes input is lines of 3 integers separated by a space, of which only the first is required:
//  - the largest number for which the 3n+1 sequence must be computed (>1)
//  - the number of parallel exection streams (defaults to 2× the number of CPUs)
//  - the sizes of blocks of integers on which spawned child processes operate
//    (defaults to approximately the range divided by the number execution streams)
//    If the block size is larger than the range divided by the number of execution streams,
//    it is reduced to that value.
// No input error checking is done.
//
func main() {
	var linetokens []string
	var input  string
	var valstrp *string
	var endnum, streams, maxblk, blk, tmp, tokncnt, updatecnt, readcnt, index int64
	var limitsGbl, resultGbl, highestGbl, updatesGbl, readsGbl, stepGbl yottadb.KeyT
	var value, errstr yottadb.BufferT
	var wgStart, wgEnd, wgInit sync.WaitGroup
	var err error

	debugPrint("Start of main()")
	defer yottadb.Exit()
	// Initialize
	value.Alloc(32)
	errstr.Alloc(2048)
	limitsGbl.Alloc(7, 2, 18) // Only 2 subs but allow full 18 digit value
	err = limitsGbl.Varnm.SetValStrLit(tptoken, &errstr, "^limits")
	if checkErrorReturn(err) { return }
	resultGbl.Alloc(7, 0, 0)
	err = resultGbl.Varnm.SetValStrLit(tptoken, &errstr, "^result")
	if checkErrorReturn(err) { return }
	err = resultGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // Start afresh - kill ^result
	if checkErrorReturn(err) { return }
	highestGbl.Alloc(8, 0, 0)
	err = highestGbl.Varnm.SetValStrLit(tptoken, &errstr, "^highest")
	if checkErrorReturn(err) { return }
	err = highestGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // Start afresh - kill ^highest
	if checkErrorReturn(err) { return }
	updatesGbl.Alloc(8, 0, 0)
	err = updatesGbl.Varnm.SetValStrLit(tptoken, &errstr, "^updates")
	if checkErrorReturn(err) { return }
	err = updatesGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // Start afresh - kill ^updates
	if checkErrorReturn(err) { return }
	readsGbl.Alloc(6, 0, 0)
	err = readsGbl.Varnm.SetValStrLit(tptoken, &errstr, "^reads")
	if checkErrorReturn(err) { return }
	err = readsGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // Start afresh - kill ^reads
	if checkErrorReturn(err) { return }
	stepGbl.Alloc(5, 1, 18)
	err = stepGbl.Varnm.SetValStrLit(tptoken, &errstr, "^step")
	if checkErrorReturn(err) { return }
	err = stepGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // Start afresh - kill ^step
	if checkErrorReturn(err) { return }
	// Get the number of CPUs from /proc/cpuinfo and calculate default number of execution streams
	cpucnt := runtime.NumCPU()
	cpuStreams := 2 * cpucnt // Max of 'streams' concurrent goroutines
	// At the top level, the program reads and processes input lines, one at a time.  Each line specifies
        // one problem to solve.  Since the program is designed to resume after a crash and reuse partial
        // results computed before the crash, data in the database at the beginning is assumed to be partial
        // results from the previous run.  After computing and writing results for a line, the database is
        // cleared for next line of input or next run of the program.
	//
        // Loop for ever, read a line (quit on end of file or an empty line), process that line - Create a reader
	// for stdin.
	readin := bufio.NewReader(os.Stdin)
	for {
		streams = int64(cpuStreams) // Initialize some parms before parm scan
		blk = 0
		endnum = 0
		// Read input from console
		input, err = readin.ReadString('\n')
		if (nil != err) && (io.EOF == err) {
			break
		}
		if checkErrorReturn(err) { return } // Takes care of the rest of the errors
		linetokens = strings.Fields(input)
		tokncnt = int64(len(linetokens))
		if 0 < tokncnt {
			endnum, err = strconv.ParseInt(linetokens[0], 10, 64) // aka 'j' in the M version
			if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
		} else {
			// Blank line ends input
			break
		}
		if 1 < tokncnt {
			streams, err = strconv.ParseInt(linetokens[1], 10, 64) // Resets streams from the default set above
			if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
		}
		if 2 < tokncnt {
			blk, err = strconv.ParseInt(linetokens[2], 10, 64)
			if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
		}
		if 3 < tokncnt {
			fmt.Println("Excess tokens in input line (max 3) - args: <maximum> <streamcnt> <maxnumsperstream>")
			continue
		}
		// Post processing on input args
		fmt.Printf("  %d", endnum)
		fmt.Printf("  %d", streams)
		maxblk = (endnum + (streams - 1)) / streams // Compute count of numbers in each processing block (number range)
		if (0 != blk) && (blk <= maxblk) {
			fmt.Printf("  %d", blk)
		} else {
			fmt.Printf("  (%d", blk)
			blk = maxblk
			fmt.Printf("->%d)", blk)
		}
		// Define blocks of integers for child processes to work on
		err = limitsGbl.Subary.SetElemUsed(tptoken, &errstr, 0) // No subscripts so we kill the entire ^limits global
		if checkErrorReturn(err) { return }
		err = limitsGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE) // kill ^limits (all of it)
		if checkErrorReturn(err) { return }
		tmp = 0
		err = limitsGbl.Subary.SetElemUsed(tptoken, &errstr, 1) // Single subscript
		if checkErrorReturn(err) { return }
		for i := 1; ; i++ {
			if tmp == endnum {
				break
			}
			tmp += blk
			if tmp > endnum {
				tmp = endnum
				err = value.SetValStrLit(tptoken, &errstr, fmt.Sprintf("%d", tmp))
				if checkErrorReturn(err) { return }
				err = limitsGbl.SetValST(tptoken, &errstr, &value)
				if checkErrorReturn(err) { return }
				break
			}
			err = limitsGbl.Subary.SetValStrLit(tptoken, &errstr, 0, fmt.Sprintf("%d", i)) // ^limits(i)
			if checkErrorReturn(err) { return }
			err = value.SetValStrLit(tptoken, &errstr, fmt.Sprintf("%d", tmp))
			if checkErrorReturn(err) { return }
			err = limitsGbl.SetValST(tptoken, &errstr, &value)
			if checkErrorReturn(err) { return }
		}
		// Launch goroutines.  The M and C versions use M locks for synchronization but in this golang version,
		// we use a Waitgroup. All the synchronization is here. None is needed in the doblk and other routines.
		// Note start this loop at 0 since index is incremented first thing in doblk().
		debugPrint("\nLaunching goroutines for this run")
		wgStart.Add(1) // Initial value all started goroutines will wait for
		for index = 0; index < streams; index++ {
			wgInit.Add(1) // Add one for each goroutine so we know when they are initialized
			wgEnd.Add(1) // Add one for each goroutine so we know when they are finished
			go func(indexlcl int64) { // Goroutine code
				debugPrint(fmt.Sprintf("Initiate goroutine # %d - awaiting release", indexlcl))
				wgInit.Done() // This goroutine is now up and running
				wgStart.Wait() // Wait till main tells us to start
				doblk(indexlcl) // The meat of this goroutine
				wgEnd.Done() // Signal this goroutine is complete
			}(index)
		}
		debugPrint(fmt.Sprintf("All %d goroutines launched - wait till they are all initialized", streams))
		wgInit.Wait()
		debugPrint("All goroutines initialized - release them to start running")
		wgStart.Done() // Signals all goroutines to start running!
		runstart := time.Now() // When goroutines start running
		wgEnd.Wait() // Wait for all goroutines to complete
		runelap := time.Since(runstart) // Calculate elapsed time (duration) in seconds
		runelaps := runelap.Seconds()
		debugPrint(fmt.Sprintf("All (%d) goroutines completed - elapsed run time: %f", streams, runelaps))
		// Fetch and output results
		err = resultGbl.ValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		valstrp, err = value.ValStr(tptoken, &errstr)
		if checkErrorReturn(err) { return }
		fmt.Printf(" %s", *valstrp) // ^result
		err = highestGbl.ValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		valstrp, err = value.ValStr(tptoken, &errstr)
		if checkErrorReturn(err) { return }
		fmt.Printf(" %s", *valstrp) // ^highest
		fmt.Printf(" %.3f", runelaps) // Test elapsed time in seconds
		err = updatesGbl.ValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		valstrp, err = value.ValStr(tptoken, &errstr)
		if checkErrorReturn(err) { return }
		fmt.Printf(" %s", *valstrp) // ^updates
		updatecnt, err = strconv.ParseInt(*valstrp, 10, 64)
		if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
		err = readsGbl.ValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		valstrp, err = value.ValStr(tptoken, &errstr)
		if checkErrorReturn(err) { return }
		fmt.Printf(" %s", *valstrp) // reads
		readcnt, err = strconv.ParseInt(*valstrp, 10, 64)
		if checkErrorReturn(err) { } // No return here as no special return codes possible
		if 0 < runelaps {
			// If duration is greater than 0, display update and read rates
			fmt.Printf(" %.0f %.0f", float64(updatecnt) / runelaps, float64(readcnt) / runelaps)
		}
		fmt.Printf("\n")
		// This run is complete - reinitialize the database for the next run
		err = value.SetValStrLit(tptoken, &errstr, "0")
		if checkErrorReturn(err) { return }
		err = highestGbl.SetValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		err = readsGbl.SetValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		err = resultGbl.SetValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		err = updatesGbl.SetValST(tptoken, &errstr, &value)
		if checkErrorReturn(err) { return }
		err = stepGbl.Subary.SetElemUsed(tptoken, &errstr, 0)
		if checkErrorReturn(err) { return }
		err = stepGbl.DeleteST(tptoken, &errstr, yottadb.YDB_DEL_TREE)
		if checkErrorReturn(err) { return }
	}
}

// doblk is the entry for our goroutine. It runs through the blocks assigned to this goroutine. The parameter
// is a starting index into the work array (^limits) where this routine picks its work from.
func doblk(index int64) {
	var blkstart, blkend int64
	var dataval uint32
	var strvalp *string
	var err error
	var shrstuff shrStuff

	debugPrint(fmt.Sprintf("Entering doblk() (goroutine # %d) - now released", index))
	shrstuffp := &shrstuff
	// Have to create new data access structs for this goroutine so we don't collide with others
	//
	// Allocate values keys
	shrstuffp.value.Alloc(32)
	shrstuffp.value2.Alloc(32)
	shrstuffp.errstr.Alloc(2048)
	shrstuffp.readsGbl.Alloc(6, 0, 0)
	err = shrstuffp.readsGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^reads")
	if checkErrorReturn(err) { return }
	shrstuffp.updatesGbl.Alloc(8, 0, 0)
	err = shrstuffp.updatesGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^updates")
	if checkErrorReturn(err) { return }
	shrstuffp.highestGbl.Alloc(8, 0, 0)
	err = shrstuffp.highestGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^highest")
	if checkErrorReturn(err) { return }
	shrstuffp.limitsGbl.Alloc(7, 2, 18) // Only 2 subs but allow full 18 digit value
	err = shrstuffp.limitsGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^limits")
	if checkErrorReturn(err) { return }
	// Set the second subscript of ^limits which will always only ever be '1' in this routine.
	err = shrstuffp.limitsGbl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 1, "1")
	if checkErrorReturn(err) { return }
	shrstuffp.stepGbl.Alloc(5, 1, 18)
	err = shrstuffp.stepGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^step")
	if checkErrorReturn(err) { return }
	err = shrstuffp.stepGbl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1)
	if checkErrorReturn(err) { return }
	shrstuffp.resultGbl.Alloc(7, 0, 0)
	err = shrstuffp.resultGbl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "^result")
	if checkErrorReturn(err) { return }
	// Note these local variable creations set a single subscript with the passed in starting index which
	// is unique amongst these goroutines so we can prevent collisions between goroutines when the YDB code
	// becomes fully threaded in the future. Create the subscript value before creating the keys.
	subscr := fmt.Sprintf("%d", index) // Create anti-collide subscr for this goroutine
	shrstuffp.readsLcl.Alloc(6, 1, 18)
	err = shrstuffp.readsLcl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "reads")
	if checkErrorReturn(err) { return }
	err = shrstuffp.readsLcl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 0, &subscr)
	if checkErrorReturn(err) { return }
	err = shrstuffp.readsLcl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1)
	if checkErrorReturn(err) { return }
	shrstuffp.updatesLcl.Alloc(8, 1, 18)
	err = shrstuffp.updatesLcl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "updates")
	if checkErrorReturn(err) { return }
	err = shrstuffp.updatesLcl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 0, &subscr)
	if checkErrorReturn(err) { return }
	err = shrstuffp.updatesLcl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1)
	if checkErrorReturn(err) { return }
	shrstuffp.highestLcl.Alloc(8, 1, 18)
	err = shrstuffp.highestLcl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "highest")
	if checkErrorReturn(err) { return }
	err = shrstuffp.highestLcl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 0, &subscr)
	if checkErrorReturn(err) { return }
	err = shrstuffp.highestLcl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1)
	if checkErrorReturn(err) { return }
	shrstuffp.currpathLcl.Alloc(8, 2, 18)
	err = shrstuffp.currpathLcl.Varnm.SetValStrLit(tptoken, &shrstuffp.errstr, "currpath")
	if checkErrorReturn(err) { return }
	err = shrstuffp.currpathLcl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 0, &subscr)
	if checkErrorReturn(err) { return }
	// (SetElemUsed for curpathLcl is done later)
	// Initialize local reads, updates, and highest to zero.
	err = shrstuffp.value.SetValStrLit(tptoken, &shrstuffp.errstr, "0")
	if checkErrorReturn(err) { return }
	err = shrstuffp.readsLcl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
	if checkErrorReturn(err) { return }
	err = shrstuffp.updatesLcl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
	if checkErrorReturn(err) { return }
	err = shrstuffp.highestLcl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
	if checkErrorReturn(err) { return }
	// Find and process the next block in ^limits that needs processing; quit when no more blocks to process.
	// ^limits(index,1)=0 means that that block defined by ^limits(index) has not been claimed by a job
	// for processing.
	for {
		index++
		err = shrstuffp.limitsGbl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1) // Make sure set for 1 subscript
		if checkErrorReturn(err) { return }
		err = shrstuffp.limitsGbl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 0, fmt.Sprintf("%d", index)) // ^limits(index)
		if checkErrorReturn(err) { return }
		dataval, err = shrstuffp.limitsGbl.DataST(tptoken, &shrstuffp.errstr)
		if checkErrorReturn(err) { return }
		if 0 == dataval {
			break // limit index does not exist - we're done
		}
		// Need to access ^limits with 2 subscripts now
		err = shrstuffp.limitsGbl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 2)
		if checkErrorReturn(err) { return }
		// Bump ^limits(index,1) to attempt to "lock" this block (or at least mark it as being worked on to
		// other goroutines).
		err = shrstuffp.limitsGbl.IncrST(tptoken, &shrstuffp.errstr, nil, &shrstuffp.value)
		if checkErrorReturn(err) { return }
		strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
		if checkErrorReturn(err) { return }
		if "1" != *strvalp {
			continue
		}
		err = shrstuffp.limitsGbl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1) // Make sure set for 1 subscript again
		if checkErrorReturn(err) { return }
		err = shrstuffp.limitsGbl.ValST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // Fetch the value of ^limits(index) which is the 2nd parm to dostep()
		if checkErrorReturn(err) { return }
		strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
		if checkErrorReturn(err) { return }
		blkend, err = strconv.ParseInt(*strvalp, 10, 64)
		if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
		if 1 == index {
			blkstart = 1
		} else {
			err = shrstuffp.limitsGbl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 0, fmt.Sprintf("%d", index - 1)) // ^limits(index - 1)
			if checkErrorReturn(err) { return }
			err = shrstuffp.limitsGbl.ValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
			if checkErrorReturn(err) { return }
			strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
			if checkErrorReturn(err) { return }
			blkstart, err = strconv.ParseInt(*strvalp, 10, 64)
			if checkErrorReturn(err) { } // No return here as no special YDB return code possible
			blkstart++
		}
		dostep(blkstart, blkend, shrstuffp)
	}
        // Adds the number of reads & writes performed by this goroutine to the number of reads & writes performed by all
	// goroutines, and sets the highest for all goroutines if the highest calculated by this process is greater than
	// that calculated so far for all goroutines. Do this in a transaction so is done atomically.
	err = yottadb.TpE(tptoken, &shrstuffp.errstr, func(tptoken uint64, errstrp *yottadb.BufferT) int32 {
		return doblkTpRtn(tptoken, errstrp, shrstuffp)
	}, "BATCH", []string{})
	if checkErrorReturn(err) { return }
}

// doblkTpRtn is the TP callback routine for the TP transaction in the doblk() routine
func doblkTpRtn(tptoken uint64, errstrp *yottadb.BufferT, shrstuffp *shrStuff) int32 {
	var highestLCL, highestDB int64
	var err error
	var strvalp *string

	// Increment ^reads and ^updates by their respective local values
	err = shrstuffp.readsLcl.ValST(tptoken, errstrp, &shrstuffp.value) // Fetch local reads
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	err = shrstuffp.readsGbl.IncrST(tptoken, errstrp, &shrstuffp.value, &shrstuffp.value2)
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	err = shrstuffp.updatesLcl.ValST(tptoken, errstrp, &shrstuffp.value)
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	err = shrstuffp.updatesGbl.IncrST(tptoken, errstrp, &shrstuffp.value, &shrstuffp.value2)
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	// Fetch ^highest to see if it is greater than our local highest - if so, update it to new higher value.
	err = shrstuffp.highestGbl.ValST(tptoken, errstrp, &shrstuffp.value)
	if (nil != err) {
		// Ignore GVUNDEF error - treat as 0 value
		if (yottadb.YDB_ERR_GVUNDEF != yottadb.ErrorCode(err)) {
			if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
		}
		highestDB = 0
	} else {
		strvalp, err = shrstuffp.value.ValStr(tptoken, errstrp)
		if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
		highestDB, err = strconv.ParseInt(*strvalp, 10, 64)
		if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
	}
	err = shrstuffp.highestLcl.ValST(tptoken, errstrp, &shrstuffp.value2)
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	strvalp, err = shrstuffp.value2.ValStr(tptoken, errstrp)
	if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	highestLCL, err = strconv.ParseInt(*strvalp, 10 , 64)
	if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
	if highestDB < highestLCL {
		// Local value is higher - update into DB
		err = shrstuffp.highestGbl.SetValST(tptoken, errstrp, &shrstuffp.value2)
		if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	}
	return 0
	// Commit happens on return to ydb_tp_st()/ydb_tp_s().
}

// dostep is a routine to process the values between the first two parms (inclusive) and update the local stats and
// are passed in. This is what the 3n+1 processing for a given starting number. Each number in the given range is processed.
// Processing is calculating the number of steps of each number.
func dostep(blkstart, blkend int64, shrstuffp *shrStuff) {
	var current, i, n, highestDB, stepval int64
	var dataval uint32
	var err error
	var strvalp *string

	// Loop through the numbers in the block
	for current = blkstart; current <= blkend; current++ {
		n = current
		// Kill the current currpath. Need to set elements used to 1 temporarily so we delete
		// all of our goroutine's nodes.
		err = shrstuffp.currpathLcl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 1)
		if checkErrorReturn(err) { return }
		err = shrstuffp.currpathLcl.DeleteST(tptoken, &shrstuffp.errstr, yottadb.YDB_DEL_TREE)
		if checkErrorReturn(err) { return }
		err = shrstuffp.currpathLcl.Subary.SetElemUsed(tptoken, &shrstuffp.errstr, 2)
		if checkErrorReturn(err) { return }
		// Go till we reach 1 or a number with a known number of steps
		for i = 0; ; i++ {
			err = shrstuffp.readsLcl.IncrST(tptoken, &shrstuffp.errstr, nil, &shrstuffp.value) // Bump local reads
			if checkErrorReturn(err) { return }
			err = shrstuffp.stepGbl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 0, fmt.Sprintf("%d", n)) // Subscript n
			if checkErrorReturn(err) { return }
			dataval, err = shrstuffp.stepGbl.DataST(tptoken, &shrstuffp.errstr) // $DATA(^step(n)
			if checkErrorReturn(err) { return }
			if (0 != dataval) || (1 == n) {
				break // This value is done by someone else so stop here
			}
			err = shrstuffp.currpathLcl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 1, fmt.Sprintf("%d", i))
			if checkErrorReturn(err) { return }
			err = shrstuffp.value.SetValStrLit(tptoken, &shrstuffp.errstr, fmt.Sprintf("%d", n))
			if checkErrorReturn(err) { return }
			err = shrstuffp.currpathLcl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // currpath(index, i) = n
			if checkErrorReturn(err) { return }
			// Modify n according to 3n+1 rules
			if 0 == (n & 0x1) {
				n = n / 2 // Even numbers are halved
			} else {
				n = (3 * n) + 1 // Odd numbers get the signature treatment
			}
			// If n is > highest then set highest = n
			err = shrstuffp.highestLcl.ValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
			if checkErrorReturn(err) { return }
			strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
			if checkErrorReturn(err) { return }
			highestDB, err = strconv.ParseInt(*strvalp, 10, 64)
			if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
			if n > highestDB {
				// Reset our high water mark
				err = shrstuffp.value.SetValStrLit(tptoken, &shrstuffp.errstr, fmt.Sprintf("%d", n)) // Subscript n
				if checkErrorReturn(err) { return }
				err = shrstuffp.highestLcl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // highest = n
				if checkErrorReturn(err) { return }
			}
		}
		if 0 < i { // if 0=i we already have an answer for n, nothing to do here
			if 1 < n {
				err = shrstuffp.stepGbl.Subary.SetValStrLit(tptoken, &shrstuffp.errstr, 0, fmt.Sprintf("%d", n)) // Subscript n
				if checkErrorReturn(err) { return }
				err = shrstuffp.stepGbl.ValST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // fetch ^step(n)
				if checkErrorReturn(err) { return }
				strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
				if checkErrorReturn(err) { return }
				stepval, err = strconv.ParseInt(*strvalp, 10, 64)
				if checkErrorReturn(err) { } // No return here as no special YDB return code possible
				i += stepval
			}
			// Atomically set maximum value with a transaction driven as a "closure" type routine.
			// This allows us use of the stack vars we've already built in this routine or its
			// enclosing routine - specifically, we can use the data structures already set up
			// (e.g. resultGbl, value, etc).
			shrstuffp.maxpath = i
			err = yottadb.TpE(tptoken, &shrstuffp.errstr, func(tptoken uint64, errstrp *yottadb.BufferT) int32 {
				return dostepTpRtn(tptoken, errstrp, shrstuffp)
			},  "BATCH", []string{})
			if checkErrorReturn(err) { return }
			// For each value in series, set ^step() to the number of values until 1
			err = shrstuffp.currpathLcl.Subary.SetElemLenUsed(tptoken, &shrstuffp.errstr, 1, 0) // Start with a null subscript
			if checkErrorReturn(err) { return }
			for {
				err = shrstuffp.currpathLcl.SubNextST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // Fetch next subscript
				if (nil != err) {
					if (yottadb.YDB_ERR_NODEEND != yottadb.ErrorCode(err)) {
						if checkErrorReturn(err) { return }
					}
					break
				}
				// Set retrieved subscript back into shrstuffp.currpathLcl key
				strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
				if checkErrorReturn(err) { return }
				err = shrstuffp.currpathLcl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 1, strvalp)
				if checkErrorReturn(err) { return }
				// We want to save the returned subscript value as 'n'
				n, err = strconv.ParseInt(*strvalp, 10, 64)
				if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
				// Increment local updates
				err = shrstuffp.updatesLcl.IncrST(tptoken, &shrstuffp.errstr, nil, &shrstuffp.value)
				if checkErrorReturn(err) { return }
				// ^step(currpath(n)) = i - n
				err = shrstuffp.currpathLcl.ValST(tptoken, &shrstuffp.errstr, &shrstuffp.value) // current value of currpath(n)
				if checkErrorReturn(err) { return }
				strvalp, err = shrstuffp.value.ValStr(tptoken, &shrstuffp.errstr)
				if checkErrorReturn(err) { return }
				err = shrstuffp.stepGbl.Subary.SetValStr(tptoken, &shrstuffp.errstr, 0, strvalp) // Set value as subscript of ^step
				if checkErrorReturn(err) { return }
				err = shrstuffp.value.SetValStrLit(tptoken, &shrstuffp.errstr, fmt.Sprintf("%d", i - n))
				if checkErrorReturn(err) { return }
				err = shrstuffp.stepGbl.SetValST(tptoken, &shrstuffp.errstr, &shrstuffp.value)
				if checkErrorReturn(err) { return }
			}
		}
	}
}

// dostepTpRtn is the TP callback routine for the TP transaction in the dostep() routine
func dostepTpRtn(tptoken uint64, errstrp *yottadb.BufferT, shrstuffp *shrStuff) int32 {
	var resultDB int64
	var err error
	var strvalp *string

	err = shrstuffp.resultGbl.ValST(tptoken, errstrp, &shrstuffp.value)
	if (nil != err) {
		// If this was a GVUNDEF ignore it and treat the value as 0
		if yottadb.YDB_ERR_GVUNDEF != yottadb.ErrorCode(err) {
			if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
		}
		resultDB = 0
	} else {
		strvalp, err = shrstuffp.value.ValStr(tptoken, errstrp)
		if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
		resultDB, err = strconv.ParseInt(*strvalp, 10, 64)
		if checkErrorReturn(err) { } // No return here as no special YDB return codes possible
	}
	if shrstuffp.maxpath > resultDB {
		// Have a new longest path so set it into ^result replacing old value
		err = shrstuffp.value.SetValStrLit(tptoken, errstrp, fmt.Sprintf("%d", shrstuffp.maxpath))
		if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
		err = shrstuffp.resultGbl.SetValST(tptoken, errstrp, &shrstuffp.value)
		if checkErrorReturn(err) { return int32(yottadb.ErrorCode(err)) }
	}
	return 0
}
