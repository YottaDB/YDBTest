#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set file = $1
set expected = $2

set actual = `ls -l $file | $tst_awk '{print $1":"$3":"$4}'`

if ("$actual" == "$expected") then
	echo "TEST-I-PASS file permissions of $file:t is as expected"
else
	echo "TEST-E-FAIL file permissions of $file is not as expected"
	echo "The expected permissions are $expected, but contents of "'$actual'" are:"
	echo "$actual"
	echo "The full file listing is:"
	ls -l $file
endif
