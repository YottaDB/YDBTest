#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that password prompting and recovery happens in all kinds of gtm_passwd states both inside and outside of DIRECT MODE

# Do a minimal setup
# Create a database with one region.
$gtm_tst/com/dbcreate.csh mumps
# Write a global
$GTM << EOF
s ^a="THIS_VAR_IS_ENCRYPTED"
EOF

# Since we will be modifying the environment variable gtm_passwd take a backup
setenv gtm_passwd_masked $gtm_passwd

# Set wrong password to be later used by external call - setWrongPasswd
setenv gtm_wrong_passwd_masked `echo badpasswd | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`

# Compile the external call program
cp $gtm_tst/$tst/inref/passwd_external_call.c .
$gt_cc_compiler $gtt_cc_shl_options passwd_external_call.c >&! compile.out
$gt_ld_shl_linker ${gt_ld_option_output}libpasswdxc${gt_ld_shl_suffix} $gt_ld_shl_options passwd_external_call.o >&! link.map

# Create the .xc file for the external call
cat >> passwd_external_call.xc << EOF
./libpasswdxc${gt_ld_shl_suffix}
setCorrectPasswd: xc_status_t setCorrectPasswd()
setWrongPasswd: xc_status_t setWrongPasswd()
setNullPasswd: xc_status_t setNullPasswd()
EOF

setenv GTMXC ./passwd_external_call.xc
echo "******* Experiment #1: Verify that we cannot access the global in an encrypted file without password *******"
unsetenv gtm_passwd
$GTM << EOF
w ^a
halt
EOF

echo "******* Experiment #2: Verify we can set gtm_passwd value after we are in GT.M *******"
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
w ^a
d &setCorrectPasswd
w ^a
h
EOF

echo "******* Experiment #3: Verify we can be prompted for password after we are in GT.M and access a global *******"
$gtm_tst/com/reset_gpg_agent.csh
expect -f $gtm_tst/$tst/inref/experiment_3.exp $gtm_dist  >&! experiment_3.out
$grep "THIS_VAR_IS_ENCRYPTED" experiment_3.out >&! grep_var3.out
set stat1=$status
$tail -n 1 experiment_3.out | $grep "GTM" >&! grep_gtm3.out
set stat2=$status
# Verify that after taking the password, GT.M prints the value and stays in the prompt
if ($stat1 ||  $stat2) then
	echo "Experiment #3 failed. Please see experiment_3.out"
else
	echo "Experiment #3 passed."
endif

echo "******* Experiment #4 Verify we can recover from a bad password by setting to a correct value after entering GT.M *******"
$gtm_tst/com/reset_gpg_agent.csh
$GTM << EOF
w ^a
d &setWrongPasswd
zsystem "$gtm_tst/com/reset_gpg_agent.csh"
w ^a
d &setCorrectPasswd
zsystem "$gtm_tst/com/reset_gpg_agent.csh"
w ^a
h
EOF

echo "******* Experiment #5 Verify we can recover from a bad password by setting gtm_passwd to NULL and by entering at the prompt *******"
$gtm_tst/com/reset_gpg_agent.csh
expect -f $gtm_tst/$tst/inref/experiment_5.exp $gtm_dist >&! experiment_5.out
$grep "THIS_VAR_IS_ENCRYPTED" experiment_5.out >&! grep_var5.out
set stat1=$status
$tail -n 1 experiment_5.out | $grep "GTM" >&! grep_gtm5.out
set stat2=$status
# Verify that after taking the password, GT.M prints the value and stays in the prompt
if ($stat1 ||  $stat2) then
	echo "Experiment #5 failed. Please see experiment_5.out"
else
	echo "Experiment #5 passed."
endif

# Use check_error_exist.csh to filter out the YDB-E-CRYPTKEYFETCHFAILED error message from the output file. This error is expected in the output
# file as the above test first tries to write a global with a wrong password and hence will result in the above error. Also, we can safely
# redirect the output of check_error_exist.csh to /dev/null as the output is anyway saved in experiment_5.outx.
$gtm_tst/com/check_error_exist.csh experiment_5.out "YDB-E-CRYPTKEYFETCHFAILED" >&! /dev/null
setenv gtm_passwd $gtm_passwd_masked
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/dbcheck.csh
