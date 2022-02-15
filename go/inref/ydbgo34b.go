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
// Test the yottadb.UnRegisterSignalNotify() function using the SIGCONT signal. See ydbgo34.csh for description of this test

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"syscall"
	"time"
)

const tptoken uint64 = yottadb.NOTTP // No TP in this test currently
const MaximumSigWait int = 5         // Maximum wait for the SIGCONT signal notification

func main() {
	var errStr yottadb.BufferT
	var err error

	defer errStr.Free()
	errStr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	defer yottadb.Exit()

	fmt.Println("ydbgo34b begins")
	// Request to be notified of a SIGCONT signal
	sigNotify := make(chan bool, 1) // Create the channel that catches signal notifications
	sigAck := make(chan bool, 1)
	err = yottadb.RegisterSignalNotify(syscall.SIGCONT, sigNotify, sigAck, yottadb.NotifyAsyncYDBSigHandler)
	if nil != err {
		panic(err)
	}
	fmt.Println("\nydbgo34b: Sending SIGCONT to ourselves after registering notification channel - should see notification",
		"msg")
	syscall.Kill(syscall.Getpid(), syscall.SIGCONT)
	select { // Wait for signal notification or timer to go off
	case <-sigNotify:
		fmt.Println("ydbgo34b: Signal SIGCONT notification received!")
		sigAck <- true // Let notifier know we are done
	case <-time.After(time.Duration(MaximumSigWait) * time.Second):
		fmt.Println("ydbgo34b: Timeout waiting for SIGCONT notification - giving up")
	}
	// Now remove the registration
	err = yottadb.UnRegisterSignalNotify(syscall.SIGCONT)
	if nil != err {
		panic(err)
	}
	// Flush our channel
	for 0 < len(sigNotify) {
		_ = <-sigNotify // flush an entry from the channel
	}
	// And drive the signal again to make sure the handler doesn't fire this time
	fmt.Println("\nydbgo34b: Sending SIGCONT to ourselves again after UN-registering notification channel - should *NOT* see",
		"a notification msg")
	// Wait for the signal to be handled - it should do largely nothing (i.e. no user handler being driven)
	syscall.Kill(syscall.Getpid(), syscall.SIGCONT)
	select {
	case _ = <-sigNotify:
		fmt.Println("ydbgo34b: Signal SIGCONT notification received in ERROR!")
		sigAck <- true // Let notifier know we are done
	case <-time.After(time.Duration(MaximumSigWait) * time.Second):
		fmt.Println("ydbgo34b: Timeout waiting for SIGCONT notification - deregistration successful")
	}

	fmt.Println("ydbgo34b: Complete")
}
