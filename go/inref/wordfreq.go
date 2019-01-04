//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.//
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
	"os"
	"runtime"
	"strings"
	"lang.yottadb.com/go/yottadb"
)

// Constants for loading varnames and other things with
const maxvarnmlen uint32 = 8
const maxwordssubs uint32 = 1
const maxindexsubs uint32 = 2
const maxwordlen uint32 = 128     // Size increased from the C version which uses 64 here
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

// Define assertnoerr function to check error code and give panic along with location if no ok
func assertnoerr(err error) {
	if nil != err {
		_, file, line, ok := runtime.Caller(1)
		if ok {
			panic(fmt.Sprintf("Assertion failure in %v at line %v with error: %v", file, line, err))
		} else {
			panic(fmt.Sprintf("Assertion failure: %v", err))
		}
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
	var strvalp, tmp1valp, tmp2valp *string
	var words []string

	defer yottadb.Exit()            // Be sure to drive cleanup at process exit
	// Allocate and set up auto-free our two keys
	wordsvar.Alloc(maxvarnmlen, maxwordssubs, maxwordlen)
	defer wordsvar.Free()
	indexvar.Alloc(maxvarnmlen, maxindexsubs, maxwordlen)
	defer indexvar.Free()

	// Decide on local or global vars and initialize varname in the KeyT structures (even/odd of process id). Note
	// the output showing which choice was made is commented out for ease in testing.
	ourPID := os.Getpid()
	if 0 != (ourPID & 1) {
		// fmt.Printf("Using local vars (PID=%d)\n", ourPID)
		rce = wordsvar.Varnm.SetValStrLit(tptoken, nil, "words")
		assertnoerr(rce)
		rce = indexvar.Varnm.SetValStrLit(tptoken, nil, "index")
		assertnoerr(rce)
	} else {
		// fmt.Printf("Using global vars (PID=%d)\n", ourPID)
		rce = wordsvar.Varnm.SetValStrLit(tptoken, nil, "^words")
		assertnoerr(rce)
		rce = indexvar.Varnm.SetValStrLit(tptoken, nil, "^index")
		assertnoerr(rce)
		// Global vars get cleaned out first
		rce = wordsvar.DeleteST(tptoken, nil, yottadb.YDB_DEL_TREE)
		assertnoerr(rce)
		rce = indexvar.DeleteST(tptoken, nil, yottadb.YDB_DEL_TREE)
		assertnoerr(rce)
	}

	// Set the number of subscripts typically used for our two keys
	rce = wordsvar.Subary.SetElemUsed(tptoken, nil, maxwordssubs)
	assertnoerr(rce)
	rce = indexvar.Subary.SetElemUsed(tptoken, nil, maxindexsubs)      // Reverts to single index temporarily later
	assertnoerr(rce)

	// Some structure setup for our word loop below - allocation, and subscript usage
	value.Alloc(maxwordlen)
	defer value.Free()
	tmp1.Alloc(maxwordlen)
	defer tmp1.Free()
	tmp2.Alloc(maxwordlen)
	defer tmp2.Free()
	wordsTmp1.Alloc(maxwordlen)
	defer wordsTmp1.Free()

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
			rce = wordsvar.Subary.SetValStr(tptoken, nil, 0, &word)
			assertnoerr(rce)
			rce = wordsvar.IncrST(tptoken, nil, nil, &value)       // Returned 'value' is ignored
			assertnoerr(rce)
		}
	}

	// Init starting subscript to null string so find first element in the array
	rce = wordsvar.Subary.SetValStrLit(tptoken, nil, 0, "")
	assertnoerr(rce)

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
			assertnoerr(rce)
		}

		// Set this subscript into wordsvar for fetching/previousing.
		tmp1valp, rce = tmp1.ValStr(tptoken, nil)
		assertnoerr(rce)
		rce = wordsvar.Subary.SetValStr(tptoken, nil, 0, tmp1valp) // Set next subscript back into KeyT for next SubNextST() call
		assertnoerr(rce)

		// Fetch the count for this word and set into index (set [^]index(count,var)="")
		strvalp, rce = wordsvar.Subary.ValStr(tptoken, nil, 0)
		assertnoerr(rce)
		rce = wordsvar.ValST(tptoken, nil, &wordsTmp1)
		assertnoerr(rce)
		strvalp, rce = wordsTmp1.ValStr(tptoken, nil)
		assertnoerr(rce)
		rce = indexvar.Subary.SetValStr(tptoken, nil, 0, strvalp)
		assertnoerr(rce)
		rce = indexvar.Subary.SetValStr(tptoken, nil, 1, tmp1valp)
		assertnoerr(rce)
		rce = indexvar.SetValST(tptoken, nil, &nullval)
		assertnoerr(rce)
	}

	// Init first subscript to null string so find first non-null subscript
	rce = indexvar.Subary.SetValStrLit(tptoken, nil, 0, "")
	assertnoerr(rce)

	//  Loop through [^]indexvar array in reverse to print most common words and their counts first.
	for {
		// We only use 1 subscript for this first subscript loop so temporarily set back to 1 sub
		rce = indexvar.Subary.SetElemUsed(tptoken, nil, 1)
		assertnoerr(rce)
		rce = indexvar.SubPrevST(tptoken, nil, &tmp1)
		if nil != rce {
			if int(yottadb.YDB_ERR_NODEEND) == yottadb.ErrorCode(rce) {
				break
			}
			assertnoerr(rce)
		}
		rce = indexvar.Subary.SetElemUsed(tptoken, nil, 2) // Revert to using two subscripts
		assertnoerr(rce)
		tmp1valp, rce = tmp1.ValStr(tptoken, nil)
		assertnoerr(rce)

		// Now loop through all the vars with this frequency count and print them
		rce = indexvar.Subary.SetValStr(tptoken, nil, 0, tmp1valp)
		assertnoerr(rce)
		rce = indexvar.Subary.SetValStrLit(tptoken, nil, 1, "")        // Init first subscr at this level to run list
		assertnoerr(rce)
		for {
			rce = indexvar.SubNextST(tptoken, nil, &tmp2)
			if nil != rce {
				if int(yottadb.YDB_ERR_NODEEND) == yottadb.ErrorCode(rce) {
					break
				}
				assertnoerr(rce)
			}
			tmp2valp, rce = tmp2.ValStr(tptoken, nil)
			assertnoerr(rce)
			rce = indexvar.Subary.SetValStr(tptoken, nil, 1, tmp2valp) // Set value back into key for next SubNextST()
			assertnoerr(rce)

			// Fetch current indexes as strings and print them
			freqcnt, rce := tmp1.ValStr(tptoken, nil)
			assertnoerr(rce)
			fmt.Printf("%v\t%s\n", *freqcnt, *tmp2valp)
		}
	}
}
