#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# Regression test for parsing incompletly specified Z* ISV, functions and commands"
echo "# This test specifies various commands that are part of other M implementations "
echo "#  but are not implemented by YottaDB. Its only function is to act as a canary to tell"
echo "#  us if the expression parser changes."
echo ""
echo "# A compilation is done; and there is not supposed to be any output below."
echo "# The previous output was:"
echo "# -- %YDB-E-INVSVN, Invalid special variable name"
echo "# -- %YDB-E-FNOTONSYS, Function or special variable is not supported by this operating system"
echo "# -- %YDB-E-INVFCN, Invalid function name"
echo "# -- %YDB-E-INVCMD, Invalid command keyword encountered"
cp $gtm_tst/$tst/inref/ydb925.m .
$gtm_dist/mumps ydb925
