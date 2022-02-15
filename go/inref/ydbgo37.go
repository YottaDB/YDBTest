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
// Test that shutting down a YDB process does not have a MaximumSigShutdownWait timer hang in the
// shutdownSignalGoroutines() function in init.go invoked as the YDB engine and wrapper shutdown.
// Note this test is dependent on a fix that went in as part of YDBGo#34.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"sync"
	"syscall"
	"time"
)

func main() {
	var wgDone sync.WaitGroup

	sigNotify := make(chan bool, 1) // Create signal notify and signal ack channels
	sigAck := make(chan bool, 1)
	yottadb.Init() // Initialize YottaDB just so the engine is alive
	// Set up a signal notifier so we do our test while there is a pending signal
	err := yottadb.RegisterSignalNotify(syscall.SIGINT, sigNotify, sigAck, yottadb.NotifyInsteadOfYDBSigHandler)
	if nil != err {
		panic(err)
	}
	wgDone.Add(1) // We have this goroutine to wait for
	go func() {   // Fire up an inline goroutine to wait for the signal then shutdown the engine while signal pending
		select {
		case _ = <-sigNotify: // Wait for the signal notification
		}
		defer wgDone.Done() // This routine is done when it exits
		var startTime = time.Now()
		// Now tell the engine to wrap up and close down and see how long it takes
		yottadb.Exit()
		duration := time.Since(startTime)
		if duration > time.Duration(yottadb.MaximumSigShutDownWait*time.Second) {
			fmt.Println("Test failed taking", duration, "to shutdown")
		} else {
			fmt.Println("Test passed taking only", duration, "to shutdown")
		}
		sigAck <- true // Send acknowledgement to notifier that we are done here
	}()
	syscall.Kill(syscall.Getpid(), syscall.SIGINT) // Send ourselves a SIGINT
	wgDone.Wait() // Wait for the go routine to do its thing
	fmt.Println("ydbgo37: Complete")
}
