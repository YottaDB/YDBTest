//////////////////////////////////////////////////////////////////
//								//
// Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.      //
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
)

func main() {
	var parm1, parm2, parm3 string
	var mrtn yottadb.CallMDesc
	var err error
	var intval int
	var int32val int32
	var uintval uint
	var uint32val uint32
	var boolval bool
	var flt32val float32
	var flt64val float64

	fmt.Println("**Test we can pass various types of read-only parms either by value or by reference")
	fmt.Println("* First test integer types first by value then by reference")
	intval = -42
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", intval, &intval)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	int32val = 42
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", int32val, &int32val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	//**********************************************************
	fmt.Println("* Next unsigned integer tests")
	uintval = 42
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", uintval, &uintval)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	uint32val = 42
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", uint32val, &uint32val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	//**********************************************************
	fmt.Println("* Next bool testes")
	boolval = true
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", true, &boolval)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	//**********************************************************
	fmt.Println("* Next float32 tests")
	flt32val = -3.1415926
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", flt32val, &flt32val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	//**********************************************************
	fmt.Println("* Next float64 tests")
	flt64val = 3.14159265358979323846
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", flt64val, &flt64val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	//**********************************************************
	fmt.Println("* Validate we get a \"not equal\" message when passing different values from tests above (3 tests)")
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", intval, &flt32val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", flt32val, &flt64val)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
        _, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "TestROParmTypes", flt64val, &intval)
        if nil != err {
                panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
        }
	//**********************************************************
	fmt.Println("")
	fmt.Println("**Testing update parms - IO, I, O where 1st & 3rd parms are updated with ALL passed by reference")
	parm1 = "parm1 value              "
	parm2 = "parm2"
	parm3 = "parm3 value              "
	_, err = yottadb.CallMT(yottadb.NOTTP, nil, 0, "Update2Parms", &parm1, &parm2, &parm3)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMT(): %s", err))
	}
	if parm1 != "This-is-the-UPDATED-parm1" {
		fmt.Println("FAIL: parm1 final value not expected: ",parm1)
	}
	if parm2 != "parm2" {
		panic(fmt.Sprintf("FAIL: parm2 was updated to \"%s\" but was not supposed to be", parm2))
	}
	if parm3 != "This-is-the-UPDATED-parm3" {
		fmt.Println("FAIL: parm3 final value not expected: ",parm3)
	}
	//**********************************************************
	fmt.Println("**Testing update parms - IO, I, O where 1st & 3rd parms are updated with parm2 passed by value")
	mrtn.SetRtnName("Update2Parms")
	parm1 = "parm1 value              "
	parm3 = "parm3 value              "
	_, err = mrtn.CallMDescT(yottadb.NOTTP, nil, 0, &parm1, "parm2", &parm3)
	if nil != err {
		panic(fmt.Sprintf("Failure code from CallMDescT(): %s", err))
	}
	if parm1!="This-is-the-UPDATED-parm1" {
		fmt.Println("FAIL: parm1 final value not expected: ",parm1)
	}
	if parm2 != "parm2" {
		panic(fmt.Sprintf("FAIL: parm2 was updated to \"%s\" but was not supposed to be", parm2))
	}
	if parm3!="This-is-the-UPDATED-parm3" {
		fmt.Println("FAIL: parm3 final value not expected: ",parm3)
	}
	//**********************************************************
	mrtn.SetRtnName("Test32Parms")
	fmt.Println("**Testing passing max number of parms (32)")
	_, err = mrtn.CallMDescT(yottadb.NOTTP, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 , 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32)
	if nil != err {
		panic(fmt.Sprintf("Received following error from Test32Parms: %s", err))
	}
	// note validation for Test32Parms is in the output of the M routine verified against the reference file
	//
	//**********************************************************
	// For testing error conditions, drive each error in a routine with a panic recover handler
	TestUpdatePassByValue()
	TestUpdateNonString1()
	TestUpdateNonString2()
	TestExcessParms()

	fmt.Println("Testing complete")
}

func TestUpdatePassByValue() {
	var mrtn yottadb.CallMDesc

	mrtn.SetRtnName("Update2Parms")
	defer func() {
		if panicrsn := recover(); nil != panicrsn {
			fmt.Println("Recovered from panic:", panicrsn)
		}
	}()

	fmt.Println("**Testing error - putting pass-by-value in update parm (expecting panic)")
	_, err := mrtn.CallMDescT(yottadb.NOTTP, nil, 0, "parm1", "parm2", "parm3")
	if nil != err {
		panic(fmt.Sprintf("Received following error: %s", err))
	}
	panic("ERROR: Did not get a panic from CallMDescT() called from TestUpdatePassByValue when one was expected")
}

func TestUpdateNonString1() {
	var mrtn yottadb.CallMDesc
	var parm1 int

	mrtn.SetRtnName("Update2Parms")
	defer func() {
		if panicrsn := recover(); nil != panicrsn {
			fmt.Println("Recovered from panic:", panicrsn)
		}
	}()

	parm1 = 42
	fmt.Println("**Testing error - putting non string type (*int) in update parm (expecting panic)")
	_, err := mrtn.CallMDescT(yottadb.NOTTP, nil, 0, &parm1, "parm2", "parm3")
	if nil != err {
		panic(fmt.Sprintf("Received following error: %s", err))
	}
	panic("ERROR: Did not get a panic from CallMDescT() called from TestUpdateNonString1 when one was expected")
}

func TestUpdateNonString2() {
	var mrtn yottadb.CallMDesc
	var parm1 string
	var parm3 float32

	mrtn.SetRtnName("Update2Parms")
	defer func() {
		if panicrsn := recover(); nil != panicrsn {
			fmt.Println("Recovered from panic:", panicrsn)
		}
	}()

	parm1 = "parm1 value              "
	parm3 = 21.42
	fmt.Println("**Testing error - putting non string type (*float32) in update parm (expecting panic)")
	_, err := mrtn.CallMDescT(yottadb.NOTTP, nil, 0, &parm1, "parm2", &parm3)
	if nil != err {
		panic(fmt.Sprintf("Received following error: %s", err))
	}
	panic("ERROR: Did not get a panic from CallMDescT() called from TestUpdateNonString2 when one was expected")
}


func TestExcessParms() {
	var mrtn yottadb.CallMDesc

	mrtn.SetRtnName("Test32Parms")
	defer func() {
		if panicrsn := recover(); nil != panicrsn {
			fmt.Println("Recovered from panic:", panicrsn)
		}
	}()

	fmt.Println("**Testing error - Passing too many parms (more than 32)")
	_, err := mrtn.CallMDescT(yottadb.NOTTP, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 , 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33)
	if nil != err {
		panic(fmt.Sprintf("Received following error: %s", err))
	}
	panic("ERROR: Did not get a panic from CallMDescT() called from TestExcessParms when one was expected")
}
