#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_jnl NON_SETJNL
# This test prints lines longer than 200 columns in some cases particularly now that region name prefix is printed as part
# of mupip journal recover output as part of GTM-5007. Override local environment setting of COLUMNS in case it is smaller.
setenv COLUMNS 300
$gtm_tst/com/dbcreate.csh mumps.dat
$MUPIP set -journal=on,enable,before -region "*"
$GTM << EOF
set ^a=1
EOF
ln -s mumps.mjl link.mjl
cp mumps.mjl copy.mjl

# Issue 1 : Report duplicated files in forward recovery
#   Identical argument
$MUPIP journal -recover -forward mumps.mjl,mumps.mjl
#   Different path definition
$MUPIP journal -recover -forward mumps.mjl,../C9K08003315/mumps.mjl
#   Symlink
$MUPIP journal -recover -forward mumps.mjl,link.mjl
#   One different file between two identical ones
$MUPIP journal -recover -forward mumps.mjl,copy.mjl,mumps.mjl
#   Do not report duplicated files in backward recovery
$MUPIP journal -recover -backward mumps.mjl,mumps.mjl

if (-X expect) then
	# Issue 2 : Don't repeat the Y/N prompt if no user input.
	cp mumps.dat back.dat
	$GTM << EOF
set ^b=1
EOF
	cp back.dat mumps.dat
	setenv TERM xterm
	expect -f $gtm_tst/$tst/u_inref/C9K08003315.exp $gtm_dist
else
	echo "No expect in PATH, please install"
endif
$gtm_tst/com/dbcheck.csh
