//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	//
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
	// Buffered channel to receive signal on. Buffered so we don't miss a signal if it comes in and we aren't ready for it
	// (unlikely but possible).
	sigchan := make(chan os.Signal, 1)
	// Dispatch a goroutine to sit and wait for this stuff
	wg.Add(1)
	go func() {
		fmt.Println("goroutine: waiting for signal")
		sig := <- sigchan
		fmt.Println("goroutine: Received signal:", sig)
		wg.Done()
		fmt.Println("goroutine: exiting..")
	}()
	// Request any signals be sent to sigchan when they occur
	signal.Notify(sigchan)
	// Initialize YDB runtime which sets up YDB signal handling. This call has no other purpose (i.e. we aren't
	// trying to delete anything important).
	err = yottadb.DeleteExclE(tptoken, nil, []string{})
	if nil != err {
		panic(err)
	}
	// Now make YDB exit
	yottadb.Exit()
	// Send ourselves the desired signal
	proc, err := os.FindProcess(os.Getpid())
	if nil != err {
		panic(err)
	}
	fmt.Println("sending signal", signum, "to ourselves")
	err = proc.Signal(syscall.Signal(signum))
	if nil != err {
		panic(err)
	}
	fmt.Println("signal sent")
	// Now wait for the signal to be recognized and the goroutine to finish
	fmt.Println("waiting for goroutine")
	wg.Wait()
	fmt.Println("wait complete - exiting")
}
