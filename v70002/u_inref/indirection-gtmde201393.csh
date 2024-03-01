#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

setenv ydb_prompt 'YDB>'
setenv gtm_prompt 'YDB>' # make output the same
setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB

cat <<echo_text
########################################################################################
# Test that M indirection @x@(1) works correctly when x contains a comment or is empty
########################################################################################
#
# test1: that M ignores a terminating comment in name indirection by checking whether the
# comment terminates its own string alone or the whole indirection line (as previously).
# This is tested by passing subscripts that will not get invoked in older versions.
# Expect a 1, not a 0
echo_text

$gtm_dist/mumps -direct <<indirection_code
s x="z;comment",z=0,z(1)=1
w @x@(1)
Halt
indirection_code

cat <<echo_text

# test2: that M produces VAREXPECTED error rather than INDEXTRACHARS (as previously)
# when an empty indirection variable is supplied.
echo_text

$gtm_dist/mumps -direct <<indirection_code
s x=""
w @x@(1)
Halt
indirection_code

echo
