//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries. //
// All rights reserved.						//
//								//
//	This source code contains the intellectual property	//
//	of its copyright holder(s), and is made available	//
//	under a license.  If you do not know the terms of	//
//	the license, please stop and do not read further.	//
//								//
//////////////////////////////////////////////////////////////////
package random_walk_test

/* Run for a specified duration calling random features of the YottaDB simple API.

We fork off N threads, where has a chance of:

- Getting a global
- Setting a global
- Killing a global
- Data'ing a global
- Walking through a global
- Walking through a subscript
- Incrementing a global
- Starting a TP transaction
- Ending a TP transaction

The goal is to run for some time with no panics

*/

import (
	"fmt"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
//	"time"
	"sync"
  "testing"
//	"runtime"
)

func Ok() {
	// Noop that means everything is OK
}

type operationCounter chan int

type testSettings struct {
	counter operationCounter
	maxDepth int
	nestedTpRate float64
}

func genGlobalName() []string {
	var ret []string
	num_subs := rand.Int() % 4 + 1
	global_id := rand.Int() % 2
	switch global_id {
	case 0:
		ret = append(ret, "^MyGlobal1")
	case 1:
		ret = append(ret, "^MyGlobal2")
	}
	for i := 0; i < num_subs; i++ {
		ret = append(ret, fmt.Sprintf("sub%d", i))
	}
	return ret
}

func run_proc(tptoken uint64, errstr *yottadb.BufferT, settings testSettings, curDepth int) int32 {
	action := rand.Float64() * 100

	//fmt.Printf("Action: %d\n", action)

	if action < 10 {
		// Get a global
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		_, err := yottadb.ValE(tptoken, errstr, varname, subs)
		settings.counter <- 1
		//fmt.Printf("Done with ValE")
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
	} else if action < 20 {// Get a global
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		err := yottadb.SetValE(tptoken, errstr, "MySecretValue", varname, subs)
		settings.counter <- 1
		//fmt.Printf("Done with SetValE")
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
	} else if action < 30 {
		// Get a global
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		res, err := yottadb.DataE(tptoken, errstr, varname, subs)
		settings.counter <- 1
		//fmt.Printf("Done with DataE")
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
	} else if action < 40 {
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		err := yottadb.DeleteE(tptoken, errstr, yottadb.YDB_DEL_TREE, varname, subs)
		settings.counter <- 1
		//fmt.Printf("Done with DeleteE")
		// There are some error codes we accept; anything other than that, raise an error
		if err != nil {
			panic(err)
		}
	} else if action < 50 {
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		// Pick a random direction
		direction := rand.Float64()
		if direction < .5 {
			direction = 1
		} else {
			direction = -1
		}
		retcode := 0
		// TODO: is the documentation for the SIMPLE API still listing as YDB_NODE_END
		for retcode != yottadb.YDB_ERR_NODEEND {
			var t []string
			var err error
			if direction == 1 {
				t, err = yottadb.NodeNextE(tptoken, errstr, varname, subs)
			} else {
				t, err = yottadb.NodePrevE(tptoken, errstr, varname, subs)
			}
			settings.counter <- 1
			//fmt.Printf("Done with NodeNextE")
			retcode = yottadb.ErrorCode(err)
			subs = t
		}
		if retcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued!", retcode))
		}
	} else if action < 60 {
		t := genGlobalName()
		varname := t[0]
		subs := t[1:]
		// Pick a random direction
		direction := rand.Float64()
		if direction < .5 {
			direction = 1
		} else {
			direction = -1
		}
		retcode := 0
		// TODO: is the documentation for the SIMPLE API still listing as YDB_NODE_END
		for retcode != yottadb.YDB_ERR_NODEEND {
			var t string
			var err error
			if direction == 1 {
				t, err = yottadb.SubNextE(tptoken, errstr, varname, subs)
			} else {
				t, err = yottadb.SubPrevE(tptoken, errstr, varname, subs)
			}
			settings.counter <- 1
			//fmt.Printf("Done with SubNextE")
			retcode = yottadb.ErrorCode(err)
			subs[len(subs)-1] = t
		}
		if retcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued!", retcode))
		}
	} else if action < 100 - (100 * settings.nestedTpRate) {
		t := genGlobalName()
		incr_amount := rand.Float64() * 10 - 5
		varname := t[0]
		subs := t[1:]
		_, err := yottadb.IncrE(tptoken, errstr, fmt.Sprintf("%f", incr_amount), varname, subs)
		settings.counter <- 1
		if err != nil {
			panic(err)
		}
	} else if action < 100 {
		if curDepth > settings.maxDepth {
			return 0
		}
		yottadb.TpE(tptoken, errstr, func(tptoken uint64, errstr *yottadb.BufferT) int32 {
			var wg sync.WaitGroup
			//fmt.Printf("TpToken: %d\n", tptoken)
			for i := 0; i < 10; i++ {
				wg.Add(1)
				go func() {
					run_proc(tptoken, errstr, settings, curDepth+1)
					wg.Done()
				}()
			}
			wg.Wait()
			return 0
		}, "BATCH", []string{})
		settings.counter <- 1
		//fmt.Printf("Done with TpE2")
	} else {
		panic("Huh, random number out of range")
	}
	return 0
}

func BenchmarkRW1threads10depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1, 10, .05) }
func BenchmarkRW10threads10depth5tp(b *testing.B) { benchmarkRandomWalk(b, 10, 10, .05) }
func BenchmarkRW100threads10depth5tp(b *testing.B) { benchmarkRandomWalk(b, 100, 10, .05) }
func BenchmarkRW1000threads10depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 10, .05) }

func BenchmarkRW1threads50depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1, 50, .05) }
func BenchmarkRW10threads50depth5tp(b *testing.B) { benchmarkRandomWalk(b, 10, 50, .05) }
func BenchmarkRW100threads50depth5tp(b *testing.B) { benchmarkRandomWalk(b, 100, 50, .05) }
func BenchmarkRW1000threads50depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 50, .05) }

func BenchmarkRW1threads100depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1, 100, .05) }
func BenchmarkRW10threads100depth5tp(b *testing.B) { benchmarkRandomWalk(b, 10, 100, .05) }
func BenchmarkRW100threads100depth5tp(b *testing.B) { benchmarkRandomWalk(b, 100, 100, .05) }
func BenchmarkRW1000threads100depth5tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 100, .05) }

/*
func BenchmarkRW1threads10depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1, 10, .10) }
func BenchmarkRW10threads10depth10tp(b *testing.B) { benchmarkRandomWalk(b, 10, 10, .10) }
func BenchmarkRW100threads10depth10tp(b *testing.B) { benchmarkRandomWalk(b, 100, 10, .10) }
func BenchmarkRW1000threads10depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 10, .10) }

func BenchmarkRW1threads50depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1, 50, .10) }
func BenchmarkRW10threads50depth10tp(b *testing.B) { benchmarkRandomWalk(b, 10, 50, .10) }
func BenchmarkRW100threads50depth10tp(b *testing.B) { benchmarkRandomWalk(b, 100, 50, .10) }
func BenchmarkRW1000threads50depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 50, .10) }

func BenchmarkRW1threads100depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1, 100, .10) }
func BenchmarkRW10threads100depth10tp(b *testing.B) { benchmarkRandomWalk(b, 10, 100, .10) }
func BenchmarkRW100threads100depth10tp(b *testing.B) { benchmarkRandomWalk(b, 100, 100, .10) }
func BenchmarkRW1000threads100depth10tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 100, .10) }
*/

// These require a pretty beefy setup to run, as the TP threads expand quickly and eat memory
/*
func BenchmarkRW1threads10depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1, 10, .15) }
func BenchmarkRW10threads10depth15tp(b *testing.B) { benchmarkRandomWalk(b, 10, 10, .15) }
func BenchmarkRW100threads10depth15tp(b *testing.B) { benchmarkRandomWalk(b, 100, 10, .15) }
func BenchmarkRW1000threads10depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 10, .15) }

func BenchmarkRW1threads50depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1, 50, .15) }
func BenchmarkRW10threads50depth15tp(b *testing.B) { benchmarkRandomWalk(b, 10, 50, .15) }
func BenchmarkRW100threads50depth15tp(b *testing.B) { benchmarkRandomWalk(b, 100, 50, .15) }
func BenchmarkRW1000threads50depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 50, .15) }

func BenchmarkRW1threads100depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1, 100, .15) }
func BenchmarkRW10threads100depth15tp(b *testing.B) { benchmarkRandomWalk(b, 10, 100, .15) }
func BenchmarkRW100threads100depth15tp(b *testing.B) { benchmarkRandomWalk(b, 100, 100, .15) }
func BenchmarkRW1000threads100depth15tp(b *testing.B) { benchmarkRandomWalk(b, 1000, 100, .15) }
*/

func benchmarkRandomWalk(b *testing.B, threads int, depth int, nestedTpRate float64) {
	var wg sync.WaitGroup

	ch := make(operationCounter)
	operations := 0

	go func() {
		for range ch {
			operations++
		}
	}()


	tptoken := yottadb.NOTTP
	done := false

	for i := 0; i < threads; i++ {
		wg.Add(1)
		go func() {
			for !done {
				run_proc(tptoken, nil, testSettings{
					ch,
					depth,
					nestedTpRate,
				}, 0)
				//runtime.GC()
			}
			wg.Done()
		}()
	}

	for range ch {
		operations++
		if operations > b.N {
			break
		}
	}
	done = true
	wg.Wait()
	close(ch)
}
