; Helper M code which calls the C code
; Only logic this does is checking the first set call


mSet
	do &cSet()
	if ^a=42 write "PASS",!
	else  write "FAIL",!
	use $p
	quit

mData
	do &cData()
	quit

mGet
	do &cGet()
	quit

mIncr
	do &cIncr()
	quit

mNodeNext
	do &cNodeNext()
	quit

mNodePrev
	do &cNodePrev()
	quit	

mStr2zwr
	do &cStr2zwr()
	quit

mZwr2str
	do &cZwr2str
	quit

mSubNext
	do &cSubNext
	quit

mSubPrev
	do &cSubPrev
	quit

mDelete
	do &cDelete
	quit

mDeleteExcl
	set local="This is a local"
	do &cDeleteExcl
	quit

mTp
	do &cTp
	quit

mLock
	do &cLock
	quit

mLockIncr
	do &cLockIncr
	quit

mLockDecr
	do &cLockDecr
	quit

mFileid
	do &cFileid
	quit

mFileIdent
	do &cFileIdent
	quit

mFileFree
	do &cFileFree
	quit

mFNC
	do &cFNC
	quit

mHiber
	do &cHiber
	quit

mHiberW
	do &cHiberW
	quit

mMal
	do &cMal
	quit

mFree
	do &cFree
	quit

mMsg
	do &cMsg
	quit

mMT
	do &cMT
	quit

mTimerS
	do &cTimerS
	quit

mTimerC
	do &cTimerC
	quit

mExit
	do &cExit
	quit

mCi
	do &cCi
	quit

mCip
	do &cCip
	quit

mCiHelper
	write "PASS",!
	use $p
	quit

mCiTab
	do &cCiTab
	quit

mCiSwitch
	do &cCiSwitch
	quit

mSwitchHelper
	write "PASS",!
	use $p
	quit
