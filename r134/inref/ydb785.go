//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	//
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
	"strings"
)

const tptoken uint64 = yottadb.NOTTP

func main() {
	var err error
	var errstr, errstr2 yottadb.BufferT
	var mDesc yottadb.CallMDesc

	defer yottadb.Exit()
	defer errstr.Free()
	defer errstr2.Free()
	errstr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	errstr2.Alloc(yottadb.YDB_MAX_ERRORMSG)

	// First try call with CallMT() which drives ydb_ci_t()
	fmt.Printf("\nTest that we get text of error from ydb_ci_t() when error occurs in M code (LVUNDEF)\n")
	_, err = yottadb.CallMT(yottadb.NOTTP, &errstr, 0, "GimeLVUNDEF")
	if nil != err {
		fmt.Println("Error from CallMT():", err)
		if (yottadb.ErrorCode(err) == yottadb.YDB_ERR_LVUNDEF) && !strings.Contains(err.Error(), "!AD") {
			fmt.Println("*** This was the expected error - SUCCESS!")
		} else {
			fmt.Println("***** This was NOT the error we expected (fully substituted LVUNDEF error) - FAIL\n")
		}
	} else {
		fmt.Println("Call via CallMT() completed with no error (but one was expected)")
	}

	// Now try call with CallMDescT() which drive ydb_cip_t()
	fmt.Printf("\nTest that we get text of error from ydb_cip_t() when error occurs in M code (LVUNDEF)\n")
	mDesc.SetRtnName("GimeLVUNDEF")
	_, err = mDesc.CallMDescT(yottadb.NOTTP, &errstr, 0)
	if nil != err {
		fmt.Println("Error from CallMDescT():", err)
		if (yottadb.ErrorCode(err) == yottadb.YDB_ERR_LVUNDEF) && !strings.Contains(err.Error(), "!AD") {
			fmt.Println("*** This was the expected error - SUCCESS!")
		} else {
			fmt.Println("***** This was NOT the error we expected (fully substituted LVUNDEF error) - FAIL\n")
		}
	} else {
		fmt.Println("Call via CallMDescT() completed with no error (but one was expected)")
	}
}
