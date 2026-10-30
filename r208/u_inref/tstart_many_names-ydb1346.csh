#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1346] A TSTART that names 6 or more local variables restores all of them on a restart        #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A TSTART passes the names of the local variables to restore on a restart to op_tstart() through'
echo '# opp_tstart. On AARCH64, the first 5 names fit in registers and the 6th and later ones are on the'
echo '# stack. opp_tstart read those from the wrong place, so on AARCH64 a TSTART with 6 or more names'
echo '# terminated with a SIG-11 (YottaDB r2.04 and later) or did not restore the 6th variable on a restart'
echo '# (r2.02 and earlier). Other platforms were not affected.'
echo '# Each stage runs its case in a new process. The case sets v1 to v<n> to 1, does a TSTART that names'
echo '# them, sets them to 2 and does a TRESTART, then prints PASS if the restart restored all of them to 1,'
echo '# or WRONG for each one that it did not restore.'
echo

cp $gtm_tst/$tst/inref/ydb1346.m .

set stage = 0
foreach label (low t6 t7 t8 t9 t16 t31)
	@ stage++
	switch ($label)
	case "low":
		echo "# Stage $stage : TSTART with 1, 2, 3, 4 and 5 names, which all fit in registers"
		echo '# Before the fix : the same result (these cases are controls)'
		echo '# With the fix   : expect PASS for each'
		breaksw
	case "t6":
		echo "# Stage $stage : TSTART with 6 names, the 6th on the stack"
		echo '# Before the fix : on AARCH64, a SIG-11 in a Release build, and an assert in op_tstart.c in a Debug'
		echo '#                  build'
		echo '# With the fix   : expect PASS'
		breaksw
	default:
		set n = `echo $label | sed 's/^t//'`
		echo "# Stage $stage : TSTART with $n names"
		echo '# Before the fix : on AARCH64, a SIG-11 in a Release build, and an assert in op_tstart.c in a Debug'
		echo '#                  build'
		echo '# With the fix   : expect PASS'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1346'
	$gtm_dist/mumps -run $label^ydb1346
	echo
end

@ stage++
echo "# Stage $stage : the same in Direct Mode, with 6 and with 9 names"
echo '# Before the fix : on AARCH64, a SIG-11 in a Release build. In a Debug build, the restart did not'
echo '#                  restore v6 with 6 names, and an assert in op_tstart.c failed with 9 names'
echo '# With the fix   : expect PASS for each'
cat > dmode.inp << CAT_EOF
set (v1,v2,v3,v4,v5,v6)=1
tstart (v1,v2,v3,v4,v5,v6)  if \$trestart=0 set (v1,v2,v3,v4,v5,v6)=2 trestart
do check^ydb1346(6)
tcommit
set (v1,v2,v3,v4,v5,v6,v7,v8,v9)=1
tstart (v1,v2,v3,v4,v5,v6,v7,v8,v9)  if \$trestart=0 set (v1,v2,v3,v4,v5,v6,v7,v8,v9)=2 trestart
do check^ydb1346(9)
tcommit
CAT_EOF
echo '# Command : $gtm_dist/mumps -direct < dmode.inp'
$gtm_dist/mumps -direct < dmode.inp |& grep -v '^$' | grep -v '^\(YDB\|GTM\)>$'
echo
echo "# Done"
