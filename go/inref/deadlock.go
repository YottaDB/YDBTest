//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.      //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
// This is a derived work based on a simple test sent to us to demonstrate an issue found by a user. A further derivation of
// this test is used in the tprestart test but this one is used to demonstrate the occurence of a deadlock if a TP callback
// routine does not use the correct tptoken value passed into it during the callback. Once a deadlock detector is added, this
// test will start failing in that it won't hang anymore but then then transition to being a test for the deadlock detector.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
)

const gbl = "^ZTESTREAL"

func main() {
	var errStr yottadb.BufferT

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	// under TP
	err := yottadb.TpE(yottadb.NOTTP, &errStr, func(tptoken uint64, errstrp *yottadb.BufferT) (ret int32) {
		fmt.Println("* Reading global (expecting deadlock): ")
		fmt.Println("* value read:", read())
		return yottadb.YDB_OK
	}, "", []string{})
	fmt.Println("* Unexpectedly returned from expected deadlock")
	if err != nil {
		fmt.Println(err)
	}
}

func read() string {
	var errStr yottadb.BufferT

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	// Note we are not using the correct tptoken here. It should have been passed in the call from the TP callback routine
	// for us to use here. And while at it, could have passed in the error string instead of creating a new one.
	readVal, err := yottadb.ValE(yottadb.NOTTP, &errStr, gbl, []string{})
	if err != nil {
		fmt.Println(err)
	}
	return readVal
}
