//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries. //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
// Test an invalid signal being passed to yottadb.UnRegisterSignalNotify() function.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
	"syscall"
	"time"
)

const tptoken uint64 = yottadb.NOTTP // No TP in this test currently

var numInvSignals int

// List of signals (non-exhaustive) that YottaDB does not register handlers for so are illegal to register user handlers for
var invSignalList = []syscall.Signal{
	syscall.SIGCLD,    // [0]
	syscall.SIGPIPE,   // [1]
	syscall.SIGPROF,   // [2]
	syscall.SIGPWR,    // [3]
	syscall.SIGSTKFLT, // [4]
	syscall.SIGSTOP,   // [5]
	syscall.SIGSYS,    // [6]
	syscall.SIGTSTP,   // [7]
	syscall.SIGTTIN,   // [8]
	syscall.SIGTTOU,   // [9]
	syscall.SIGUSR2,   // [10]
	syscall.SIGVTALRM, // [11]
	syscall.SIGWINCH,  // [12]
	syscall.SIGXCPU,   // [13]
	syscall.SIGXFSZ,   // [14]
}

func testSignalRegister() {
	// Setup panic catcher
	defer func() {
		if r := recover(); nil != r {
			fmt.Println("Recovering from panic -", r)
		}
		return
	}()
	indx := rand.Intn(numInvSignals)
	sigNotify := make(chan bool, 1) // Channel for notification (not really used in this test)
	sigAck := make(chan bool, 1)    // Channel for acknowledgement (not really used in this test)
	// We expect this attempt to generate a panic in the current wrapper
	err := yottadb.RegisterSignalNotify(invSignalList[indx], sigNotify, sigAck, yottadb.NotifyBeforeYDBSigHandler)
	if nil != err {
		fmt.Println(err)
	}
}

func main() {
	var errStr yottadb.BufferT

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	defer yottadb.Exit()

	numInvSignals = len(invSignalList)
	// Initialize random number generator seed
	rand.Seed(time.Now().UnixNano())
	yottadb.Init() // Initialize YDB engine
	// Attempt to register 5 random signals from the above list
	for attempt := 1; 5 >= attempt; attempt++ {
		testSignalRegister()
	}
	fmt.Println("ydbgo34c: Complete")
}
