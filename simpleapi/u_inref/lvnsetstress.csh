#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

unsetenv gtmdbglvl # or else test runs for too long

#
# Stress test of ydb_set_s() function for Local variables in the simpleAPI
#
cat > lvnset.xc << CAT_EOF
driveZWRITE: void driveZWRITE(I:ydb_string_t *)
CAT_EOF

setenv GTMCI lvnset.xc	# needed to invoke driveZWRITE.m from lvnset*.c below

echo "Generate genlvnsetstress.m and genlvnsetstress.c that each do LOTS of SETs of lvns"
# The below M program generates a C program that takes up huge amounts of memory and can cause the system to go down.
# So limit the size of that based on available memory.
# Pass the current total memory on the system in the command line.
# Let the M program figure out the maximum size of the generated C program.
set totMemInKb = `grep MemTotal /proc/meminfo | $tst_awk '{print $2}'`
$gtm_dist/mumps -run lvnsetstress $totMemInKb

set file = "genlvnsetstress.c"
echo " --> Running $file <---"
set exefile = $file:r
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
if (0 != $status) then
	echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	continue
endif
`pwd`/$exefile | grep -v zwrarg >& $exefile.log
mv $exefile.o $exefile.c.o	# move it away for the M program (of the same name) to be compiled and a .o created
				# or else an INVOBJFILE error would be issued (due to unexpected format)

# Set M-stack size to maximum possible value (10,000 KiB). This is needed as we have seen the "mumps -run genlvnsetstress"
# command fail rarely with a %YDB-E-STACKCRIT error at startup because the generated M file "genlvnsetstress.m" has approximately
# 32,558 lines each (possible on systems with RAM/memory of 64GiB) of which sets a different M variable name resulting in a
# variable-table length requirement (in the M-stack frame at process startup) of approximately 32K * 8 bytes = 256KiB that is
# close to the default M stack size of 272Kib. Setting the M stack size to 10,000 KiB is bumping it 40 times and so that should
# keep us completely away from the STACKCRIT error zone.
setenv gtm_mstack_size "10000"
$gtm_dist/mumps -run genlvnsetstress >& $exefile.cmp

diff $exefile.cmp $exefile.log >& $exefile.diff
if ($status) then
	echo "LVNSETSTRESS-E-FAIL : diff $exefile.cmp $exefile.log returned non-zero status. See $exefile.diff for details"
else
	echo "PASS from lvnsetstress"
endif

