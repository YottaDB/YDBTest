#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This test case provides regression support that validates that call-ins can
# use the JOB command and call gtmsecshr as needed.
#
# The tricky part with call-ins is that the external excutable dynamically
# links to libgtmshr.so.  This means that the call-in code does not have an
# argv[0] or other means like /proc to use to validate that $gtm_dist points to
# the same location as libgtmshr.so.
#
# Previously, the call-in code simply copied $gtm_dist from the environment
# without any validation. The improvement sends a syslog message when $gtm_dist
# is undefined or too long. If the code invokes the JOB command or gtmsecshr,
# then failures ensue with messaging that makes sense.
#

#
# How to invoke gtmsecshr aka callers of send_mesg2gtmsecshr()
#
# - Read-only database file
#	gds_rundown()
#	db_ipcs_reset()
#	db_init()
#	mu_rndwn_file()
# - M lock wake-up (currently disabled)
#	crit_wake()
# - Continue process belonging to another user
#	continue_proc()
# - Remove semid
#	REMIPC() via sem_rmid() or shm_rmid()
# - Clean up mutex socket file only on non MSEM platforms
#	mutex_sock_init()
#

set origpath=($path)
set path=($PWD $gtm_dist $path)

$gtm_tst/com/dbcreate.csh mumps 1

setenv GTMCI callin.tab
cat >> $GTMCI << callin
job7926     : void job^gtm7926callins()
iopi7926    : void iopi^gtm7926callins()
secshr7926  : void secshr^gtm7926callins()
callin

# Build the C programs
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtm7926callinproxy.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output gtm7926callinproxy $gt_ld_options_common gtm7926callinproxy.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
ln gtm7926callinproxy job7926
ln gtm7926callinproxy secshr7926
ln gtm7926callinproxy iopi7926

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map

#
# Test the JOB command execution with the correct and incorrect (null or invalid) $gtm_dist
#
echo "This will not generate an error"
job7926
echo "This will generate an undef error"
env gtm_dist= job7926
echo "This will generate a syscall error"
env gtm_dist=/no/such/path job7926 |& sed 's/ -- .*$//'

#
# Test the default search path for PIPE device execution with the correct and incorrect (null or invalid) $gtm_dist
#
echo "This will not generate an error"
iopi7926
echo "This will generate an undef error"
env gtm_dist= iopi7926
echo "This will generate a syscall error"
env gtm_dist=/no/such/path iopi7926 |& sed 's/ -- .*$//'

#
# Test the access to gtmsecshr with the correct and incorrect (null or invalid) $gtm_dist
#
echo "This will not generate an error"
secshr7926
echo "This will generate an undef error"
env gtm_dist= secshr7926
echo "This will generate a syscall error"
env gtm_dist=/no/such/path secshr7926 |& sed 's/ -- .*$//'

# Restore prior settings
unsetenv $GTMCI
set path=($path)

$gtm_tst/com/dbcheck.csh

