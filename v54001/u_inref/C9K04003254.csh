#! /usr/local/bin/tcsh -f
# C9K04003254 - create 10 jobs which make identical changes to the database in a loop for 30 sec.
# The changes along with a view "jnlflush" will be enclosed by a transaction" 

echo ENTERING C9K04003254 test

setenv gtm_test_jnl "SETJNL"

$gtm_tst/com/dbcreate.csh mumps 1

cat << EOF  > viewjnlflush.m
	set ^done=0
	set jmaxwait=0
	set jdetach=1
	do ^job("child^viewjnlflush",10,"""""")
	; timeout after 30 sec
	hang 30
	set ^done=1
	do wait^job
	quit
child
	for  quit:^done  do
	. tstart ():(serial:transaction="BATCH")
	. set (^a,^b,^c,^d,^e)=1
	. view "jnlflush"
	. tcommit
	quit
EOF

$gtm_exe/mumps -run viewjnlflush

$gtm_tst/com/dbcheck.csh -extract mumps

echo LEAVING C9K04003254 test
