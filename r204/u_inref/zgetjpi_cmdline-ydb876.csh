#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test to make sure that the $ZgetJPI function with the keyword cmdline works
# $ZGETJPI(PID,"cmdline") should return the command line of the process with PID (or the current process if PID=0)
# Test the standard case as well as edge cases of 1024 chars and >1024 chars
# Tests that it works with a function that alters its own command line to end in a space
# The function only returns the first 1024 chars of the command line (typically small but potentially big)
echo '# Test that running $ZGETJPI with the keyword CMDLINE gives the command line of process'
echo
#these lined create a string of 999 or 1000 copies of the char "9"
set nine999 = `printf '%*s' 999 '' | tr ' ' 9`
set nine1000 = `printf '%*s' 1000 '' | tr ' ' 9`
echo "# Starting background process to get their command lines"
echo "# Starting process with small command line"
(sh -c "sleep 15 && echo '9'" & ; echo $! >&! sleep0.pid) >&! sleep0.outx
echo "# Starting process with exactly 1024 length command line"
(sh -c "sleep 15 && echo '${nine999}'" & ; echo $! >&! sleep1.pid) >&! sleep1.outx
echo "# Starting process with more than 1024 length command line"
(sh -c "sleep 15 && echo '${nine1000}'" & ; echo $! >&! sleep2.pid) >&! sleep2.outx
set smallpid = `cat sleep0.pid`
set exact1024pid = `cat sleep1.pid`
set exact1025pid = `cat sleep2.pid`
echo
echo '# Now testing $ZGETJPI'
echo "# Running with small command line"
$gtm_dist/mumps -run %XCMD 'write $zgetjpi('$smallpid',"cmdline")'
echo "# And the zlength of that output is"
$gtm_dist/mumps -run %XCMD 'write $ZLength($zgetjpi('$smallpid',"cmdline"))'
echo "# Running with exactly 1024 len command line"
$gtm_dist/mumps -run %XCMD 'write $zgetjpi('$exact1024pid',"cmdline")'
echo "# And the zlength of that output is"
$gtm_dist/mumps -run %XCMD 'write $ZLength($zgetjpi('$exact1024pid',"cmdline"))'
echo "# Running with over 1024 len command line. is exactly length 1025, the cutoff char at the end is a single quote"
$gtm_dist/mumps -run %XCMD 'write $zgetjpi('$exact1025pid',"cmdline")'
echo "# And the zlength of that output is"
$gtm_dist/mumps -run %XCMD 'write $ZLength($zgetjpi('$exact1025pid',"cmdline"))'
echo "# Running with nonexistent PID -1"
echo
$gtm_dist/mumps -run %XCMD 'write $zgetjpi(-1,"cmdline")'
echo "# Killing background processes"
kill $exact1024pid
kill $exact1025pid
kill $smallpid
$gtm_tst/com/wait_for_proc_to_die.csh $exact1024pid
$gtm_tst/com/wait_for_proc_to_die.csh $exact1025pid
$gtm_tst/com/wait_for_proc_to_die.csh $smallpid
#
# This section test PID=0
#
echo
echo "# Now testing PID=0, this should give the PID of the current YottaDB process"
($gtm_dist/mumps -run %XCMD 'hang 10' & ; echo $! >&! gtmbk.pid) >&! gtmbk.outx
set bgpid = `cat gtmbk.pid`
$GTM << END
write \$zgetjpi(0,"cmdline")
END
echo "# Shutting down YottaDB process"
$gtm_dist/mupip stop $bgpid
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
echo
echo "# Trying out all PID's to make sure that none produce an error, this will not output anything."
echo
(find /proc -maxdepth 1 -type d -regex '/proc/[0-9]+' -printf "%f\n" | $gtm_dist/mumps -run %XCMD 'for  read pid quit:$zeof  write "Pid = ",pid," : Command line = ",$zgetjpi(pid,"cmdline"),!') >&! allPID.outx
#
#
# This section is testing with a space at the end of the command line
# ydb876.c replaces the 1 in the arguments area of the command line with a space
set file = ydb876
echo
echo "# In this section, we will compile a c program that will edit it's own command line to end with a space"
echo "# Build a C program "
$gt_cc_compiler $gtt_cc_shl_options -I$ydb_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
echo "# Run the compiled ydb876.c program:"
($PWD/$file 1 & ; echo $! >&! cpro.pid)  >&! cpro.outx
set cpid = `cat cpro.pid`
sleep .5
echo "# Getting the CMDLINE"
$gtm_dist/mumps -run %XCMD 'write $zgetjpi('$cpid',"cmdline")'
kill $cpid
$gtm_tst/com/wait_for_proc_to_die.csh $cpid
echo "# Test is done."
