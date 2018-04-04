#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Don't use an existing screen instance
unsetenv STY

# Execute the test
expect -f $gtm_tst/$tst/inref/terminal.exp >& terminal.out

# Clean up the output - remove '\r', the first line and last two lines as they contain terminal garbage that varies
cat terminal_expect.log | $gtm_dist/mumps -run LOOP^%XCMD --xec=';write:(%NR>1)&(%NR<54) $tr(%l,$char(13),""),!;'

$echoline
echo "Step 4 - print the zshow output from terminal.m"
$tst_awk '/YDB-E-DEVPARMNEG/{sub(/-E-/,"-X-")} /^.dev/{sub(/^.dev[^ ]+ /,"/dev/tty ")} /Test 7/{x++}/LENG=/{if(x=="")sub(/-?[0-9]+ $/,"XX ")} {print}' zshow.outx

# Step 5 was moved to test/expect/u_inref/terminal5.csh since it relies on screen

$echoline
echo 'Step 6 - another terminal test (expect to see "$Y:1" and "$Y:9999")'
expect -f $gtm_tst/$tst/inref/terminal6.exp >& terminal6.outx
cat terminal6.outx |& $gtm_dist/mumps -run LOOP^%XCMD \
	--xec=';write:%l["$Y should be" (%NR-1),":",$tr(%l2,$char(13)),$char(10),%NR,":",$tr(%l,$char(13)),$char(10) set %l2=%l;'

$echoline
echo "Step 7 - writing 35000 bytes should not error out"
expect -f $gtm_tst/$tst/inref/terminal7.exp >& terminal7.out
$grep -q "spawn id" terminal7.out && echo "expect error in terminal7.out"
