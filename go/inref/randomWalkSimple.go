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

/* Run for a specified duration calling random features of the YottaDB Go Simple API.

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

const THREADS_TO_MAKE	= 10
const DRIVER_THREADS	= 10
const MAX_DEPTH		= 10
const NEST_RATE		= 0.20
const TEST_TIMEOUT	= 120 // test timeout in seconds for the driver threads to stop

func Ok(){
	//Noop that means everything is OK
}

type testSettings struct {
	maxDepth	int
	nestedTpRate	float64
}

/* generate a variable to use in runProc()
 */
func genName() []string {
	var ret []string
	num_subs := rand.Int() % 4
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

/* randomly attempts various SimpleAPI functions with a generated variable
 * see header comment for details
 */
func runProc(tptoken uint64, errstr *yottadb.BufferT, settings testSettings, curDepth int) int32 {
	remainingOdds := 80 - (100 * settings.nestedTpRate)
	var varname yottadb.KeyT
	t := genName()

	defer varname.Free()

	varname.Alloc(uint32(len(t[0])), 4, 4)
	varname.Varnm.SetValStr(tptoken, errstr, &t[0])
	for i, elem := range t[1:] {
		varname.Subary.SetValStr(tptoken, errstr, uint32(i), &elem)
	}
	varname.Subary.SetElemUsed(tptoken, errstr, uint32(len(t[1:])))
	action := rand.Float64() * 100

	if action < 20 {
		var value yottadb.BufferT
		defer value.Free()

		value.Alloc(16)
		value.SetValStrLit(tptoken, errstr, "MySecretValue")
		// There are some error codes we accept; anything other than that, raise an error
		err := varname.SetValST(tptoken, errstr, &value)
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
	} else if action < 20 + remainingOdds*(1 / 12.0) {
		var value yottadb.BufferT
		defer value.Free()

		value.Alloc(16)

		err := varname.ValST(tptoken, errstr, &value)
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
	} else if action < 20 + remainingOdds*(2 / 12.0) {
		res, err := varname.DataST(tptoken, errstr)
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
	} else if action < 20 + remainingOdds*(3 / 12.0) {
		delType := rand.Float64()
		var err error
		if delType < 0.5 {
			err = varname.DeleteST(tptoken, errstr, yottadb.YDB_DEL_TREE)
		} else {
			err = varname.DeleteST(tptoken, errstr, yottadb.YDB_DEL_NODE)
		}
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			panic(fmt.Sprintf("Unexpected return code (%d) issued %s", errcode, err))
		}
	} else if action < 20 + remainingOdds*(4 / 12.0) {
		var basevar yottadb.BufferTArray
		defer basevar.Free()

		basevar.Alloc(16, 1)
		varnameStr, _ := varname.Varnm.ValStr(tptoken, errstr)
		basevar.SetValStr(tptoken, errstr, 0, varnameStr)
		err := basevar.DeleteExclST(tptoken, errstr)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			panic(fmt.Sprintf("Unexpected return code (%d) issued %s", errcode, err))
		}
	} else if action < 20 + remainingOdds*(5 / 12.0) {
		direction := rand.Float64()
		if direction < 0.5 {
			direction = 1
		} else {
			direction = -1
		}
		errcode := 0
		var err error
		var value yottadb.BufferTArray
		defer value.Free()

		value.Alloc(4, 16)

		for err == nil {
			value.SetElemUsed(tptoken, errstr, 0)
			if direction == 1 {
				err = varname.NodeNextST(tptoken, errstr, &value)
			} else {
				err = varname.NodePrevST(tptoken, errstr, &value)
			}
			errcode = yottadb.ErrorCode(err)
			for i := uint32(0); i < value.ElemUsed(); i++ {
				s, _ := value.ValStr(tptoken, errstr, i)
				varname.Subary.SetValStr(tptoken, errstr, i, s)
			}
			varname.Subary.SetElemUsed(tptoken, errstr, value.ElemUsed())
		}
		if errcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
		}
	} else if action < 20 + remainingOdds*(6 / 12.0) {
		direction := rand.Float64()
		if direction < 0.5 {
			direction = 1
		} else {
			direction = -1
		}
		errcode := 0
		var err error
		var value yottadb.BufferT
		defer value.Free()

		for err == nil {
			value.Alloc(16)
			if direction == 1 {
				err = varname.SubNextST(tptoken, errstr, &value)
			} else {
				err = varname.SubPrevST(tptoken, errstr, &value)
			}
			errcode = yottadb.ErrorCode(err)
			sub, _ := value.ValStr(tptoken, errstr)
			i := varname.Subary.ElemUsed()
			if i == 0 {
				varname.Varnm.SetValStr(tptoken, errstr, sub)
			} else {
				varname.Subary.SetValStr(tptoken, errstr, i-1, sub)
			}
		}
		if errcode != yottadb.YDB_ERR_NODEEND {
			panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
		}
	} else if action < 20 + remainingOdds*(7 / 12.0) {
		incr_amount := fmt.Sprintf("%f", rand.Float64()*10 - 5)
		var incrVal yottadb.BufferT
		defer incrVal.Free()

		incrVal.Alloc(2)
		incrVal.SetValStr(tptoken, errstr, &incr_amount)
		err := varname.IncrST(tptoken, errstr, &incrVal, nil)
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
		}
	} else if action < 20 + remainingOdds*(8 / 12.0) {
		var err error
		err = yottadb.LockST(tptoken, errstr, 0, &varname)
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
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
		err = varname.LockIncrST(tptoken, errstr, 0)
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
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
		err = varname.LockDecrST(tptoken, errstr)
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
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
		err = yottadb.LockST(tptoken, errstr, 0)
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
			case yottadb.YDB_ERR_TPLOCK:
				Ok()
			default:
				panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
			}
		}
	} else if action < 20 + remainingOdds*(10 / 12.0) {
		var strIn, strOut yottadb.BufferT
		compStr := "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\""
		defer strIn.Free()
		defer strOut.Free()

		strIn.Alloc(32)
		strOut.Alloc(32)
		strIn.SetValStrLit(tptoken, errstr, "a\n\tb\000c")
		err := strIn.Str2ZwrST(tptoken, errstr, &strOut);
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
		}
		s, _ := strOut.ValStr(tptoken, errstr)
		if compStr != *s {
			panic("Str2Zwr did not return the right value")
		}
	} else if action < 20 + remainingOdds*(11 / 12.0) {
		var strIn, strOut yottadb.BufferT
		compStr := "a\n\tb\000c"
		defer strIn.Free()
		defer strOut.Free()

		strIn.Alloc(32)
		strOut.Alloc(32)
		strIn.SetValStrLit(tptoken, errstr, "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"")
		err := strIn.Zwr2StrST(tptoken, errstr, &strOut);
		if err != nil {
			errcode := yottadb.ErrorCode(err)
			panic(fmt.Sprintf("Unexpected return code (%d) issued! %s", errcode, err))
		}
		s, _ := strOut.ValStr(tptoken, errstr)
		if compStr != *s {
			panic("Zwr2Str did not return the right value")
		}
	} else if action < 20 + remainingOdds*(12 / 12.0) {
		yottadb.ReleaseT(tptoken, errstr)
	} else if action <= 100 {
		if curDepth > settings.maxDepth {
			return 0
		}
		var err error
		var tpBuf yottadb.BufferTArray
		makeThreads := rand.Float64() //half the time do a TP, else create THREADS_TO_MAKE routines
		if makeThreads < 0.5 {
			err = tpBuf.TpST(tptoken, errstr, func(tptoken uint64, errstr *yottadb.BufferT) int32 {
				n := rand.Int() % 20
				for i := 0; i < n; i++ {
					runProc(tptoken, errstr, settings, curDepth+1)
				}
				return 0
			}, "BATCH")
		} else {
			var wg sync.WaitGroup
			for i := 0; i < THREADS_TO_MAKE; i++ {
				wg.Add(1)
				go func() {
					runProc(tptoken, errstr, testSettings{MAX_DEPTH, NEST_RATE/2}, curDepth+1)
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
	defer yottadb.Exit()
	var wg sync.WaitGroup
	var doneMutex sync.Mutex

	tptoken := yottadb.NOTTP
	done := false

	go func() { //wait for test timeout then set done to true
		time.Sleep(TEST_TIMEOUT * time.Second)
		doneMutex.Lock()
		done = true
		doneMutex.Unlock()
	} ()

	for i := 0; i < DRIVER_THREADS; i++ {
		wg.Add(1)
		go func() {
			for { //loop until test timeout then break
				doneMutex.Lock()
				d := done
				doneMutex.Unlock()
				if d {
					break
				}
				runProc(tptoken, nil, testSettings{
					MAX_DEPTH,
					NEST_RATE,
				}, 0)
			}
			wg.Done()
		}()
	}
	wg.Wait() //wait for existing routines to end
}
