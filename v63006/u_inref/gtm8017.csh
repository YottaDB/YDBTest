#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# The ^%TRIM() utility allows the specification of what character(s) to trim from either the left and/or right hand side of a given string'
echo '# The default trim characters are $CHAR(32,9) (<SP> and <TAB>), these can be overridden by passing a string consisting of the desired characters in the optional second parameter.This functionality has existed for some time but was undocumented and not regularly tested'

echo
echo '# Testing $$FUNC^%TRIM varients of %TRIM'
$gtm_dist/mumps -run gtm8017
