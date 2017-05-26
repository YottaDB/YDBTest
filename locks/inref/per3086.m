; Test garbage collection for M locks 
; 
; This is a regression test for PER 3086 (MUMPS process waiting on nonexistant
; lock - UNIX only).
; 
; Due to a bug in mlk_lock.c, a mumps process would not garbage collect the 
; lock space if a lock entry exceeded the free lock space by one byte.
; This resulted in a mumps job waiting for the lock indefinitely (or until
; the timed lock ran out).
;
; NOTE: For this test to function properly a GT.M database must be created
;       with a lock space of 40 blocks (which is the default).
;
per3086
	l +^XQ(1)
	l -^XQ(1)
	f i=1000:1:1214 Do
	. l +^XQ(i)
	. l -^XQ(i)
	l +^XQ(12341234567890):5
	i $T w "per3086 - PASSED",!
	e  w "per3086 - FAILED",!
	q
