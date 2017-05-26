#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_repl_norepl 1
setenv gtm_test_spanreg 0
$gtm_tst/com/dbcreate.csh mumps 9 255 2048 4096

$GDE << gde_eof
change -region GREG -std
change -region HREG -std
add -name gglobal(1:100) -reg=HREG
gde_eof

$gtm_exe/mumps -run jnlnojnl

echo "# extract of g.mjl should have records from ^gglobal(100) since 1:100 goes to HREG"
set gmjl = `ls g.mjl*`
set gmjl = `echo $gmjl | sed 's/ /,/'`
$MUPIP journal -extract -forw $gmjl >&! gmjl_extract.out
$tst_awk -F \\ '/^05/ {print $NF ; exit}' g.mjf

echo "# extract of h.mjl should be empty since HREG is not journaled"
set hmjl = `ls h.mjl*`
set hmjl = `echo $hmjl | sed 's/ /,/'`
$MUPIP journal -extract -forw $hmjl >&! hmjl_extract.out
$grep "^05" h.mjf


$gtm_tst/com/dbcheck.csh -extract
