//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	//
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
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"sync"
)

const tptoken uint64 = yottadb.NOTTP

func main() {
	var err error
	var wg sync.WaitGroup

	defer yottadb.Exit()
	if (1 >= len(os.Args)) || (3 <= len(os.Args)) {
		fmt.Println("Missing/Invalid argument - Single argument with numeric signal")
		return
	}
	signum, err := strconv.Atoi(os.Args[1])
	if nil != err || (0 >= signum) || (64 < signum) {
		fmt.Println("Argument is not a valid signal number")
		syscall.Exit(1);
	}
	proc, err := os.FindProcess(os.Getpid()) // Figure out our pid - needed for later
	if nil != err {
		panic(err)
	}
	// Buffered channel to receive signal on. Buffered so we don't miss a signal if it comes in and we aren't ready for it
	// (unlikely but possible).
	fmt.Println("dispatching goroutine to wait for signal")
	// Dispatch a goroutine to sit and wait for a signal
	sigchan := make(chan os.Signal, 1)
	wg.Add(1)
	go func() {
		sig := <- sigchan
		fmt.Println("goroutine: Received signal:", sig)
		fmt.Println("goroutine: Exiting..")
		wg.Done()
	}()
	// Request the signal of interest in this test to be sent to sigchan when it occurs.
	// Note: Previously, we used to notify all signals as signals of interest but once in a while the test used to
	// fail because an unrelated signal was received by the above signal handler (e.g. SIGURG shows up unexpectedly).
	// Hence the request only for `signum` below.
	signal.Notify(sigchan, syscall.Signal(signum))
	// Initialize YDB runtime which sets up YDB signal handling. This call has no other purpose (i.e. we aren't
	// trying to delete anything important).
	err = yottadb.DeleteExclE(tptoken, nil, []string{})
	if nil != err {
		panic(err)
	}
	// Now make YDB exit
	yottadb.Exit()
	// Send ourselves the desired signal
	fmt.Println("sending signal", signum, "to ourselves - then waiting for goroutine")
	err = proc.Signal(syscall.Signal(signum))
	if nil != err {
		panic(err)
	}
	// Now wait for the signal to be recognized and the goroutine to finish
	wg.Wait()
	fmt.Println("wait complete - exiting")
}
