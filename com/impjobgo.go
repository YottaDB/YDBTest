///////////////////////////////////////////////////////////////////
//                                                               //
// Copyright (c) 2019-2020 YottaDB LLC. and/or its subsidiaries. //
// All rights reserved.                                          //
//                                                               //
//      This source code contains the intellectual property      //
//      of its copyright holder(s), and is made available        //
//      under a license.  If you do not know the terms of        //
//      the license, please stop and do not read further.        //
//                                                               //
///////////////////////////////////////////////////////////////////

package main

import (
	"fmt"
	"imp"
	"lang.yottadb.com/go/yottadb"
	"math/rand"
	"os"
	"strconv"
	"time"
)

// Golang implementation of impjob^imptp. One of these is fired off for each worker process that imptpgo initiates.

// Constants
const tptoken uint64 = yottadb.NOTTP

// shrStuff is a structure of the keys, buffers and other fields that need to be shared with other routines driven by this
// process.
type shareStuff struct {
	bufI                                 *yottadb.BufferT
	bufloop                              *yottadb.BufferT
	bufsubs                              *yottadb.BufferT
	bufsubsMAX                           *yottadb.BufferT
	bufval                               *yottadb.BufferT
	bufvalALT                            *yottadb.BufferT
	bufvalMAX                            *yottadb.BufferT
	bufvalue                             *yottadb.BufferT
	dlrTRESTART                          *yottadb.KeyT
	lclI                                 *yottadb.KeyT
	lclloop                              *yottadb.KeyT
	lclsubs                              *yottadb.KeyT
	lclsubsMAX                           *yottadb.KeyT
	lclval                               *yottadb.KeyT
	lclvalALT                            *yottadb.KeyT
	lclvalMAX                            *yottadb.KeyT
	gblPctImptp                          *yottadb.KeyT
	gblantp                              *yottadb.KeyT
	gblbntp                              *yottadb.KeyT
	gblcntp                              *yottadb.KeyT
	gbldntp                              *yottadb.KeyT
	gblentp                              *yottadb.KeyT
	gblfntp                              *yottadb.KeyT
	gblgntp                              *yottadb.KeyT
	gblhntp                              *yottadb.KeyT
	gblintp                              *yottadb.KeyT
	gblarandom                           *yottadb.KeyT
	gblbrandomv                          *yottadb.KeyT
	gblcrandomva                         *yottadb.KeyT
	gbldrandomvariable                   *yottadb.KeyT
	gblerandomvariableimptp              *yottadb.KeyT
	gblfrandomvariableinimptp            *yottadb.KeyT
	gblgrandomvariableinimptpfill        *yottadb.KeyT
	gblhrandomvariableinimptpfilling     *yottadb.KeyT
	gblirandomvariableinimptpfillprgrm   *yottadb.KeyT
	gbljrandomvariableinimptpfillprogram *yottadb.KeyT
	gblendloop                           *yottadb.KeyT
	gbllasti                             *yottadb.KeyT
	gblzdummy                            *yottadb.KeyT
	callhelper1                          *yottadb.CallMDesc
	callhelper2                          *yottadb.CallMDesc
	callhelper3                          *yottadb.CallMDesc
	callimptpdztrig                      *yottadb.CallMDesc
	callnoop                             *yottadb.CallMDesc
	callztrcmd                           *yottadb.CallMDesc
	callztwormstr                        *yottadb.CallMDesc
	I                                    int32
	crash                                int32
	fillid                               int32
	istp                                 int32
	jobno                                int32
	loop                                 int32
	trigger                              int32
	ztr                                  bool
	dztrig                               bool
}

// pctImptpInt32 fetches ^%imptp(fillid,xxxxxx) where xxxxxx is supplied as a parm. Assumes fillid (subscript 0) has been
// filled in prior to call as well as the number of used subscripts set to 2.
func pctImptpInt32(tptoken uint64, errstr *yottadb.BufferT, shr *shareStuff, sub2 string, gvundefOK bool) (int32, error) {
	var err error
	var valint64 int64

	err = shr.gblPctImptp.Subary.SetValStr(tptoken, errstr, 1, sub2) // Set second subscript
	if nil == err {
		err = shr.gblPctImptp.ValST(tptoken, errstr, shr.bufvalue) // Fetch value
		if nil == err {
			strval, err := shr.bufvalue.ValStr(tptoken, errstr) // Extract value
			if nil == err {
				valint64, err = strconv.ParseInt(strval, 10, 32) // Convert value
			}
		}
	}
	// If we got a GVUNDEF error and that's allowed, just return 0
	if (nil != err) && gvundefOK && (yottadb.YDB_ERR_GVUNDEF == yottadb.ErrorCode(err)) {
		return 0, nil
	} // Otherwise the caller will deal with any error generated
	return int32(valint64), err
}

// impjobgo is a worker process for imptpgo
func main() {
	var valint, lasti, i, J, root, nroot, rc int32
	var valint64 int64
	var valstr string
	var valptr *yottadb.BufferT
	var starvar yottadb.BufferTArray
	var err error
	var shr shareStuff
	var errstr yottadb.BufferT

	defer yottadb.Exit() // Needed to assure proper cleanup
	defer errstr.Free()

	errstr.Alloc(yottadb.YDB_MAX_ERRORMSG)
	processID := os.Getpid()
	// Initialize random number generator seed
	rand.Seed(time.Now().UnixNano())
	// Fetch our jobid from envvar
	jobidstr := os.Getenv("gtm_test_jobid")
	if "" != jobidstr {
		valint64, err = strconv.ParseInt(jobidstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		valint = 0
	}
	jobid := valint
	jobidstr = fmt.Sprintf("%d", jobid) // Reset with now reformatted string
	// Initialize shared values that need initializing
	shr.bufvalue = imp.NewBufferT(imp.BigMaxValueLen)
	shr.bufI = imp.NewBufferT(imp.MaxValueLen)
	shr.bufloop = imp.NewBufferT(imp.MaxValueLen)
	shr.bufsubs = imp.NewBufferT(imp.MaxValueLen)
	shr.bufsubsMAX = imp.NewBufferT(imp.BigMaxValueLen)
	shr.bufval = imp.NewBufferT(imp.MaxValueLen)
	shr.bufvalALT = imp.NewBufferT(imp.MaxValueLen)
	shr.bufvalMAX = imp.NewBufferT(imp.BigMaxValueLen)
	shr.dlrTRESTART = imp.NewKeyT(tptoken, &errstr, "$TRESTART", 0, 0)
	shr.lclI = imp.NewKeyT(tptoken, &errstr, "I", 0, 0)
	shr.lclloop = imp.NewKeyT(tptoken, &errstr, "loop", 0, 0)
	shr.lclsubs = imp.NewKeyT(tptoken, &errstr, "subs", 0, 0)
	shr.lclsubsMAX = imp.NewKeyT(tptoken, &errstr, "subsMAX", 0, 0)
	shr.lclval = imp.NewKeyT(tptoken, &errstr, "val", 0, 0)
	shr.lclvalALT = imp.NewKeyT(tptoken, &errstr, "valALT", 0, 0)
	shr.lclvalMAX = imp.NewKeyT(tptoken, &errstr, "valMAX", 0, 0)
	shr.gblPctImptp = imp.NewKeyT(tptoken, &errstr, "^%imptp", 2, imp.BigMaxValueLen)
	shr.gblantp = imp.NewKeyT(tptoken, &errstr, "^antp", 2, imp.BigMaxValueLen)
	shr.gblbntp = imp.NewKeyT(tptoken, &errstr, "^bntp", 2, imp.BigMaxValueLen)
	shr.gblcntp = imp.NewKeyT(tptoken, &errstr, "^cntp", 2, imp.BigMaxValueLen)
	shr.gbldntp = imp.NewKeyT(tptoken, &errstr, "^dntp", 2, imp.BigMaxValueLen)
	shr.gblentp = imp.NewKeyT(tptoken, &errstr, "^entp", 2, imp.BigMaxValueLen)
	shr.gblfntp = imp.NewKeyT(tptoken, &errstr, "^fntp", 2, imp.BigMaxValueLen)
	shr.gblgntp = imp.NewKeyT(tptoken, &errstr, "^gntp", 2, imp.BigMaxValueLen)
	shr.gblhntp = imp.NewKeyT(tptoken, &errstr, "^hntp", 2, imp.BigMaxValueLen)
	shr.gblintp = imp.NewKeyT(tptoken, &errstr, "^intp", 2, imp.BigMaxValueLen)
	shr.gblarandom = imp.NewKeyT(tptoken, &errstr, "^arandom", 2, imp.BigMaxValueLen)
	shr.gblbrandomv = imp.NewKeyT(tptoken, &errstr, "^brandomv", 2, imp.BigMaxValueLen)
	shr.gblcrandomva = imp.NewKeyT(tptoken, &errstr, "^crandomva", 2, imp.BigMaxValueLen)
	shr.gbldrandomvariable = imp.NewKeyT(tptoken, &errstr, "^drandomvariable", 2, imp.BigMaxValueLen)
	shr.gblerandomvariableimptp = imp.NewKeyT(tptoken, &errstr, "^erandomvariableimptp", 2, imp.BigMaxValueLen)
	shr.gblfrandomvariableinimptp = imp.NewKeyT(tptoken, &errstr, "^frandomvariableinimptp", 2, imp.BigMaxValueLen)
	shr.gblgrandomvariableinimptpfill = imp.NewKeyT(tptoken, &errstr, "^grandomvariableinimptpfill", 2, imp.BigMaxValueLen)
	shr.gblhrandomvariableinimptpfilling = imp.NewKeyT(tptoken, &errstr, "^hrandomvariableinimptpfilling", 2, imp.BigMaxValueLen)
	shr.gblirandomvariableinimptpfillprgrm = imp.NewKeyT(tptoken, &errstr, "^irandomvariableinimptpfillprgrm", 2, imp.BigMaxValueLen)
	shr.gbljrandomvariableinimptpfillprogram = imp.NewKeyT(tptoken, &errstr, "^jrandomvariableinimptpfillprogr", 4, imp.BigMaxValueLen)
	shr.gblendloop = imp.NewKeyT(tptoken, &errstr, "^endloop", 1, imp.MaxValueLen)
	shr.gbllasti = imp.NewKeyT(tptoken, &errstr, "^lasti", 2, imp.MaxValueLen)
	shr.gblzdummy = imp.NewKeyT(tptoken, &errstr, "^zdummy", 1, imp.MaxValueLen)
	shr.callhelper1 = imp.NewCallMDesc("helper1")
	shr.callhelper2 = imp.NewCallMDesc("helper2")
	shr.callhelper3 = imp.NewCallMDesc("helper3")
	shr.callimptpdztrig = imp.NewCallMDesc("imptpdztrig")
	shr.callnoop = imp.NewCallMDesc("noop")
	shr.callztrcmd = imp.NewCallMDesc("ztrcmd")
	shr.callztwormstr = imp.NewCallMDesc("ztwormstr")
	// Initialize local (to this routine) stuff
	starvar.Alloc(1, 1)
	err = starvar.SetValStr(tptoken, &errstr, 0, "*")
	if imp.CheckErrorReturn(err) {
		return
	}

	// Fetch childnum (first and only parameter). Note we don't do a lot of parameter checking here since this is a test program
	// invoked by another test program.
	childnumstr := os.Args[1]
	if "" != childnumstr {
		valint64, err = strconv.ParseInt(childnumstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		valint = int32(valint64)
	} else {
		panic("impjobgo: required parameter not supplied")
	}
	childnum := valint
	// MCode: set jobindex=index
	err = yottadb.SetValE(tptoken, &errstr, childnumstr, "jobindex", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// Randomly choose whether to complete this imptp worker process by doing a callin to M code or if we want to do it (primarily)
	// in Golang (impjob^imptp). There's a 5% chance for using M-callin versus using Golang for the test.
	useCi := (0 == int(20*rand.Float64()))
	// If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
	// errors can happen in the imptp child process and that is expected. This is easily handled if we
	// invoke the entire child process using impjob^imptp. If we use SimpleAPI/SimpleThreadAPI for this, all the ydb_*_st()
	// calls need to be checked for return status to allow for JNLEXTEND/JNLSWITCHFAIL and it gets clumsy.
	// Since SimpleAPI/SimpleThreadAPI gets good test coverage through imptp in many dozen tests, we choose to use call-ins
	// only for this specific test.
	valstr = os.Getenv("test_subtest_name")
	isGtm8086Subtest := ("gtm8086" == valstr)
	if isGtm8086Subtest {
		useCi = true
	}
	if useCi {
		fmt.Println("impjob; Elected to do M call-in to impjob^imptp for this process")
		// MCode: do impjob^imptp
		_, err = yottadb.CallMT(tptoken, &errstr, 0, "impjob")
		if nil != err {
			errcode := yottadb.ErrorCode(err)
			if isGtm8086Subtest && ((yottadb.YDB_ERR_JNLEXTEND == errcode) || (yottadb.YDB_ERR_JNLSWITCHFAIL == errcode)) {
				return
			}
			panic(fmt.Sprintf("impjob: Driving impjob^imptp failed with error: %s", err))
		}
		return
	}
	// We have randomly chosen to use Go Simple API to run this child
	//
	// MCode: write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	fmt.Println("Start Time:", time.Now().Format("02-Jan-2006 03:04:05.000"))
	// MCode: write "$zro=",$zro,!
	valstr, err = yottadb.ValE(tptoken, &errstr, "$ZROUTINES", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	fmt.Printf("$zro=%s\n", valstr)
	// MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE" merge %imptp=^%imptp
	// No need to translate the above M line as parent would have YDB_ASSERT failed in that case.
	//
	// MCode: set jobno=jobindex	; Set by job.m ; not using $job makes imptp resumable after a crash!
	shr.jobno = childnum
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", shr.jobno), "jobno", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set jobid=+$ztrnlnm("gtm_test_jobid")
	// Bypassed - this fetch has already been done in this function
	//
	// MCode: set fillid=^%imptp("fillid",jobid)
	fillidstr, err := yottadb.ValE(tptoken, &errstr, "^%imptp", []string{"fillid", jobidstr})
	if imp.CheckErrorReturn(err) {
		return
	}
	valint64, err = strconv.ParseInt(fillidstr, 10, 32)
	imp.CheckErrorReturn(err) // Only panic-able errors should hit here
	shr.fillid = int32(valint64)
	err = yottadb.SetValE(tptoken, &errstr, fillidstr, "fillid", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// Fill in subscript 0 of several globals as it is a typical first subscript for them
	err = shr.gblPctImptp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblantp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblbntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblcntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gbldntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblentp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblfntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblgntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblhntp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblintp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblarandom.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblbrandomv.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblcrandomva.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gbldrandomvariable.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblerandomvariableimptp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblfrandomvariableinimptp.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblgrandomvariableinimptpfill.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblhrandomvariableinimptpfilling.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblirandomvariableinimptpfillprgrm.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gblendloop.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	err = shr.gbllasti.Subary.SetValStr(tptoken, &errstr, 0, fillidstr)
	imp.CheckErrorReturn(err)
	// MCode: set jobcnt=^%imptp(fillid,"totaljob")
	jobcnt, err := pctImptpInt32(tptoken, &errstr, &shr, "totaljob", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", jobcnt), "jobcnt", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set prime=^%imptp(fillid,"prime")
	prime, err := pctImptpInt32(tptoken, &errstr, &shr, "prime", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set root=^%imptp(fillid,"root")
	root, err = pctImptpInt32(tptoken, &errstr, &shr, "root", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set top=+$GET(^%imptp(fillid,"top"))
	top, err := pctImptpInt32(tptoken, &errstr, &shr, "top", true)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if top=0 set top=prime\jobcnt
	if 0 == top {
		top = prime / jobcnt
	}
	// MCode: set istp=^%imptp(fillid,"istp")
	shr.istp, err = pctImptpInt32(tptoken, &errstr, &shr, "istp", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", shr.istp), "istp", []string{}) // istp needs to be local var too
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set tptype=^%imptp(fillid,"tptype")
	err = shr.gblPctImptp.Subary.SetValStr(tptoken, &errstr, 1, "tptype")
	if nil == err {
		err = shr.gblPctImptp.ValST(tptoken, &errstr, shr.bufvalue)
		if nil == err {
			valstr, err = shr.bufvalue.ValStr(tptoken, &errstr)
		}
	}
	if imp.CheckErrorReturn(err) {
		return
	}
	// Value to set into 'tptype' is in valstr
	err = yottadb.SetValE(tptoken, &errstr, valstr, "tptype", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	tptypestr := valstr
	// MCode: set tpnoiso=^%imptp(fillid,"tpnoiso")
	tpnoiso, err := pctImptpInt32(tptoken, &errstr, &shr, "tpnoiso", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set dupset=^%imptp(fillid,"dupset")
	dupset, err := pctImptpInt32(tptoken, &errstr, &shr, "dupset", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set skipreg=^%imptp(fillid,"skipreg")
	skipreg, err := pctImptpInt32(tptoken, &errstr, &shr, "skipreg", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set crash=^%imptp(fillid,"crash")
	shr.crash, err = pctImptpInt32(tptoken, &errstr, &shr, "crash", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// Set crash local variable
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", shr.crash), "crash", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set gtcm=^%imptp(fillid,"gtcm")
	gtcm, err := pctImptpInt32(tptoken, &errstr, &shr, "gtcm", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; ONLINE ROLLBACK - BEGIN
	// MCode: ; Randomly 50% when in TP, switch the online rollback TP mechanism to restart outside of TP
	// MCode: ;	orlbkintp = 0 disable online rollback support - this is the default
	// MCode: ;	orlbkintp = 1 use the TP rollback mechanism outside of TP, should be true for only TP
	// MCode: ;	orlbkintp = 2 use the TP rollback mechanism inside of TP, should be true for only TP
	// MCode: set orlbkintp=0
	// MCode: new ORLBKRESUME
	// MCode: if $ztrnlnm("gtm_test_onlinerollback")="TRUE" do init^orlbkresume("imptp",$zlevel,"ERROR^imptp") if istp=1 set orlbkintp=($random(2)+1)
	// MCode: ; ONLINE ROLLBACK -  END
	//
	// The above online rollback section does not need to be migrated since we never run SimpleAPI/GoSimpleAPI against online rollback

	// MCode: set orlbkintp=0
	err = yottadb.SetValE(tptoken, &errstr, "0", "orlbkintp", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}

	// MCode: ; Node Spanning Blocks - BEGIN

	// MCode: set keysize=^%imptp(fillid,"key_size")
	keysize, err := pctImptpInt32(tptoken, &errstr, &shr, "key_size", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// Set keysize local variable
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", keysize), "keysize", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set recsize=^%imptp(fillid,"record_size")
	recsize, err := pctImptpInt32(tptoken, &errstr, &shr, "record_size", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// Set recsize local variable
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", recsize), "recsize", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: set span=+^%imptp(fillid,"gtm_test_spannode")
	span, err := pctImptpInt32(tptoken, &errstr, &shr, "gtm_test_spannode", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// Set span local variable
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", span), "span", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; Node Spanning Blocks - END

	// MCode: ; TRIGGERS - BEGIN
	// MCode: ; The triggers section MUST be the last update to ^%imptp during setup. Online Rollback tests use this as a marker to detect
	// MCode: ; when ^%imptp has been rolled back.

	// MCode: set trigger=^%imptp(fillid,"trigger"),ztrcmd="ztrigger ^lasti(fillid,jobno,loop)",ztr=0,dztrig=0
	shr.trigger, err = pctImptpInt32(tptoken, &errstr, &shr, "trigger", false)
	if imp.CheckErrorReturn(err) {
		return
	}
	// Set trigger local variable
	err = yottadb.SetValE(tptoken, &errstr, fmt.Sprintf("%d", shr.trigger), "trigger", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	err = yottadb.SetValE(tptoken, &errstr, "ztrigger ^lasti(fillid,jobno,loop)", "ztrcmd", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	shr.ztr = false
	shr.dztrig = false
	// MCode: if trigger do
	if 0 != shr.trigger {
		// MCode: . set trigname="triggernameforinsertsanddels"
		err = yottadb.SetValE(tptoken, &errstr, "triggernameforinsertsanddels", "trigname", []string{})
		if imp.CheckErrorReturn(err) {
			return
		}
		// MCode: . set fulltrig="^unusedbyothersdummytrigger -commands=S -xecute=""do ^nothing"" -name="_trigname
		err = yottadb.SetValE(tptoken, &errstr,
			"^unusedbyothersdummytrigger -commands=S -xecute=\"do ^nothing\" -name=triggernameforinsertsanddels",
			"fulltrig", []string{})
		if imp.CheckErrorReturn(err) {
			return
		}
		// MCode: . set ztr=(trigger#10)>1  ; ZTRigger command testing
		shr.ztr = 1 < (shr.trigger % 10)
		// MCode: . set dztrig=(trigger>10) ; $ZTRIGger() function testing
		shr.dztrig = 10 < shr.trigger
	}
	// Set dztrig into M local variable
	err = yottadb.SetValE(tptoken, &errstr, imp.BoolStr(shr.dztrig), "dztrig", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; TRIGGERS -  END

	// MCode: set zwrcmd="zwr jobno,istp,tptype,tpnoiso,orlbkintp,dupset,skipreg,crash,gtcm,fillid,keysize,recsize,trigger"
	// MCode: write zwrcmd,!
	// MCode: xecute zwrcmd
	fmt.Printf("jobno=%d\n", shr.jobno)
	fmt.Printf("istp=%d\n", shr.istp)
	fmt.Printf("tptype=%s\n", tptypestr)
	fmt.Printf("tpnoiso=%d\n", tpnoiso)
	fmt.Printf("orlbkintp=0\n")
	fmt.Printf("dupset=%d\n", dupset)
	fmt.Printf("skipreg=%d\n", skipreg)
	fmt.Printf("crash=%d\n", shr.crash)
	fmt.Printf("gtcm=%d\n", gtcm)
	fmt.Printf("fillid=%d\n", shr.fillid)
	fmt.Printf("keysize=%d\n", keysize)
	fmt.Printf("recsize=%d\n", recsize)
	fmt.Printf("trigger=%d\n", shr.trigger)
	// MCode: write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
	fmt.Printf("PID: %d\nIn hex: %x\n", processID, processID)
	// MCode: lock +^%imptp(fillid,"jsyncnt")  set ^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"jsyncnt")+1  lock -^%imptp(fillid,"jsyncnt")
	// The "ydb_lock_incr_s" and "ydb_lock_decr_s" usages below are unnecessary since "ydb_incr_s" is atomic.
	// But we want to test the SimpleAPI/SimpleThreadAPI lock functions and so have them here just like the M version of imptp.
	err = shr.gblPctImptp.Subary.SetValStr(tptoken, &errstr, 1, "jsyncnt")
	if nil == err {
		err = shr.gblPctImptp.LockIncrST(tptoken, &errstr, imp.LockTimeout)
	}
	if imp.CheckErrorReturn(err) {
		return
	}
	if 1 == int(rand.Float64()*2) {
		valptr = shr.bufvalue
	} else {
		valptr = nil
	}
	err = shr.gblPctImptp.IncrST(tptoken, &errstr, nil, valptr)
	if imp.CheckErrorReturn(err) {
		return
	}
	err = shr.gblPctImptp.LockDecrST(tptoken, &errstr)
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: ; lfence is used for the fence type of last segment of updates of *ndxarr at the end
	// MCode: ; For non-tp and crash test meaningful application checking is very difficult
	// MCode: ; So at the end of the iteration TP transaction is used
	// MCode: ; For gtcm we cannot use TP at all, because it is not supported.
	// MCode: ; We cannot do crash test for gtcm.
	//
	// MCode: set lfence=istp
	// MCode: if (istp=0)&(crash=1) set lfence=1	; TP fence
	// MCode: if gtcm=1 set lfence=0		; No fence
	lfence := (0 != shr.istp)
	if (0 == shr.istp) && (0 != shr.crash) {
		lfence = true
	}
	if 0 != gtcm {
		lfence = false
	}
	// Set "lfence" M variable
	err = yottadb.SetValE(tptoken, &errstr, imp.BoolStr(lfence), "lfence", []string{})
	if imp.CheckErrorReturn(err) {
		return
	}
	// MCode: if tpnoiso do tpnoiso^imptp
	if 0 != tpnoiso {
		_, err = yottadb.CallMT(tptoken, &errstr, 0, "tpnoiso")
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: if dupset view "GVDUPSETNOOP":1
	if 0 != dupset {
		_, err = yottadb.CallMT(tptoken, &errstr, 0, "dupsetnoop")
		if imp.CheckErrorReturn(err) {
			return
		}
	}
	// MCode: set nroot=1
	// MCode: for J=1:1:jobcnt set nroot=(nroot*root)#prime
	for nroot, i = 1, 1; i <= jobcnt; i = i + 1 {
		nroot = (nroot * root) % prime
	}
	// MCode: ; imptp can be restarted at the saved value of lasti
	//
	// MCode: set lasti=+$get(^lasti(fillid,jobno))
	err = shr.gbllasti.Subary.SetValStr(tptoken, &errstr, 1, fmt.Sprintf("%d", shr.jobno))
	imp.CheckErrorReturn(err)
	err = shr.gbllasti.ValST(tptoken, &errstr, shr.bufvalue)
	if (nil != err) && (yottadb.YDB_ERR_GVUNDEF == yottadb.ErrorCode(err)) {
		lasti = 0
	} else {
		if imp.CheckErrorReturn(err) {
			return
		}
		valstr, err = shr.bufvalue.ValStr(tptoken, &errstr)
		if nil == err {
			valint64, err = strconv.ParseInt(valstr, 10, 32)
			if nil == err {
				lasti = int32(valint64)
			}
		}
		imp.CheckErrorReturn(err)
	}
	// MCode: zwrite lasti
	fmt.Printf("lasti=%d\n", lasti)
	// MCode: ; Initially we have followings:
	// MCode: ; 	Job 1: I=w^0
	// MCode: ; 	Job 2: I=w^1
	// MCode: ; 	Job 3: I=w^2
	// MCode: ; 	Job 4: I=w^3
	// MCode: ; 	Job 5: I=w^4
	// MCode: ;	nroot = w^5 (all job has same value)
	// MCode: set I=1
	// MCode: for J=2:1:jobno  set I=(I*root)#prime
	// MCode: for J=1:1:lasti  set I=(I*nroot)#prime
	shr.I = 1
	for J = 2; J <= shr.jobno; J++ {
		shr.I = int32((int64(shr.I) * int64(root)) % int64(prime))
	}
	for J = 1; J <= lasti; J++ {
		shr.I = int32((int64(shr.I) * int64(nroot)) % int64(prime))
	}
	// MCode: write "Starting index:",lasti+1,!
	fmt.Printf("Starting index:%d\n", lasti+1)
	// MCode: for loop=lasti+1:1:top do  quit:$get(^endloop(fillid),0)
	for shr.loop = lasti + 1; shr.loop <= top; shr.loop++ {
		// Set I and loop M variables (needed by "helper1" call-in code)
		err = shr.bufvalue.SetValStr(tptoken, &errstr, fmt.Sprintf("%d", shr.I))
		if nil == err {
			err = shr.lclI.SetValST(tptoken, &errstr, shr.bufvalue)
		}
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.bufvalue.SetValStr(tptoken, &errstr, fmt.Sprintf("%d", shr.loop))
		if nil == err {
			err = shr.lclloop.SetValST(tptoken, &errstr, shr.bufvalue)
		}
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// MCode: ; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
		// MCode: do pauseifneeded^pauseimptp
		// MCode: set subs=$$^ugenstr(I)		; I to subs  has one-to-one mapping
		// MCode: set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
		// MCode: set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
		// MCode: set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
		// MCode: set valMAX=$j(val,recpad)
		// MCode: set valALT=$select(span>1:valMAX,1:val)
		// MCode: set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
		// MCode: set subsMAX=$j(subs,keypad)
		// MCode: if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
		_, err = shr.callhelper1.CallMDescT(tptoken, &errstr, 0)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// Initialize some local variables for use by later function calls ("tpfnStage1", etc.)
		err = shr.lclI.ValST(tptoken, &errstr, shr.bufI)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.lclsubs.ValST(tptoken, &errstr, shr.bufsubs)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.lclsubsMAX.ValST(tptoken, &errstr, shr.bufsubsMAX)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.lclval.ValST(tptoken, &errstr, shr.bufval)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.lclvalALT.ValST(tptoken, &errstr, shr.bufvalALT)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		err = shr.lclvalMAX.ValST(tptoken, &errstr, shr.bufvalMAX)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// . ; Stage 1
		// . if istp=1 tstart *:(serial:transaction=tptype)
		// Run a block of code as a TP or non-TP transaction based on "istp" variable
		if 0 != shr.istp {
			err = starvar.TpST(tptoken, &errstr, func(tptoken uint64, errstr *yottadb.BufferT) int32 {
				return tpfnStage1(tptoken, errstr, &shr)
			}, tptypestr)
			if imp.CheckErrorReturn(err) {
				if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
				}
				break
			}
		} else {
			rc = tpfnStage1(tptoken, &errstr, &shr)
			if yottadb.YDB_OK != rc {
				if yottadb.YDB_ERR_CALLINAFTERXIT == rc {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error CALLINAFTERXIT")
					break
				}
				panic(fmt.Sprintf("TP transaction (tpfnStage1) failed with rc = %d", rc))
			}
		}
		// MCode: if istp=1 tcommit

		// MCode: . ; Stage 2
		// MCode: . set rndm=$random(10)
		// MCode: . if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
		// MCode: . . set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig)
		// MCode: . . set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms
		// MCode: . . xecute ztrigstr
		// MCode: . . if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error
		// MCode: . . goto:'ztrigret ERROR
		_, err = shr.callhelper2.CallMDescT(tptoken, &errstr, 0)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// MCode: . set ^antp(fillid,subs)=val
		// Note: subscr[0] already has <fillid> value in it
		baryp, err := shr.bufsubs.ValBAry(tptoken, &errstr)
		if nil == err {
			err = shr.gblantp.Subary.SetValBAry(tptoken, &errstr, 1, baryp)
			if nil == err {
				err = shr.gblantp.SetValST(tptoken, &errstr, shr.bufval)
			}
		}
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// MCode: . if 'trigger do
		if 0 == shr.trigger {
			// MCode: . . set ^bntp(fillid,subs)=val
			err = shr.gblbntp.Subary.SetValBAry(tptoken, &errstr, 1, baryp) // baryp still set from above
			if nil == err {
				err = shr.gblbntp.SetValST(tptoken, &errstr, shr.bufval)
			}
			if imp.CheckErrorReturn(err) {
				if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
				}
				break
			}
			// MCode: . . set ^cntp(fillid,subs)=val
			err = shr.gblcntp.Subary.SetValBAry(tptoken, &errstr, 1, baryp) // baryp still set from above
			if nil == err {
				err = shr.gblcntp.SetValST(tptoken, &errstr, shr.bufval)
			}
			if imp.CheckErrorReturn(err) {
				if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
				}
				break
			}
		}
		// MCode: . . set ^dntp(fillid,subs)=valALT
		err = shr.gbldntp.Subary.SetValBAry(tptoken, &errstr, 1, baryp) // baryp still set from above
		if nil == err {
			err = shr.gbldntp.SetValST(tptoken, &errstr, shr.bufval)
		}
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}

		// MCode: . ; Stage 3
		// MCode: . if istp=1 tstart ():(serial:transaction=tptype)
		// Run a block of code as a TP or non-TP transaction based on "istp" variable
		if 0 != shr.istp {
			err = starvar.TpST(tptoken, &errstr, func(tptoken uint64, errstr *yottadb.BufferT) int32 {
				return tpfnStage3(tptoken, errstr, &shr)
			}, tptypestr)
			if imp.CheckErrorReturn(err) {
				if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
				}
				break
			}
		} else {
			rc = tpfnStage3(tptoken, &errstr, &shr)
			if yottadb.YDB_OK != rc {
				if yottadb.YDB_ERR_CALLINAFTERXIT == rc {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error CALLINAFTERXIT")
					break
				}
				panic(fmt.Sprintf("TP transaction (tpfnStage3) failed with rc = %d", rc))
			}
		}
		// MCode: if istp=1 tcommit

		// MCode: . ; Stages 4 thru 11
		// MCode: . ; Stage 4
		// MCode: . for J=1:1:jobcnt D
		// MCode: . . set valj=valALT_J
		// MCode: . . ;
		// MCode: . . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
		// MCode: . . set ^arandom(fillid,subs,J)=valj
		// MCode: . . if 'trigger do
		// MCode: . . . set ^brandomv(fillid,subs,J)=valj
		// MCode: . . . set ^crandomva(fillid,subs,J)=valj
		// MCode: . . . set ^drandomvariable(fillid,subs,J)=valj
		// MCode: . . . set ^erandomvariableimptp(fillid,subs,J)=valj
		// MCode: . . . set ^frandomvariableinimptp(fillid,subs,J)=valj
		// MCode: . . . set ^grandomvariableinimptpfill(fillid,subs,J)=valj
		// MCode: . . . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
		// MCode: . . . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
		// MCode: . . do:dztrig ^imptpdztrig(1,istp<2)
		// MCode: . . if istp=1 tcommit
		// MCode: . . ;
		// MCode: . ; Stage 5
		// MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
		// MCode: . do:dztrig ^imptpdztrig(2,istp<2)
		// MCode: . if ((istp=1)&(crash)) do
		// MCode: . . set rndm=$random(10)
		// MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
		// MCode: . . if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time
		// MCode: . kill ^arandom(fillid,subs,1)
		// MCode: . if 'trigger do
		// MCode: . . kill ^brandomv(fillid,subs,1)
		// MCode: . . kill ^crandomva(fillid,subs,1)
		// MCode: . . kill ^drandomvariable(fillid,subs,1)
		// MCode: . . kill ^erandomvariableimptp(fillid,subs,1)
		// MCode: . . kill ^frandomvariableinimptp(fillid,subs,1)
		// MCode: . . kill ^grandomvariableinimptpfill(fillid,subs,1)
		// MCode: . . kill ^hrandomvariableinimptpfilling(fillid,subs,1)
		// MCode: . . kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
		// MCode: . do:dztrig ^imptpdztrig(1,istp<2)
		// MCode: . do:dztrig ^imptpdztrig(2,istp<2)
		// MCode: . if istp=1 tcommit
		// MCode: . ; Stage 6
		// MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
		// MCode: . zkill ^jrandomvariableinimptpfillprogram(fillid,I)
		// MCode: . if 'trigger do
		// MCode: . . zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
		// MCode: . if istp=1 tcommit
		// MCode: . ; Stage 7 : delimited spanning nodes to be changed in Stage 10
		// MCode: . ; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan
		// MCode: . ; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef
		// MCode: . ;				 		2. ^aspan=^espan and ^bspan is undef
		// MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
		// MCode: . ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
		// MCode: . set piecesize=7
		// MCode: . set valPIECE=valMAX
		// MCode: . set totalpieces=($length(valPIECE)/piecesize)+1
		// MCode: . for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|" ; $extract beyond $length returns a null character
		// MCode: . set totalpieces=$length(valPIECE,"|")
		// MCode: . set ^aspan(fillid,I)=valPIECE
		// MCode: . if 'trigger do
		// MCode: . . set ^espan(fillid,I)=$get(^aspan(fillid,I))
		// MCode: . . set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","")
		// MCode: . if istp=1 tcommit
		// MCode: . ; Stage 8
		// MCode: . kill ^arandom(fillid,subs,1)	; This results nothing
		// MCode: . kill ^antp(fillid,subs)
		// MCode: . if 'trigger do
		// MCode: . . kill ^bntp(fillid,subs)
		// MCode: . . zkill ^brandomv(fillid,subs,1)	; This results nothing
		// MCode: . . zkill ^cntp(fillid,subs)
		// MCode: . . zkill ^dntp(fillid,subs)
		// MCode: . kill ^bntp(fillid,subsMAX)
		// MCode: . if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
		// MCode: . ; Stage 9
		// MCode: . ; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
		// MCode: . set flag=$random(2)
		// MCode: . if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
		// MCode: . set cntloop=$incr(^cntloop(fillid))
		// MCode: . set cntseq=$incr(^cntseq(fillid),(13+jobcnt))
		// MCode: . if flag=1,lfence=1 tcommit
		// MCode: . ; Stage 10 : More SET $piece
		// MCode: . ; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece)
		// MCode: . ; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece
		// MCode: . ; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan
		// MCode: . ;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
		// MCode: . ;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
		// MCode: . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
		// MCode: . set targetpiece=(loop#(totalpieces))
		// MCode: . set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X")
		// MCode: . zkill ^espan(fillid,I)
		// MCode: . set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece
		// MCode: . if 'trigger do
		// MCode: . . set $piece(^espan(fillid,I),"|",targetpiece)=subpiece
		// MCode: . . set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece
		// MCode: . if istp=1 tcommit
		// MCode: . ; Stage 11
		// MCode: . if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
		// MCode: . do:dztrig ^imptpdztrig(1,istp<2)
		// MCode: . xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole="""""
		// MCode: . set ^andxarr(fillid,jobno,loop)=I
		// MCode: . if 'trigger do
		// MCode: . . set ^bndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^cndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^dndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^endxarr(fillid,jobno,loop)=I
		// MCode: . . set ^fndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^gndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^hndxarr(fillid,jobno,loop)=I
		// MCode: . . set ^indxarr(fillid,jobno,loop)=I
		// MCode: . if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
		// MCode: . if lfence=1 tcommit
		_, err = shr.callhelper3.CallMDescT(tptoken, &errstr, 0)
		if imp.CheckErrorReturn(err) {
			if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
				fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
			}
			break
		}
		// MCode: . set I=(I*nroot)#prime
		shr.I = int32((int64(shr.I) * int64(nroot)) % int64(prime))
		// MCode: quit:$get(^endloop(fillid),0)
		err = shr.gblendloop.ValST(tptoken, &errstr, shr.bufvalue)
		if nil != err {
			if yottadb.YDB_ERR_GVUNDEF == yottadb.ErrorCode(err) {
				continue
			}
			if imp.CheckErrorReturn(err) {
				if yottadb.YDB_ERR_CALLINAFTERXIT != yottadb.ErrorCode(err) {
					fmt.Fprintln(os.Stderr, "IMPJOBGO: Stopping due to error:", err)
				}
				break
			}
		}
		valstr, err = shr.bufvalue.ValStr(tptoken, &errstr)
		imp.CheckErrorReturn(err)
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		if 0 != valint64 {
			break
		}
	} // MCode: ; End FOR loop
	// MCode: write "End index:",loop,!
	fmt.Printf("End index:%d\n", shr.loop)
	// MCode: write "Job completion successful",!
	fmt.Println("Job completion successful")
	// MCode: write "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	fmt.Println("End Time :", time.Now().Format("02-Jan-2006 03:04:05.000"))
	return
}

// tpfnStage1 is the stage 1 TP callback routine
func tpfnStage1(tptoken uint64, errstr *yottadb.BufferT, shr *shareStuff) int32 {
	var rndm int32
	var dollartrestart int32
	var valint64 int64
	var valstr string

	// MCode: . set ^arandom(fillid,subsMAX)=val
	baryp, err := shr.bufsubsMAX.ValBAry(tptoken, errstr)
	if nil == err {
		err = shr.gblarandom.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblarandom.SetValST(tptoken, errstr, shr.bufval)
		}
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetElemUsed(tptoken, errstr, 2) // Only use 2 subscripts at first
	imp.CheckErrorReturn(err)
	if (0 != shr.istp) && (0 != shr.crash) {
		// MCode: . . set rndm=$r(10)
		rndm = int32(rand.Float64() * 10)
		// MCode: . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
		err = shr.dlrTRESTART.ValST(tptoken, errstr, shr.bufvalue)
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		valstr, err = shr.bufvalue.ValStr(tptoken, errstr)
		imp.CheckErrorReturn(err)
		valint64, err = strconv.ParseInt(valstr, 10, 32)
		imp.CheckErrorReturn(err) // Only panic-able errors should hit here
		dollartrestart = int32(valint64)
		if 2 < dollartrestart {
			if 1 == rndm {
				_, err = shr.callnoop.CallMDescT(tptoken, errstr, 0)
				if imp.CheckErrorReturn(err) {
					return int32(yottadb.ErrorCode(err))
				}
			}
			// MCode: . . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
			if 2 == rndm {
				rndm = int32(rand.Float64() * 10)
				time.Sleep(time.Duration(rndm) * time.Second)
			}
		}
		// MCode: . . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow
		if 0 != dollartrestart {
			err = shr.gblzdummy.Subary.SetValStr(tptoken, errstr, 0, valstr) // valstr still has $ZRESTART value from above
			if nil == err {
				err = shr.bufvalue.SetValStr(tptoken, errstr, fmt.Sprintf("%d", shr.jobno)) // set up value to store
				if nil == err {
					err = shr.gblzdummy.SetValST(tptoken, errstr, shr.bufvalue)
				}
			}
			if imp.CheckErrorReturn(err) {
				return int32(yottadb.ErrorCode(err))
			}
		}
	}
	// MCode: . set ^brandomv(fillid,subsMAX)=valALT
	err = shr.gblbrandomv.Subary.SetValBAry(tptoken, errstr, 1, baryp) // baryp still points to subsMAX from above
	if nil == err {
		err = shr.gblbrandomv.SetValST(tptoken, errstr, shr.bufvalALT)
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	if 0 == shr.trigger {
		// MCode: . . set ^crandomva(fillid,subsMAX)=valALT
		err = shr.gblcrandomva.Subary.SetValBAry(tptoken, errstr, 1, baryp) // baryp still points to subsMAX from above
		if nil == err {
			err = shr.gblcrandomva.SetValST(tptoken, errstr, shr.bufvalALT)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	// MCode: . set ^drandomvariable(fillid,subs)=valALT
	baryp, err = shr.bufsubs.ValBAry(tptoken, errstr) // baryp now points to subs
	if nil == err {
		err = shr.gbldrandomvariable.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gbldrandomvariable.SetValST(tptoken, errstr, shr.bufvalALT)
		}
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	if 0 == shr.trigger {
		// MCode: . . set ^erandomvariableimptp(fillid,subs)=valALT
		err = shr.gblerandomvariableimptp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblerandomvariableimptp.SetValST(tptoken, errstr, shr.bufvalALT)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		// MCode: . . set ^frandomvariableinimptp(fillid,subs)=valALT
		err = shr.gblfrandomvariableinimptp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblfrandomvariableinimptp.SetValST(tptoken, errstr, shr.bufvalALT)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	// MCode: . set ^grandomvariableinimptpfill(fillid,subs)=val
	err = shr.gblgrandomvariableinimptpfill.Subary.SetValBAry(tptoken, errstr, 1, baryp)
	if nil == err {
		err = shr.gblgrandomvariableinimptpfill.SetValST(tptoken, errstr, shr.bufval)
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	if 0 == shr.trigger {
		// MCode: . . set ^hrandomvariableinimptpfilling(fillid,subs)=val
		err = shr.gblhrandomvariableinimptpfilling.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblhrandomvariableinimptpfilling.SetValST(tptoken, errstr, shr.bufval)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		// MCode: . . set ^irandomvariableinimptpfillprgrm(fillid,subs)=val
		err = shr.gblirandomvariableinimptpfillprgrm.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblirandomvariableinimptpfillprgrm.SetValST(tptoken, errstr, shr.bufval)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	} else {
		// MCode: . if trigger xecute ztwormstr	; fill in $ztwormhole for below update that requires "subs"
		_, err = shr.callztwormstr.CallMDescT(tptoken, errstr, 0)
		if nil != err {
			if imp.CheckErrorReturn(err) {
				return int32(yottadb.ErrorCode(err))
			}
		}
	}
	// MCode: . set ^jrandomvariableinimptpfillprogram(fillid,I)=val
	barypsubs := baryp                             // save pointer to subs buffer as we may need it later
	baryp, err = shr.bufI.ValBAry(tptoken, errstr) // baryp now points to I
	if nil == err {
		err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gbljrandomvariableinimptpfillprogram.SetValST(tptoken, errstr, shr.bufval)
		}
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	if 0 == shr.trigger {
		// MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val
		err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetValBAry(tptoken, errstr, 2, baryp)
			if nil == err {
				err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetElemUsed(tptoken, errstr, 3) // Use 3 subscripts now
				if nil == err {
					err = shr.gbljrandomvariableinimptpfillprogram.SetValST(tptoken, errstr, shr.bufval)
				}
			}
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		// MCode: . . set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val
		err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetValBAry(tptoken, errstr, 3, barypsubs)
		if nil == err {
			err = shr.gbljrandomvariableinimptpfillprogram.Subary.SetElemUsed(tptoken, errstr, 4) // Use 4 subscripts now
			if nil == err {
				err = shr.gbljrandomvariableinimptpfillprogram.SetValST(tptoken, errstr, shr.bufval)
			}
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	// MCode: . if istp'=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
	if 0 != shr.istp {
		if shr.ztr {
			_, err = shr.callztrcmd.CallMDescT(tptoken, errstr, 0)
			if nil != err {
				if imp.CheckErrorReturn(err) {
					return int32(yottadb.ErrorCode(err))
				}
			}
		}
		err = shr.bufvalue.SetValStr(tptoken, errstr, fmt.Sprintf("%d", shr.loop))
		if nil == err {
			err = shr.gbllasti.SetValST(tptoken, errstr, shr.bufvalue)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	return yottadb.YDB_OK
}

// tpfnStage3 is the stage 3 TP callback routine
func tpfnStage3(tptoken uint64, errstr *yottadb.BufferT, shr *shareStuff) int32 {
	var err error

	// MCode: . do:dztrig ^imptpdztrig(2,istp<2)
	if shr.dztrig {
		_, err = shr.callimptpdztrig.CallMDescT(tptoken, errstr, 0)
		if nil != err {
			if imp.CheckErrorReturn(err) {
				return int32(yottadb.ErrorCode(err))
			}
		}
	}
	// MCode: . set ^entp(fillid,subs)=val
	baryp, err := shr.bufsubs.ValBAry(tptoken, errstr) // baryp now points to subs var value
	if nil == err {
		err = shr.gblentp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblentp.SetValST(tptoken, errstr, shr.bufval)
		}
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	err = shr.gblfntp.Subary.SetValBAry(tptoken, errstr, 1, baryp) // Fill in 2nd subscript (subs) for both paths below
	imp.CheckErrorReturn(err)
	if 0 == shr.trigger {
		// MCode: . . set ^fntp(fillid,subs)=val
		err = shr.gblfntp.SetValST(tptoken, errstr, shr.bufval)
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	} else {
		// MCode: . . set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix"))
		err = shr.gblfntp.ValST(tptoken, errstr, shr.bufvalue) // Fetch current value ^fntp(fillid,subs)
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		vallen, err := shr.bufvalue.LenUsed(tptoken, errstr)
		imp.CheckErrorReturn(err)
		if 6 <= vallen { // 6 == $length("suffix")
			vallen = vallen - 6
		} else {
			if 0 == shr.istp { // Should only be possible in TP and is a restartable condition then
				panic("Value less than 6 bytes and not using TP")
			}
			return yottadb.YDB_TP_RESTART
		}
		err = shr.bufvalue.SetLenUsed(tptoken, errstr, vallen)
		if nil == err {
			err = shr.gblfntp.SetValST(tptoken, errstr, shr.bufvalue)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	// MCode: . set ^gntp(fillid,subsMAX)=valMAX
	baryp, err = shr.bufsubsMAX.ValBAry(tptoken, errstr) // baryp now point to subsMAX var value
	if nil == err {
		err = shr.gblgntp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblgntp.SetValST(tptoken, errstr, shr.bufvalMAX)
		}
	}
	if imp.CheckErrorReturn(err) {
		return int32(yottadb.ErrorCode(err))
	}
	// MCode: . if 'trigger do
	if 0 == shr.trigger {
		// MCode: . . set ^hntp(fillid,subsMAX)=valMAX
		err = shr.gblhntp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblhntp.SetValST(tptoken, errstr, shr.bufvalMAX)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		// MCode: . . set ^intp(fillid,subsMAX)=valMAX
		err = shr.gblintp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblintp.SetValST(tptoken, errstr, shr.bufvalMAX)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
		// MCode: . . set ^bntp(fillid,subsMAX)=valMAX
		err = shr.gblbntp.Subary.SetValBAry(tptoken, errstr, 1, baryp)
		if nil == err {
			err = shr.gblbntp.SetValST(tptoken, errstr, shr.bufvalMAX)
		}
		if imp.CheckErrorReturn(err) {
			return int32(yottadb.ErrorCode(err))
		}
	}
	return yottadb.YDB_OK
}
