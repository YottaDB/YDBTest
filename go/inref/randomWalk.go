//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries. //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
package main

/* Run for a specified duration calling random features of the YottaDB Go Easy API.

We fork off N threads, where has a chance of:

- Getting a global/local
- Setting a global/local
- Killing a global/local
- Data'ing a global/local
- Walking through a global/local
- Walking through a subscript
- Incrementing a global/local
- Settings locks on a global/local
- Starting a TP transaction
- Ending a TP transaction
- Creating routines in a TP transaction

The goal is to run for some time with no panics

*/

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
	"sync"
	"time"
)

// This are set randomly at the start of the test but should be treated as constants
var THREADS_TO_MAKE int
var DRIVER_THREADS int
var MAX_THREADS int
var MAX_DEPTH int
var NEST_RATE float64
var TEST_TIMEOUT int

func Ok() {
	// Noop that means everything is OK
}

type testSettings struct {
	maxDepth     int
	nestedTpRate float64
}

var countMutex sync.Mutex
var rtnCount int

/* Generate a variable to be used in runProc()
 */
func genName() []string {
	var ret []string
	num_subs := rand.Int() % 5
	global_id := rand.Int() % 4
	switch global_id {
	case 0:
		ret = append(ret, "^MyGlobal1")
	case 1:
		ret = append(ret, "^MyGlobal2")
	case 2:
		ret = append(ret, "MyLocal1xx")
	case 3:
		ret = append(ret, "MyLocal2xx")
	}
	for i := 0; i < num_subs; i++ {
		ret = append(ret, fmt.Sprintf("sub%d", i))
	}
	return ret
}

/* randomly attempts various EasyAPI functions with a generated variable
 * see header comment for details
 */
func runProc(tptoken uint64, errstr *yottadb.BufferT, settings testSettings, curDepth int) int32 {
	remainingOdds := 80 - (100 * settings.nestedTpRate)
	t := genName()
	varname := t[0]
	subs := t[1:]
	action := rand.Float64() * 100

	if action < 20 {
		err := yottadb.SetValE(tptoken, errstr, "MySecretValue", varname, subs)
		// There are some error codes we accept; anything other than that, raise an error
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
	} else if action < 20+remainingOdds*(1/11.0) {
		_, err := yottadb.ValE(tptoken, errstr, varname, subs)
		// There are some error codes we accept; anything other than that, raise an error
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
	} else if action < 20+remainingOdds*(2/11.0) {
		res, err := yottadb.DataE(tptoken, errstr, varname, subs)
		// There are some error codes we accept; anything other than that, raise an error
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))

			}
		}
		switch res {
		case 0:
			Ok()
		case 1:
			Ok()
		case 10:
			Ok()
		case 11:
			Ok()
		default:
			panic("Unexpected data value issued!")
		}
	} else if action < 20+remainingOdds*(3/11.0) {
		delType := rand.Float64()
		var err error
		if delType < 0.5 {
			err = yottadb.DeleteE(tptoken, errstr, yottadb.YDB_DEL_TREE, varname, subs)
		} else {
			err = yottadb.DeleteE(tptoken, errstr, yottadb.YDB_DEL_NODE, varname, subs)
		}
		// There are some error codes we accept; anything other than that, raise an error
		if err != nil {
			panic(err)
		}
	} else if action < 20+remainingOdds*(4/11.0) {
		err := yottadb.DeleteExclE(tptoken, errstr, []string{})
		if err != nil {
			panic(err)
		}
	} else if action < 20+remainingOdds*(5/11.0) {
		direction := rand.Float64()
		if direction < .5 {
			direction = 1
		} else {
			direction = -1
		}
		retcode := 0
		var s []string
		var err error
		for err == nil {
			if direction == 1 {
				s, err = yottadb.NodeNextE(tptoken, errstr, varname, subs)
			} else {
				s, err = yottadb.NodePrevE(tptoken, errstr, varname, subs)
			}
			retcode = yottadb.ErrorCode(err)
			subs = s
		}
		if retcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued!", retcode))
		}
	} else if action < 20+remainingOdds*(6/11.0) {
		// Pick a random direction
		direction := rand.Float64()
		if direction < .5 {
			direction = 1
		} else {
			direction = -1
		}
		retcode := 0
		var s string
		var err error
		for err == nil {
			if direction == 1 {
				s, err = yottadb.SubNextE(tptoken, errstr, varname, subs)
			} else {
				s, err = yottadb.SubPrevE(tptoken, errstr, varname, subs)
			}
			retcode = yottadb.ErrorCode(err)
			if len(t) == 1 {
				varname = s
			} else {
				subs[len(subs)-1] = s
			}
		}
		if retcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued!", retcode))
		}
	} else if action < 20+remainingOdds*(7/11.0) {
		incr_amount := rand.Float64()*10 - 5
		_, err := yottadb.IncrE(tptoken, errstr, fmt.Sprintf("%f", incr_amount), varname, subs)
		if err != nil {
			panic(err)
		}
	} else if action < 20+remainingOdds*(8/11.0) {
		var err error
		err = yottadb.LockE(tptoken, errstr, 0, varname, subs)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				errstr.Dump()
				fmt.Println(varname)
				fmt.Println(subs)
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}

		err = yottadb.LockIncrE(tptoken, errstr, 0, varname, subs)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
		err = yottadb.LockDecrE(tptoken, errstr, varname, subs)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
		err = yottadb.LockE(tptoken, errstr, 0)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			switch errcode {
			case yottadb.YDB_ERR_GVUNDEF:
				Ok()
			case yottadb.YDB_ERR_INVSVN:
				Ok()
			case yottadb.YDB_ERR_LVUNDEF:
				Ok()
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
	} else if action < 20+remainingOdds*(9/11.0) && tptoken != yottadb.NOTTP {
		/*	err := yottadb.Exit()
			if err != nil {
				panic(err)
			} */
	} else if action < 20+remainingOdds*(10/11.0) {
		_, err := yottadb.MessageT(tptoken, errstr, yottadb.YDB_ERR_KILLBYSIGUINFO)
		if err != nil {
			panic(err)
		}
	} else if action < 20+remainingOdds*(11/11.0) {
		yottadb.IsLittleEndian()
	} else if action <= 100 {
		if curDepth > settings.maxDepth { //if at max depth exit
			return 0
		}
		var err error
		makeThreads := rand.Float64() //half the time do a TP, else create THREADS_TO_MAKE routines
		// have to save this to a local variable to prevent dataraces in the 'if' clause
		countMutex.Lock()
		curCount := rtnCount
		countMutex.Unlock()
		if makeThreads < 0.5 || curCount >= MAX_THREADS {
			err = yottadb.TpE(tptoken, errstr, func(tptoken uint64, errstr *yottadb.BufferT) int32 {
				n := rand.Int() % 20
				for i := 0; i < n; i++ {
					runProc(tptoken, errstr, settings, curDepth+1)
				}
				return 0
			}, "BATCH", []string{})
		} else {
			var wg sync.WaitGroup
			for i := 0; i < THREADS_TO_MAKE; i++ {
				wg.Add(1)
				go func() {
					countMutex.Lock()
					rtnCount++
					countMutex.Unlock()
					runProc(tptoken, errstr, testSettings{MAX_DEPTH, NEST_RATE / 2}, curDepth+1)
					countMutex.Lock()
					rtnCount--
					countMutex.Unlock()
					wg.Done()
				}()
			}
			wg.Wait()
			return 0
		}
		if err != nil {
			panic(err)
		}
	} else {
		panic("Huh, random number out of range")
	}
	return 0
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	THREADS_TO_MAKE = rand.Intn(17) + 4 //[4,20]
	DRIVER_THREADS = rand.Intn(9) + 2   //[2,10]
	MAX_THREADS = 1000
	MAX_DEPTH = rand.Intn(19) + 2            //[2,20]
	NEST_RATE = float64(rand.Intn(21)) / 100 //[0,0.20]
	TEST_TIMEOUT = rand.Intn(106) + 15       //[15,120] test timeout in seconds for the driver threads to stop
	defer yottadb.Exit()
	var wg sync.WaitGroup
	var doneMutex sync.Mutex

	tptoken := yottadb.NOTTP
	done := false

	go func() { //wait for test timeout then set done to true
		time.Sleep(time.Duration(TEST_TIMEOUT) * time.Second)
		doneMutex.Lock()
		done = true
		doneMutex.Unlock()
	}()

	for i := 0; i < DRIVER_THREADS; i++ {
		wg.Add(1)
		go func() {
			var errstr yottadb.BufferT
			defer errstr.Free()
			errstr.Alloc(yottadb.YDB_MAX_ERRORMSG)
			countMutex.Lock()
			rtnCount++
			countMutex.Unlock()
			for { //loop until test timeout then break
				doneMutex.Lock()
				d := done
				doneMutex.Unlock()
				if d {
					break
				}
				runProc(tptoken, &errstr, testSettings{
					MAX_DEPTH,
					NEST_RATE,
				}, 0)
			}
			countMutex.Lock()
			rtnCount--
			countMutex.Unlock()
			wg.Done()
		}()
	}

	wg.Wait() //wait for existing routines to end
}
