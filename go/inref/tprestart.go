//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2020-2026 YottaDB LLC and/or its subsidiaries.      //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
// This is a derived work based on a simple test sent to us to demonstrate an issue found by a user. The return code when a TP
// restart is detected/required from SimpleThreadAPI calls and if M code is driven inside the transaction should be the same.
// Prior to YDB#619, they were not with ydb_ci[p][_t]() returning TPRETRY instead.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"os"
	"os/exec"
)

const gbl = "^ZTESTREAL"

// This main program forces a TP restart by driving another copy of itself and adjusting parameters such that it just does an
// update to the DB in one of the two ways described above.
//
// This routine takes two parameters:
// first parm: Y or N signifying whether this is the main program or not. When first started, this parm should be Y.
// second parm: 0, 1, or 2 - no error checking is done here. On the very first call, 0 is used just to put something
// there. When the interference process is launched, it has a second parm of 1 or 2 depending on which method is to be used
// for interference.
func main() {
	var errStr yottadb.BufferT
	var err error

	defer errStr.Free()
	mainrtn := os.Args[1]  // Is this the main routine (Y or N)
	testfunc := os.Args[2] // Which of the tests we run (1, or 2) (ignored for main = Y)
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	if mainrtn == "Y" {
		err = yottadb.SetValE(yottadb.NOTTP, &errStr, "0", gbl, []string{}) // Initialize engine and value of global
		if err != nil {
			panic(err)
		}
		tprestartviaSTAPI(&errStr, mainrtn)
		tprestartviaMCode(&errStr, mainrtn)
	} else
	{
		switch(testfunc) {
		case "1":
			tprestartviaSTAPI(&errStr, mainrtn)
		case "2":
			tprestartviaMCode(&errStr, mainrtn)
		default:
			panic("invalid testfunc value")
		}
	}
}

// Run TP transaction for TPRESTART via SimpleThreadAPI update
func tprestartviaSTAPI(errStrp *yottadb.BufferT, mainrtn string) {
	err := yottadb.TpE(yottadb.NOTTP, errStrp, func(tptoken uint64, errstrp *yottadb.BufferT) (ret int32) {
		fmt.Println("*** In TP transaction - testing with SimpleThreadAPI call to cause restart")
		fmt.Println("read : ", read(tptoken))
		trestart, err := yottadb.ValE(tptoken, errstrp, "$TRESTART", []string{})
		if nil != err {
			panic(err)
		}
		if mainrtn == "Y" && "0" == trestart {
			// Launch interference job
			cmd := exec.Command("./tprestart", "N", "1")
			err := cmd.Run()
			if nil != err {
				panic(err)
			}
			f, _ := os.Create("stapi.pid")
			defer f.Close()
			fmt.Fprintf(f, "%d\n", cmd.Process.Pid)
		}
		err = callFunc(tptoken, errStrp)
		//err = write(tptoken)
		if err != nil {
			ydbErr, _ := err.(*yottadb.YDBError)
			fmt.Println(yottadb.ErrorCode(ydbErr))
			return int32(yottadb.ErrorCode(ydbErr))
		}
		return yottadb.YDB_OK
	}, "", []string{})
	if err != nil {
		fmt.Println(err)
	}
}

// Run TP transaction for TPRESTART via SimpleThreadAPI update
func tprestartviaMCode(errStrp *yottadb.BufferT, mainrtn string) {
	err := yottadb.TpE(yottadb.NOTTP, errStrp, func(tptoken uint64, errstrp *yottadb.BufferT) (ret int32) {
		var err error
		var trestart string

		fmt.Println("*** In TP transaction - testing with M code call to cause restart")
		fmt.Println("read : ", read(tptoken))
		trestart, err = yottadb.ValE(tptoken, errstrp, "$TRESTART", []string{})
		if nil != err {
			panic(err)
		}
		if mainrtn == "Y" && "0" == trestart {
			// Launch interference job
			cmd := exec.Command("./tprestart", "N", "2")
			err = cmd.Run()
			if nil != err {
				fmt.Println("error from launch:", err)
				panic(err)
			}
			f, _ := os.Create("mcode.pid")
			defer f.Close()
			fmt.Fprintf(f, "%d\n", cmd.Process.Pid)
		}
		err = callFunc(tptoken, errStrp)
		if err != nil {
			ydbErr, _ := err.(*yottadb.YDBError)
			fmt.Println(yottadb.ErrorCode(ydbErr))
			return int32(yottadb.ErrorCode(ydbErr))
		}
		return yottadb.YDB_OK
	}, "", []string{})
	if err != nil {
		fmt.Println(err)
	}
}

// Read our global from the DB
func read(tptoken uint64) string {
	var errStr yottadb.BufferT

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	r, err := yottadb.ValE(tptoken, &errStr, gbl, []string{})
	if err != nil {
		fmt.Println(err)
	}
	return r
}

// Increment our global in the DB. If called as main, we expect it to be YDB_TP_RESTART (returns text "TPRESTART").
// If called as the non-main routine, we expect this call to succeed.
func write(tptoken uint64) error {
	var errStr yottadb.BufferT

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	_, err := yottadb.IncrE(tptoken, &errStr, "1", gbl, []string{})
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println("write function finish with err = ", err)
	return err
}

// Drive M code to do the increment of our global and show the return code. If called as main, we expect it to be YDB_TP_RESTART
// (returns text "TPRESTART"). If called as the non-main routine, we expect this call to succeed.
func callFunc(tptoken uint64, errstrp *yottadb.BufferT) error {
	var mrtn yottadb.CallMDesc

	defer mrtn.Free()
	fmt.Println("Bump global in database via function call")
	mrtn.SetRtnName("Run")
	_, err := mrtn.CallMDescT(tptoken, errstrp, 0)
	fmt.Println("Call function finish with err = ", err)
	return err
}
