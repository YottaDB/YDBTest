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
// Note this test is derived from a test case posted to gitlab in our YDBGo repository:
//   YottaDB/Lang/YDBGo#25 (comment 258495195) by @zapkub
//
// The purpose of this test is to verify that with Yottadb r1.30 and Go wrapper 1.1.0 or later, we are able to catch the panic
// raised by a SIGSEGV. Prior to these versions, this test would exit the module leaving a core file and could not be caught by
// Go's recover handler preventing application specific cleanups.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"os"
	"runtime/debug"
)

type A struct {
	S string
}

func main() {
	var nilVar *A

	debug.SetPanicOnFault(false) // No core - just a panic please
	err := yottadb.SetValE(yottadb.NOTTP, nil, "a value", "avariable", []string{})
	if err != nil {
		fmt.Println("panicking from SetValE() call")
		panic(err)
	}
	defer func() { // If a panic makes it here we should intercept it
		if r := recover(); r != nil {
			fmt.Println("Successful panic recovery! Panic message:", r)
			os.Exit(0)
		}
	}()
	fmt.Println(nilVar.S) // Should cause a SIGSEGV as we are dereferencing a nil pointer
}
