//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.      //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
// Test the syslogEntry() function by forcing a SIGACKTIMEOUT message. This should put an entry in the syslog which
// the test script will wait for.

package main

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"os"
	"sync"
	"syscall"
	"time"
)

const tptoken uint64 = yottadb.NOTTP // No TP in this test currently

func main() {
	var wgDone sync.WaitGroup

	// Write out PID out to pid.txt so we can search for OUR errors only
	fd, err := os.Create("pid.txt")
	if nil != err {
		panic(err)
	}
	_, err = fd.WriteString(fmt.Sprintf("%d\n", os.Getpid()))
	if nil != err {
		panic(err)
	}
	fd.Close()
	// Create signal notify and signal ack channels
	sigNotify := make(chan bool, 1)
	sigAck := make(chan bool, 1)
	yottadb.Init() // Initialize YottaDB just so the engine is alive
	defer yottadb.Exit()
	yottadb.MaximumSigAckWait = 5 // Shorten our timeout just for this test so it runs faster
	// Set up a signal notifier so we do our test while there is a pending signal
	err = yottadb.RegisterSignalNotify(syscall.SIGILL, sigNotify, sigAck, yottadb.NotifyInsteadOfYDBSigHandler)
	if nil != err {
		panic(err)
	}
	wgDone.Add(1) // We have this goroutine to wait for
	go func() {   // Fire up an inline goroutine to wait for the signal
		select {
		case _ = <-sigNotify: // Wait for the signal notification
		}
		defer wgDone.Done() // This routine is done when it exits
		// Sleep long enough to cause a timeout and then have sufficient time for the message to appear
		// in the syslog. Note we tried waiting for one additional second but that ended up not being
		// enough time for the message to appear and for getoper.csh to find it before we exited. Once
		// this goroutine exits, the main exits very quickly which could happen before the syslog
		// message was even made and causing a test failure. Hence the 2*timeout usage.
		time.Sleep(2*time.Duration(yottadb.MaximumSigAckWait*time.Second))
		sigAck <- true // Send acknowledgement to notifier that we are done here
	}()
	syscall.Kill(syscall.Getpid(), syscall.SIGILL) // Send ourselves a SIGINT
	wgDone.Wait() // Wait for the go routine to do its thing
	fmt.Println("ydbgo34d: Complete")
}
