#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "## Test that a call-in successfully invokes an external call that uses Simple API ##"
echo "# Should avoid a SIG-11 error and return the variable rc as 0"
echo ""
echo "# Automates haisenbug test which can be found at:"
echo "https://gitlab.com/YottaDB/DB/YDB/issues/401 or https://github.com/YottaDB/YDB/issues/351"
echo ""
echo "# Copy relevant files"
cp $gtm_tst/$tst/inref/ydb401.c .
cp $gtm_tst/$tst/inref/ydb401_plugin.c .
cp $gtm_tst/$tst/inref/ydb401.m .
cp $gtm_tst/$tst/inref/ydb401_Makefile .

cat >> extcall.tab << CAT_EOF
\$plugin
func: gtm_long_t func(I:gtm_string_t*)
CAT_EOF

cat >> callin.tab << CAT_EOF
echo:	void echo^ydb401()
test1:	void test1^ydb401(I:gtm_char_t*)
call:	void call^ydb401()
CAT_EOF

echo "# Running the make file"
make -f ydb401_Makefile run
