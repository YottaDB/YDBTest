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
)

const tptoken uint64 = yottadb.NOTTP

/* Test that there is no sig11 when a properly allocated
 * buffer is given to CallMT() and CallMDescT
 */

func main() {

	/* CallMT section */
	fmt.Println("CallMT test")
	retval, err := yottadb.CallMT(tptoken, nil, 26, "testciret")
	if nil != err {
		panic(err)
	}
	fmt.Println("ciret: Return value: ", retval)
	fmt.Println("ciret: Return value length: ", len(retval))

	/* CallMDescT section */
	fmt.Println("CallMDescT test")
	var mrtn yottadb.CallMDesc
	mrtn.SetRtnName("testciret")
	retval, err = mrtn.CallMDescT(yottadb.NOTTP, nil, 26)
	if nil != err {
		panic(err)
	}
	fmt.Println("ciret: Return value: ", retval)
	fmt.Println("ciret: Return value length: ", len(retval))
}
