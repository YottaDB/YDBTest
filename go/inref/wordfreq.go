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

//
// workfreqgo: Count and report word frequencies for http://www.cs.duke.edu/csed/code/code2007/
//

package main

import (
	"bufio"
	"fmt"
	"io"
	"lang.yottadb.com/go/yottadb"
	"os"
	"runtime"
	"strings"
)

// Constants for loading varnames and other things with
const maxvarnmlen uint32 = 8
const maxwordssubs uint32 = 1
const maxindexsubs uint32 = 2
const maxwordlen uint32 = 128 // Size increased from the C version which uses 64 here
const tptoken uint64 = yottadb.NOTTP

// Define assert function to validate return codes and panic is assertion fails
func assert(good bool) {
	if !good {
		_, file, line, ok := runtime.Caller(1)
		if ok {
			panic(fmt.Sprintf("Assertion failure: in %v at line %v", file, line))
		} else {
			panic("Assertion failure")
		}
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
// section
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
// Main routine (wordfreq) - Golang flavor
//
// Note, this routine uses nil for all errstr values in yottadb package calls since this program uses a single goroutine.
//
func main() {
	var wordsvar, indexvar yottadb.KeyT
	var value, tmp1, tmp2, wordsTmp1, nullval yottadb.BufferT
	var rce error
	var word, linein, lineinlc string
	var strval, tmp1val, tmp2val string
	var words []string

	defer yottadb.Exit() // Be sure to drive cleanup at process exit
	// Allocate and set up auto-free our two keys
	wordsvar.Alloc(maxvarnmlen, maxwordssubs, maxwordlen)
	indexvar.Alloc(maxvarnmlen, maxindexsubs, maxwordlen)
	// Decide on local or global vars and initialize varname in the KeyT structures (even/odd of process id). Note
	// the output showing which choice was made is commented out for ease in testing.
	ourPID := os.Getpid()
	if 0 != (ourPID & 1) {
		// fmt.Printf("Using local vars (PID=%d)\n", ourPID)
		rce = wordsvar.Varnm.SetValStr(tptoken, nil, "words")
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.Varnm.SetValStr(tptoken, nil, "index")
		if checkErrorReturn(rce) {
			return
		}
	} else {
		// fmt.Printf("Using global vars (PID=%d)\n", ourPID)
		rce = wordsvar.Varnm.SetValStr(tptoken, nil, "^words")
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.Varnm.SetValStr(tptoken, nil, "^index")
		if checkErrorReturn(rce) {
			return
		}
		// Global vars get cleaned out first
		rce = wordsvar.DeleteST(tptoken, nil, yottadb.YDB_DEL_TREE)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.DeleteST(tptoken, nil, yottadb.YDB_DEL_TREE)
		if checkErrorReturn(rce) {
			return
		}
	}
	// Set the number of subscripts typically used for our two keys
	rce = wordsvar.Subary.SetElemUsed(tptoken, nil, maxwordssubs)
	if checkErrorReturn(rce) {
		return
	}
	rce = indexvar.Subary.SetElemUsed(tptoken, nil, maxindexsubs) // Reverts to single index temporarily later
	if checkErrorReturn(rce) {
		return
	}
	// Some structure setup for our word loop below - allocation, and subscript usage
	value.Alloc(maxwordlen)
	tmp1.Alloc(maxwordlen)
	tmp2.Alloc(maxwordlen)
	wordsTmp1.Alloc(maxwordlen)
	// Create a reader for stdin
	readin := bufio.NewReader(os.Stdin)
	// Loop through each line in the input file (via stdin) breaking the line into space delimited words
	for {
		linein, rce = readin.ReadString('\n')
		if nil != rce {
			if io.EOF == rce {
				break
			}
			panic(fmt.Sprintf("ReadString failure: %s", rce))
		}

		// Lower case the string and break line up using Fields method that also eliminates white space
		lineinlc = strings.ToLower(linein)
		words = strings.Fields(lineinlc)

		// Loop over each word (whitespace delineated) in the input line and increment the counter for it in "words" array
		for _, word = range words {
			assert(0 < len(word))
			rce = wordsvar.Subary.SetValStr(tptoken, nil, 0, word)
			if checkErrorReturn(rce) {
				return
			}
			rce = wordsvar.IncrST(tptoken, nil, nil, &value) // Returned 'value' is ignored
			if checkErrorReturn(rce) {
				return
			}
		}
	}
	// Init starting subscript to null string so find first element in the array
	rce = wordsvar.Subary.SetValStr(tptoken, nil, 0, "")
	if checkErrorReturn(rce) {
		return
	}
	// Loop through each word and create the index glvn with the frequency count as the first subscript to sort them into
	// least frequent to most frequent order (typical numeric order). Note even though we pass these subscripts as strings,
	// when the string is a canonic integer, it is converted to an integer value and sorted appropriately (i.e. by numeric
	// value, not by string value).
	for {
		// Fetch next previous subscript
		rce = wordsvar.SubNextST(tptoken, nil, &tmp1)
		if nil != rce {
			if int(yottadb.YDB_ERR_NODEEND) == yottadb.ErrorCode(rce) {
				break
			}
			if checkErrorReturn(rce) {
				return
			}
		}
		// Set this subscript into wordsvar for fetching/previousing.
		tmp1val, rce = tmp1.ValStr(tptoken, nil)
		if checkErrorReturn(rce) {
			return
		}
		rce = wordsvar.Subary.SetValStr(tptoken, nil, 0, tmp1val) // Set next subscript back into KeyT for next SubNextST() call
		if checkErrorReturn(rce) {
			return
		}
		// Fetch the count for this word and set into index (set [^]index(count,var)="")
		strval, rce = wordsvar.Subary.ValStr(tptoken, nil, 0)
		if checkErrorReturn(rce) {
			return
		}
		rce = wordsvar.ValST(tptoken, nil, &wordsTmp1)
		if checkErrorReturn(rce) {
			return
		}
		strval, rce = wordsTmp1.ValStr(tptoken, nil)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.Subary.SetValStr(tptoken, nil, 0, strval)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.Subary.SetValStr(tptoken, nil, 1, tmp1val)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.SetValST(tptoken, nil, &nullval)
		if checkErrorReturn(rce) {
			return
		}
	}
	// Init first subscript to null string so find first non-null subscript
	rce = indexvar.Subary.SetValStr(tptoken, nil, 0, "")
	if checkErrorReturn(rce) {
		return
	}
	//  Loop through [^]indexvar array in reverse to print most common words and their counts first.
	for {
		// We only use 1 subscript for this first subscript loop so temporarily set back to 1 sub
		rce = indexvar.Subary.SetElemUsed(tptoken, nil, 1)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.SubPrevST(tptoken, nil, &tmp1)
		if nil != rce {
			if int(yottadb.YDB_ERR_NODEEND) == yottadb.ErrorCode(rce) {
				break
			}
			if checkErrorReturn(rce) {
				return
			}
		}
		rce = indexvar.Subary.SetElemUsed(tptoken, nil, 2) // Revert to using two subscripts
		if checkErrorReturn(rce) {
			return
		}
		tmp1val, rce = tmp1.ValStr(tptoken, nil)
		if checkErrorReturn(rce) {
			return
		}
		// Now loop through all the vars with this frequency count and print them
		rce = indexvar.Subary.SetValStr(tptoken, nil, 0, tmp1val)
		if checkErrorReturn(rce) {
			return
		}
		rce = indexvar.Subary.SetValStr(tptoken, nil, 1, "") // Init first subscr at this level to run list
		if checkErrorReturn(rce) {
			return
		}
		for {
			rce = indexvar.SubNextST(tptoken, nil, &tmp2)
			if nil != rce {
				if int(yottadb.YDB_ERR_NODEEND) == yottadb.ErrorCode(rce) {
					break
				}
				if checkErrorReturn(rce) {
					return
				}
			}
			tmp2val, rce = tmp2.ValStr(tptoken, nil)
			if checkErrorReturn(rce) {
				return
			}
			rce = indexvar.Subary.SetValStr(tptoken, nil, 1, tmp2val) // Set value back into key for next SubNextST()
			if checkErrorReturn(rce) {
				return
			}

			// Fetch current indexes as strings and print them
			freqcnt, rce := tmp1.ValStr(tptoken, nil)
			if checkErrorReturn(rce) {
				return
			}
			fmt.Printf("%v\t%s\n", freqcnt, tmp2val)
		}
	}
}
