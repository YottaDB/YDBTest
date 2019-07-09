//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2019 T.N. Incorporation Ltd (TNI) and/or	//
// its subsidiaries. All rights reserved.			//
//								//
// Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	//
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
	"math"
	"math/rand"
	"pseudoBank/dataObject"
	"runtime"
	"strconv"
	"sync"
	"time"
)

// #cgo pkg-config: yottadb
// #include "libyottadb.h"
// #include "libydberrors.h"
// int TestTpRtn_cgo(uint64_t tptoken, uintptr_t in); // Forward declaration
// void ydb_ci_t_wrapper(unsigned long tptoken, char *name, ydb_string_t *arg);
import "C"

/*
const YDB_DEL_TREE  = 1
const AryDim uint32 = 10                        // Dimension (capacity) of array of YDBBufferT struct
const SubSiz uint32 = 15                        // Max length of each subscripts

var tptoken uint64 = yottadb.NOTTP
*/

const tranAmt = 1
const startCid = 100001
const accountNeeded = 1000

func main() {
	defer yottadb.Exit()
	id := strconv.Itoa(rand.Int())
	fmt.Println("init data")
	initData(accountNeeded)
	concurrent := 10
	idShift := math.Ceil(math.Log10(float64(concurrent)))
	var waitGroup sync.WaitGroup

	waitGroup.Add(1)
	timeout := make(chan bool)
	go func() {
		time.Sleep(120 * time.Second)
		for i := 0; i < concurrent; i++ {
			timeout <- false
		}
		waitGroup.Done()
	}()

	waitGroup.Add(concurrent)
	for i := 0; i < concurrent; i++ {
		guid := i
		user := id
		go func(user string) {
			defer waitGroup.Done()
			var t int
			for {
				select {
				case <-timeout:
					return
				default:
					ref := guid + (t * int(math.Pow10(int(idShift))))
					key := strconv.Itoa(ref)
					from := startCid + rand.Intn(accountNeeded)
					to := startCid + rand.Intn(accountNeeded-1)
					if from == to {
						to += 1
					}
					postTranfer(key, from, to, tranAmt, user)
					t++
				}
			}
		}(user)
	}
	waitGroup.Wait()

	fmt.Println("Done")
}

func initData(accountNeeded int) {

	// init data
	var key1, key2 yottadb.KeyT
	var buff1, buff2, errStr yottadb.BufferT
	var tptoken uint64
	var err error
	var cid string

	tptoken = yottadb.NOTTP

	defer key1.Free()
	defer key2.Free()
	defer buff1.Free()
	defer buff2.Free()
	defer errStr.Free()

	key1.Alloc(32, 2, 32)
	key2.Alloc(32, 2, 32)
	buff1.Alloc(64)
	buff2.Alloc(64)
	errStr.Alloc(128)

	// account
	err = key1.Varnm.SetValStr(tptoken, &errStr, "^ZACN")
	handleError(err)
	err = key1.Subary.SetElemUsed(tptoken, &errStr, 1)
	handleError(err)
	err = buff1.SetValStr(tptoken, &errStr, "1|10000000")
	handleError(err)

	for i := 0; i < accountNeeded; i++ {
		cid = strconv.Itoa(startCid + i)
		err = key1.Subary.SetValStr(tptoken, &errStr, 0, cid)
		handleError(err)
		err = key1.SetValST(tptoken, &errStr, &buff1)
		handleError(err)
	}

	// history
	err = key2.Varnm.SetValStr(tptoken, &errStr, "^ZHIST")
	handleError(err)
	err = key2.Subary.SetElemUsed(tptoken, &errStr, 2)
	handleError(err)
	err = key2.Subary.SetValStr(tptoken, &errStr, 1, "1")
	handleError(err)
	err = buff2.SetValStr(tptoken, &errStr, "Account Create||10000000")
	handleError(err)
	for i := 0; i < accountNeeded; i++ {
		cid = strconv.Itoa(100001 + i)
		err = key2.Subary.SetValStr(tptoken, &errStr, 0, cid)
		handleError(err)
		err = key2.SetValST(tptoken, &errStr, &buff2)
		handleError(err)
	}
}

func postTranfer(ref string, from, to, amt int, user string) {

	var keyAcct, keyHist yottadb.KeyT
	var buffAcct, buffHist, errStr yottadb.BufferT
	var tptoken uint64
	// var val1 *string
	var err error
	// var newData string

	tptoken = yottadb.NOTTP

	defer keyAcct.Free()
	defer buffAcct.Free()
	defer keyHist.Free()
	defer buffHist.Free()
	defer errStr.Free()

	keyAcct.Alloc(32, 2, 32)
	keyHist.Alloc(32, 2, 32)
	errStr.Alloc(128)
	// time.Sleep(100 * time.Millisecond)	// to create race condition

	// under TP
	err = yottadb.TpE(tptoken, &errStr, func(tptoken uint64, errstrp *yottadb.BufferT) int32 {

		guid := ref

		var accountFrom, accountTo dataObject.Account
		err = accountFrom.Load(tptoken, from, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}
		err = accountTo.Load(tptoken, to, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		accountFrom.HistSeq += 1
		accountFrom.Bal -= amt
		accountTo.HistSeq += 1
		accountTo.Bal += amt

		err = accountFrom.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}
		err = accountTo.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		var histFrom, histTo dataObject.HistRecord
		histFrom.Cid = from
		histFrom.HistSeq = accountFrom.HistSeq
		histFrom.Comment = "Transfer to " + strconv.Itoa(to)
		histFrom.Amt = -amt
		histFrom.Endbal = accountFrom.Bal
		histFrom.User = guid
		err = histFrom.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		histTo.Cid = to
		histTo.HistSeq = accountTo.HistSeq
		histTo.Comment = "Transfer from " + strconv.Itoa(from)
		histTo.Amt = amt
		histTo.Endbal = accountTo.Bal
		histTo.User = guid
		err = histTo.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		dt := time.Now()
		// guid := strconv.Itoa(ref)
		// guid := ref
		var trnLogFrom, trnLogTo dataObject.TrnLog
		trnLogFrom.Guid = guid
		trnLogFrom.Tseq = 1
		trnLogFrom.Cid = from
		trnLogFrom.Comment = "Transfer to " + strconv.Itoa(to)
		trnLogFrom.TDateTime = dt
		trnLogFrom.Amt = -amt
		trnLogFrom.Endbal = accountFrom.Bal
		trnLogFrom.User = user
		err = trnLogFrom.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		trnLogTo.Guid = guid
		trnLogTo.Tseq = 2
		trnLogTo.Cid = to
		trnLogTo.Comment = "Transfer from " + strconv.Itoa(from)
		trnLogTo.TDateTime = dt
		trnLogTo.Amt = amt
		trnLogTo.Endbal = accountTo.Bal
		trnLogTo.User = user
		err = trnLogTo.Save(tptoken, &keyAcct, &buffAcct, &errStr)
		if handleError(err) {
			return int32(yottadb.ErrorCode(err))
		}

		return 0

	}, "BATCH", []string{})
	handleError(err)
}

func handleError(err error) bool {
	if err == nil {
		return false
	}
	if ydbErr, ok := err.(*yottadb.YDBError); ok {
		switch yottadb.ErrorCode(ydbErr) {
		case yottadb.YDB_TP_RESTART:
			// If an application uses transactions, TP_RESTART must be handled inside the transaction callback;
			// it is here. For completeness, but ensure that one modifies this routine as needed, or copies bits
			// from it. A transaction must be restarted; this can happen if some other process modifies a value
			// we read before we commit the transaction.
			return true
		case yottadb.YDB_TP_ROLLBACK:
			// If an application uses transactions, TP_ROLLBACK must be handled inside the transaction callback;
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
				panic(fmt.Sprintf("Assertion failure in %v at line %v with error (%d): %v", file, line, yottadb.ErrorCode(err), err))
			} else {
				panic(fmt.Sprintf("Assertion failure (%d): %v", yottadb.ErrorCode(err), err))
			}
		}
	} else {
		panic(err)
	}
}
