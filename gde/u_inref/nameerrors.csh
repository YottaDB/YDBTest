#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The below collation numbers are used in the gde commands below
source $gtm_tst/com/cre_coll_sl_straight.csh 1
source $gtm_tst/com/cre_coll_sl_reverse.csh 99
source $gtm_tst/com/cre_coll_sl.csh polish 9

@ case = 1
# First generate the required gde command list

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/nameerrors.cmd'")'

# If there is an error gde @file.com won't return.

cp gdenameerrors.cmd gdenameerrors.cmd_orig
sed 's/\$/\\\$/g' gdenameerrors.cmd_orig >&! gdenameerrors.cmd
# Now generate a script to be executed
echo "$GDE << gde_eof"	>>&! name_errors_script.csh
cat gdenameerrors.cmd	>>&! name_errors_script.csh
echo "gde_eof"		>>&! name_errors_script.csh

chmod +x name_errors_script.csh

./name_errors_script.csh

mv mumps.gld mumps.gld_$case
@ case++

echo "# Test that all regions comprising a spanning global need to be checked for stdnullcoll"
$GDE << GDE_EOF
template -region -nostdnullcoll
change -region DEFAULT -nostdnullcoll
add -reg AREG -d=ASEG
add -seg ASEG -f=a.dat
add -name A(1:100) -reg=AREG
GDE_EOF
