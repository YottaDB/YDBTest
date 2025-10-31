//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (c) 2019-2026 YottaDB LLC. and/or its subsidiaries.//
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
	"lang.yottadb.com/go/yottadb"
	"runtime"
	"time"
)

// Constant definitions

// LockTimeout is the maximum wait for a lock to be granted by LockST(), LockE(), LockIncrST(), or LockIncrE()
const LockTimeout uint64 = uint64(15 * time.Minute)

// MaxValueLen is the maximum size of a "normal" value
const MaxValueLen uint32 = 256 // Maximum length of value returned for most nodes (keeps buffers small)
// BigMaxValueLen is the maximum size of a "magnum" value (quite a bit bigger than "normal")
const BigMaxValueLen uint32 = (MaxValueLen * 6) // Certain values can go more than MAXVALUELEN so we need this in that case
// NumSubs is the maximum number of subscripts that KeyTs need to allocate.
const NumSubs int32 = 8

// CheckErrorReturn assists with error checking. Given that a handful of valid errors codes are possible, this function returns
// true if we hit a valid error code and should "restart". For TP, this means returning from the TP callback and letting the
// engine call it again. For non-TP, it means we caught a CALLINAFTEREXIT error which is possible if the C managed thread that
// detected a fatal condition shutsdown YDB but another thread running a goroutine doesn't know it yet and tries a call. If a
// thread gets a CALLINAFTEREXIT in the normal course of things it either a programming error - where a call has been made
// after intentionally shutting down YDB by driving yottadb.Exit() or it is unintentional with YDB shutting the process down
// but some goroutines not yet aware of it.
func CheckErrorReturn(err error) bool {
	if err == nil {
		return false
	}
	if ydbErr, ok := err.(*yottadb.YDBError); ok {
		switch yottadb.ErrorCode(ydbErr) {
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
			// database, or exit the program.
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

// NewBufferT is a function to return an allocated *BufferT
func NewBufferT(elemlen uint32) *yottadb.BufferT {
	var newbuf yottadb.BufferT

	newbuf.Alloc(elemlen)
	return &newbuf
}

// NewKeyT is a function to return a *KeyT initialized with the given varname and the subscript array allocated
func NewKeyT(tptoken uint64, errstr *yottadb.BufferT, varname string, elemcnt, elemlen uint32) *yottadb.KeyT {
	var newkey yottadb.KeyT

	newkey.Alloc(uint32(len(varname)), elemcnt, elemlen)
	err := newkey.Varnm.SetValStr(tptoken, errstr, varname)
	if CheckErrorReturn(err) {
		panic(err)
	}
	if 0 < elemcnt {
		err = newkey.Subary.SetElemUsed(tptoken, errstr, elemcnt)
		if CheckErrorReturn(err) {
			panic(err)
		}
	}
	return &newkey
}

// NewCallMDesc is a function to return a *CallMDesc initialized with the given routine name
func NewCallMDesc(rtnname string) *yottadb.CallMDesc {
	var newDesc yottadb.CallMDesc

	newDesc.SetRtnName(rtnname)
	return &newDesc
}

// BoolStr is a function to return "0" if the supplied bool is false, else "1"
func BoolStr(flag bool) string {
	if flag {
		return "1"
	}
	return "0"
}
