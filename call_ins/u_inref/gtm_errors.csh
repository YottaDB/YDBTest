#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test call in table parsing errors
# gtm_errors.csh
#
echo "--------------------------------------------------------------------------------"
echo "TEST: Referenced label not specified in call-in table: "
source $gtm_tst/$tst/u_inref/cinoentry.csh
echo "# Test that CINOENTRY message shows relative path if GTMCI/ydb_ci env var is set to relative path"
# Note that GTMCI is already set to relative path by the previous call to "source cinoentry.csh"
ccnoent
echo "# Test that CINOENTRY message shows absolute path if GTMCI/ydb_ci env var is set to absolute path"
setenv GTMCI `pwd`/$GTMCI
ccnoent
echo "# Test that setting GTMCI/ydb_ci env var to the empty string issues a CITABOPN error"
setenv GTMCI ""
ccnoent
unsetenv GTMCI	# unset GTMCI env var before moving on to next stage of test
echo "--------------------------------------------------------------------------------"
echo "TEST: Invalid direction for passed parameters: "
source $gtm_tst/$tst/u_inref/cidirctv.csh
dirctv
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Missing/Invalid C identifier in call-in table: "
source $gtm_tst/$tst/u_inref/circalname.csh
cclerr
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Wrong type specification for O/IO, pointer type expected: "
source $gtm_tst/$tst/u_inref/cipartyp.csh
cpartyp
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Syntax errors in parameter specifications in call-in table: "
source $gtm_tst/$tst/u_inref/ciparnam.csh
cparnam
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Unknown parameter type specifcation:  "
source $gtm_tst/$tst/u_inref/ciuntype.csh
cuntype
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Invalid return type specifcation:  "
source $gtm_tst/$tst/u_inref/cirtntyp.csh
crtntyp
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Environment variable for call table:"
source $gtm_tst/$tst/u_inref/citabenv.csh
ctabenv
#unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Unable to open call table:"
source $gtm_tst/$tst/u_inref/citabopn.csh
ctabopn
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Multiple caret:"
source $gtm_tst/$tst/u_inref/cimulcar.csh
cmulcar
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
