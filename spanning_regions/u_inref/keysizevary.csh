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

$GDE @$gtm_tst/$tst/inref/keysizevary.gde

$MUPIP create

echo "# run keysizevary. Expect GVSUBOFLOW errors from most commands"
$gtm_exe/mumps -run keysizevary
