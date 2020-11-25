//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2019 T.N. Incorporation Ltd (TNI) and/or	//
// its subsidiaries. All rights reserved.			//
//								//
// Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	//
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
)

const tptoken uint64 = yottadb.NOTTP

/* Test that there is no sig11 when a properly allocated
 * buffer is given to CallMT() and CallMDescT
 */

func main() {
	var errstr yottadb.BufferT

	defer yottadb.Exit()
	defer errstr.Free()

	errstr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	/* CallMT section */
	fmt.Println("CallMT test")
	retval, err := yottadb.CallMT(tptoken, &errstr, 26, "testciret")
	if nil != err {
		panic(err)
	}
	fmt.Println("ciret: Return value: ", retval)
	fmt.Println("ciret: Return value length: ", len(retval))

	/* CallMDescT section */
	fmt.Println("CallMDescT test")
	var mrtn yottadb.CallMDesc
	mrtn.SetRtnName("testciret")
	retval, err = mrtn.CallMDescT(tptoken, &errstr, 26)
	if nil != err {
		panic(err)
	}
	fmt.Println("ciret: Return value: ", retval)
	fmt.Println("ciret: Return value length: ", len(retval))
}
