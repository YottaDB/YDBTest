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
package main

import "C"

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"unsafe"
)

//go:generate gengluecode -pkg main -func myGoCallback

//export MyGoCallback
func MyGoCallback(tptoken uint64, errptr unsafe.Pointer, tpfnarg unsafe.Pointer) int {
	var errstr yottadb.BufferT
	errstr.BufferTFromPtr(errptr)

	err := yottadb.SetValE(tptoken, &errstr, "Hello world", "^hello", []string{})
	if err != nil {
		errcode := yottadb.ErrorCode(err)
		return errcode
	}
	return yottadb.YDB_OK
}

func main() {
	var errstr yottadb.BufferT

	errstr.Alloc(64)

	err := yottadb.TpE(yottadb.NOTTP, &errstr, GetMyGoCallbackCgo(), nil, "BATCH", []string{})

	if err != nil {
		errval, _ := errstr.ValStr(yottadb.NOTTP, nil)
		fmt.Printf("Error encountered! %s\n", *errval)
	}
}
