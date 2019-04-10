#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of all simpleapi functions in a nested called (c -> m -> c)
# See externalcall.c for a description of how this test works.
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour

echo '# test of all SimpleAPI and Utility functions on a nestedcall (c -> m -> c)'
echo '# each function is ran, checked that it worked properly then prints either a pass or fail'

#SETUP of the driver C file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/externalcallD.c
$gt_ld_linker $gt_ld_option_output externalcallD $gt_ld_options_common externalcallD.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& externalcall.map

setenv GTMCI `pwd`/externalcall.tab
echo $GTMCI
cat >> externalcall.tab << xx
mSet: void mSet^externalcallHb()
mData: void mData^externalcallHb()
mGet: void mGet^externalcallHb()
mIncr: void mIncr^externalcallHb()
mNodeNext: void mNodeNext^externalcallHb()
mNodePrev: void mNodePrev^externalcallHb()
mStr2zwr: void mStr2zwr^externalcallHb()
mZwr2str: void mZwr2str^externalcallHb()
mSubNext: void mSubNext^externalcallHb()
mSubPrev: void mSubPrev^externalcallHb()
mDelete: void mDelete^externalcallHb()
mDeleteExcl: void mDeleteExcl^externalcallHb()
mTp: void mTp^externalcallHb()
mLock: void mLock^externalcallHb()
mLockIncr: void mLockIncr^externalcallHb()
mLockDecr: void mLockDecr^externalcallHb()
mFileid: void mFileid^externalcallHb()
mFileIdent: void mFileIdent^externalcallHb()
mFileFree: void mFileFree^externalcallHb()
mFNC: void mFNC^externalcallHb()
mHiber: void mHiber^externalcallHb()
mHiberW: void mHiberW^externalcallHb()
mMal: void mMal^externalcallHb()
mFree: void mFree^externalcallHb()
mMsg: void mMsg^externalcallHb()
mMT: void mMT^externalcallHb()
mTimerS: void mTimerS^externalcallHb()
mTimerC: void mTimerC^externalcallHb()
mExit: void mExit^externalcallHb()
mCi: void mCi^externalcallHb()
mCip: void mCip^externalcallHb()
mCiHelper: void mCiHelper^externalcallHb()
mCiTab: void mCiTab^externalcallHb()
mCiSwitch: void mCiSwitch^externalcallHb()
xx

cat >> externalcallSwtich.tab << xxxx
mSwitchHelper: void mSwitchHelper^externalcallHb()
xxxx
#SETUP of the helper C file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/externalcallH.c
$gt_ld_shl_linker ${gt_ld_option_output}externalcallH${gt_ld_shl_suffix} $gt_ld_shl_options externalcallH.o $gt_ld_syslibs

setenv GTMXC `pwd`/externalcall.xc
cat >> externalcall.xc << xxx
`pwd`/externalcallH.so
cSet: int cSet()
cData: int cData()
cGet: int cGet()
cIncr: int cIncr()
cNodeNext: int cNodeNext()
cNodePrev: int cNodePrev()
cStr2zwr: int cStr2zwr()
cZwr2str: int cZwr2str()
cSubNext: int cSubNext()
cSubPrev: int cSubPrev()
cDelete: int cDelete()
cDeleteExcl: int cDeleteExcl()
cTp: int cTp()
cLock: int cLock()
cLockIncr: int cLockIncr()
cLockDecr: int cLockDecr()
cFileid: int cFileid()
cFileIdent: int cFileIdent()
cFileFree: int cFileFree()
cFNC: int cFNC()
cHiber: int cHiber()
cHiberW: int cHiberW()
cMal: int cMal()
cFree: int cFree()
cMsg: int cMsg()
cMT: int cMT()
cTimerS: int cTimerS()
cTimerC:void cTimerC()
cExit: int cExit()
cCi: int cCi()
cCip: int cCip()
cCiTab: int cCiTab()
cCiSwitch: int cCiSwitch()
xxx

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096 -record_size=4000 -key_size=1019 -glob=8192

# Run driver C
./externalcallD

# ydb_fork_n_core check
if ($tst_image == 'pro') then
	ls -1 core* >& /dev/null
	if($status != 0) then
		echo "ydb_fork_n_core(): FAIL"
	else
		echo "ydb_fork_n_core(): PASS"
		rm -f core*
	endif
endif


$gtm_tst/com/dbcheck.csh
