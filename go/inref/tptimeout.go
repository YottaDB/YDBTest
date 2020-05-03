//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	//
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
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"time"
)

const debug bool = false
const TIMEOUTSEC int = 5                                    // timeout in 5 seconds
const CMDSLEEPPERSEC int = 10                               // Do this many sleeps/updates/sec
const CMDSLEEPINTVL int = int(time.Second) / CMDSLEEPPERSEC // Sleep length to have CMDSLEEPERSEC sleeps/updates per second
const MAXCMDSLEEP int = CMDSLEEPPERSEC * TIMEOUTSEC * 2     // Max count twice as many as takes to get to timeout

// Create long running TP transaction so can see if TPTIME fires and does the right thing
func main() {
	var err error
	var errstr yottadb.BufferT
	var newval string

	defer yottadb.Exit()
	if debug {
		fmt.Println("CMDSLEEPINTVL =", CMDSLEEPINTVL, "   MAXCMDSLEEP =", MAXCMDSLEEP)
	}
	// First thing we want to do is set the $ZMAXTPTIME var to our timeout
	err = yottadb.SetValE(yottadb.NOTTP, nil, fmt.Sprintf("%d", TIMEOUTSEC), "$ZMAXTPTIME", []string{})
	if nil != err {
		panic(err)
	}
	// Clear ^lastindex before we start updating it
	err = yottadb.SetValE(yottadb.NOTTP, nil, "0", "^lastindex", []string{})
	if nil != err {
		panic(err)
	}
	// Start up TP.
	errstr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	defer errstr.Free()
	err = yottadb.TpE(yottadb.NOTTP, &errstr, func(tptoken uint64, errptr *yottadb.BufferT) int32 {
		if debug {
			fmt.Println("TP routine: Entered")
		}
		// Now do some mindless activity with some sleeps in between (not trying to write a ton
		// of data as that is not the purpose).
		for i := 1; MAXCMDSLEEP > i; i++ {
			// Note these sets won't make it to the DB as the transaction is never committed
			err = yottadb.SetValE(tptoken, errptr, fmt.Sprintf("%d", i), "^lastindex", []string{})
			if nil != err {
				if yottadb.YDB_ERR_TPTIMEOUT == yottadb.ErrorCode(err) {
					// We got our timeout - now rollback this transaction by returning with the
					// transaction rollback return code.
					return yottadb.YDB_TP_ROLLBACK
				}
				panic(fmt.Sprintf("SetValE() failed with error: %s", err))
			}
			if debug {
				fmt.Printf("TP routine: Writing record #%d\n", i)
			}
			// Sleep between each call
			time.Sleep(time.Duration(CMDSLEEPINTVL) * time.Nanosecond)
		}
		panic("Did not get interrupted before twice the timeout had transpired")
	}, "BATCH", []string{})
	if nil == err {
		panic("main: TP returned normally when should have returned an error")
	}
	if yottadb.YDB_TP_ROLLBACK != yottadb.ErrorCode(err) {
		panic(fmt.Sprintf("main: TP did not return with expected ROLLBACK after TPTIMEOUT - receive this error instead:" +
			" %v (%d)", err, yottadb.ErrorCode(err)))
	}
	// Transaction should be rolled back now. Increment ^lastindex and see what we ended up with (making sure it is '1').
	newval, err = yottadb.IncrE(yottadb.NOTTP, &errstr, "1", "^lastindex", []string{})
	if nil != err {
		panic(fmt.Sprintf("IncrE() failed with error: %s", err))
	}
	// ^lastindex was bumped till the TPTIMEOUT error occured but since that transaction was rolled back, after the
	// IncrE() above, it should now be '1'. If not, issue error.
	if "1" != newval {
		panic(fmt.Sprintf("newval does not have the expected value - expected: 1, received: %s"))
	}
	fmt.Println("tptimeout success")
}
