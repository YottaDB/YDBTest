#################################################################
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
#
echo '# Test that $ZEDITOR reflects exit status of the last ZEDIT invocation'
echo ""

setenv EDITOR "tmp.csh"

foreach value (120 250)
	echo "------------------------------------------------------"
	echo '# Test that $ZEDITOR is 0 at first and then is '$value
	echo "------------------------------------------------------"
	set verbose
	echo "#\!/usr/local/bin/tcsh" > tmp.csh
	echo "exit $value" >> tmp.csh
	chmod +x tmp.csh
	$ydb_dist/mumps -run ^%XCMD 'zwrite $zeditor  zedit "x.m"  zwrite $zeditor'
	unset verbose
	echo ""
end
